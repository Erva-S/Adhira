require('dotenv').config();
const express = require('express');
const cors = require('cors');
const { GeminiService, RESPONSES } = require('./services/gemini_service');
const dataStore = require('./database/data_store');
const websiteScraperService = require('./services/website_scraper_service');

const app = express();
const PORT = process.env.PORT || 3000;

// ── Middleware ────────────────────────────────────────────────────────────────
app.use(cors());
app.use(express.json());

// Request logger
app.use((req, res, next) => {
  if (process.env.NODE_ENV !== 'test') {
    console.log(`[${new Date().toISOString()}] ${req.method} ${req.path}`);
  }
  next();
});

// Initialize Gemini Service
const geminiService = new GeminiService();

// ── Routes ───────────────────────────────────────────────────────────────────

// Health Check
app.get('/api/health', (req, res) => {
  res.json({
    status: 'healthy',
    service: 'Tribal Scholar Saathi — JAGO AI Assistant Server',
    model: geminiService.modelName,
    geminiConfigured: Boolean(geminiService.apiKey)
  });
});

// Predefined Suggestions
app.get('/api/jago/suggestions', (req, res) => {
  res.json({
    success: true,
    suggestions: [
      'Check my eligibility',
      'Track my application',
      'What documents do I need?',
      'What documents are pending?',
      'Check my payment status',
      'Which scholarship am I applying for?'
    ]
  });
});

// Trusted Official Website Knowledge Endpoint (tribal.nic.in/ScholarshiP.aspx)
app.get('/api/jago/website-knowledge', async (req, res) => {
  try {
    const { refresh = 'false', query } = req.query;
    if (query) {
      const relevant = await websiteScraperService.findRelevantContent(query);
      return res.json({ success: true, data: relevant });
    }
    const knowledge = await websiteScraperService.getKnowledge({ forceRefresh: refresh === 'true' });
    res.json({ success: true, data: knowledge });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

// Main Chat Endpoint
app.post('/api/jago/chat', async (req, res) => {
  try {
    const {
      message,
      conversationHistory = [],
      userId = 'TSS-2025-45678',
      applicationId = 'app-pms-2025-001',
      locale = 'en',
      languageInstruction = '',
      screenContext = ''
    } = req.body;

    if (!message || typeof message !== 'string') {
      return res.status(400).json({
        success: false,
        error: 'Message parameter is required and must be a string.'
      });
    }

    // Process through Gemini AI assistant
    const result = await geminiService.processChat({
      message,
      conversationHistory,
      userId,
      applicationId,
      locale,
      languageInstruction,
      screenContext
    });

    return res.json({
      success: true,
      reply: result.reply,
      toolCalls: result.toolCalls || []
    });
  } catch (err) {
    console.error('[JAGO Backend] Chat processing error:', err);
    return res.status(500).json({
      success: false,
      reply: RESPONSES.UNAVAILABLE,
      error: err.message
    });
  }
});

// Schemes endpoint for direct query
app.get('/api/scholarships', async (req, res) => {
  const schemes = await dataStore.getScholarshipSchemes();
  res.json({ success: true, data: schemes });
});

// ── Real-Time Push Notification Endpoints ─────────────────────────────────────
const PushNotificationService = require('./services/push_notification_service');

// Register FCM Device Token for authenticated user
app.post('/api/notifications/register-token', (req, res) => {
  const { userId, token } = req.body;
  if (!userId || !token) {
    return res.status(400).json({ success: false, error: 'userId and token are required.' });
  }
  const registered = PushNotificationService.registerToken(userId, token);
  return res.json({ success: registered, message: 'FCM device token registered successfully.' });
});

// Unregister Device Token on logout
app.post('/api/notifications/unregister-token', (req, res) => {
  const { userId, token } = req.body;
  if (!userId) {
    return res.status(400).json({ success: false, error: 'userId is required.' });
  }
  PushNotificationService.unregisterToken(userId, token);
  return res.json({ success: true, message: 'FCM device token unregistered successfully.' });
});

// Send Push Notification to User (or simulate event)
app.post('/api/notifications/send', async (req, res) => {
  const { userId, title, message, type = 'system', actionRoute = '/notifications', relatedId = null, metadata = {} } = req.body;
  if (!userId || !title || !message) {
    return res.status(400).json({ success: false, error: 'userId, title, and message are required.' });
  }
  const result = await PushNotificationService.sendToUser(userId, {
    title,
    message,
    type,
    actionRoute,
    relatedId,
    metadata
  });
  return res.json(result);
});

// Query registered tokens for user (debug/admin)
app.get('/api/notifications/tokens/:userId', (req, res) => {
  const tokens = PushNotificationService.getTokensForUser(req.params.userId);
  return res.json({ success: true, userId: req.params.userId, tokenCount: tokens.length, tokens });
});

// Start Server if not imported by test
if (process.env.NODE_ENV !== 'test') {
  app.listen(PORT, () => {
    console.log(`====================================================`);
    console.log(`🚀 JAGO AI Assistant Backend running on http://localhost:${PORT}`);
    console.log(`🤖 Target Model: ${geminiService.modelName}`);
    console.log(`🔑 Gemini API Key configured: ${geminiService.apiKey ? 'YES (Secure server-side)' : 'NO (Add to backend/.env)'}`);
    console.log(`📡 Endpoints:`);
    console.log(`   POST http://localhost:${PORT}/api/jago/chat`);
    console.log(`   GET  http://localhost:${PORT}/api/jago/suggestions`);
    console.log(`   GET  http://localhost:${PORT}/api/health`);
    console.log(`====================================================`);
  });
}

module.exports = app;
