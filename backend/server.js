require('dotenv').config();
const express = require('express');
const cors = require('cors');
const { GeminiService, RESPONSES } = require('./services/gemini_service');
const dataStore = require('./database/data_store');

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

// Main Chat Endpoint
app.post('/api/jago/chat', async (req, res) => {
  try {
    const {
      message,
      conversationHistory = [],
      userId = 'TSS-2025-45678',
      applicationId = 'app-pms-2025-001',
      locale = 'en'
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
      locale
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
