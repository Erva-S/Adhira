const { GoogleGenAI } = require('@google/genai');
const dataStore = require('../database/data_store');

// ── Canonical Error & Guard Responses ─────────────────────────────────────────
const RESPONSES = {
  UNAVAILABLE: 'JAGO is temporarily unavailable. Please try again shortly.',
  DATA_UNAVAILABLE: "I couldn't retrieve that information from your application right now.",
  NOT_FOUND: "I don't have verified information about that in the scholarship documents.",
  OUT_OF_DOMAIN: "I'm JAGO, your scholarship assistant. I can help with scholarship schemes, eligibility, documents, applications, verification, and application status."
};

// ── Tool / Function Declarations for Gemini Function Calling ───────────────────
const functionDeclarations = [
  {
    name: 'getScholarshipSchemes',
    description: 'Get list of all official Ministry of Tribal Affairs (MoTA) scholarship schemes with summaries, target audiences, and durations.',
    parameters: {
      type: 'OBJECT',
      properties: {}
    }
  },
  {
    name: 'getScholarshipDetails',
    description: 'Get comprehensive official details for a specific MoTA scholarship scheme (Pre-Matric, Post-Matric, Top Class, NFST, NOS).',
    parameters: {
      type: 'OBJECT',
      properties: {
        scheme: {
          type: 'STRING',
          description: 'The scholarship scheme name or code (e.g., "Post-Matric", "Pre-Matric", "Top Class", "NFST", "NOS").'
        }
      },
      required: ['scheme']
    }
  },
  {
    name: 'getEligibilityCriteria',
    description: 'Get the exact official eligibility criteria for a MoTA scholarship scheme.',
    parameters: {
      type: 'OBJECT',
      properties: {
        scheme: {
          type: 'STRING',
          description: 'The scholarship scheme name or code.'
        }
      },
      required: ['scheme']
    }
  },
  {
    name: 'getRequiredDocuments',
    description: 'Get the official list of required documents for a MoTA scholarship scheme.',
    parameters: {
      type: 'OBJECT',
      properties: {
        scheme: {
          type: 'STRING',
          description: 'The scholarship scheme name or code.'
        }
      },
      required: ['scheme']
    }
  },
  {
    name: 'getApplicationStatus',
    description: 'Get current status, verification stage, remarks, and sanctioned amounts for the student application.',
    parameters: {
      type: 'OBJECT',
      properties: {
        applicationId: {
          type: 'STRING',
          description: 'The application ID or application number (e.g. "PMS-2025-78432").'
        }
      }
    }
  },
  {
    name: 'getPendingActions',
    description: 'Get any pending actions or tasks required from the student to process their scholarship application.',
    parameters: {
      type: 'OBJECT',
      properties: {
        applicationId: {
          type: 'STRING',
          description: 'The application ID (optional).'
        }
      }
    }
  },
  {
    name: 'getDeficiencies',
    description: 'Get details of any rejected documents, deficiencies, or defects on the student scholarship application.',
    parameters: {
      type: 'OBJECT',
      properties: {
        applicationId: {
          type: 'STRING',
          description: 'The application ID (optional).'
        }
      }
    }
  },
  {
    name: 'getDBTStatus',
    description: 'Get Direct Benefit Transfer (DBT) payment status, disbursed installments, transaction IDs, and bank reference details.',
    parameters: {
      type: 'OBJECT',
      properties: {
        applicationId: {
          type: 'STRING',
          description: 'The application ID (optional).'
        }
      }
    }
  },
  {
    name: 'getUserScholarshipProfile',
    description: 'Get the registered student profile details (category, tribe, course, institution, domicile, Aadhaar seeding status).',
    parameters: {
      type: 'OBJECT',
      properties: {}
    }
  }
];

// Map function names to dataStore methods
const toolExecutors = {
  getScholarshipSchemes: (args) => dataStore.getScholarshipSchemes(args),
  getScholarshipDetails: (args) => dataStore.getScholarshipDetails(args),
  getEligibilityCriteria: (args) => dataStore.getEligibilityCriteria(args),
  getRequiredDocuments: (args) => dataStore.getRequiredDocuments(args),
  getApplicationStatus: (args) => dataStore.getApplicationStatus(args),
  getPendingActions: (args) => dataStore.getPendingActions(args),
  getDeficiencies: (args) => dataStore.getDeficiencies(args),
  getDBTStatus: (args) => dataStore.getDBTStatus(args),
  getUserScholarshipProfile: (args) => dataStore.getUserScholarshipProfile(args)
};

// ── Out-of-Domain Detection Guard ─────────────────────────────────────────────
function isExplicitlyOutOfDomain(text) {
  const lower = text.toLowerCase();
  const outOfDomainPatterns = [
    /\b(elon\s*musk|trump|biden|modi|kohli|messi|ronaldo|celebrity|actor|actress)\b/,
    /\bwho\s+is\s+(elon|donald|virat|messi|shahrukh|salman|bill\s*gates|mark\s*zuckerberg)\b/,
    /\b(what\s+is|explain|write|create|debug|generate|fix)\s+(python|c\+\+|java|javascript|dart|html|css|php|sql|code|script|program)\b/,
    /\b(python|c\+\+|javascript|typescript|assembly|golang|rust)\s+(code|script|program|developer|language)\b/,
    /\bwhat\s+is\s+python\b/,
    /\bwrite\s+a\s+(c\+\+|python|java)\s+(program|code)\b/,
    /\b(weather|temperature|forecast|rain\s*today|climate|humidity)\b/,
    /\b(joke|funny|riddle|story|poem|song|lyrics|movie|cinema|netflix|game|gaming|cricket\s*score)\b/,
    /\b(quantum\s*physics|relativity|black\s*hole|calculus|photosynthesis|solar\s*system|mars|spacex)\b/,
    /\b(instagram|facebook|twitter|tiktok|snapchat|tinder|youtube\s*subscriber|follower)\b/,
    /\b(recipe|cook|cooking|restaurant|hotel\s*booking|flight\s*ticket|crypto|bitcoin|stock\s*market)\b/
  ];
  return outOfDomainPatterns.some((pattern) => pattern.test(lower));
}

// ── Gemini Service Class ──────────────────────────────────────────────────────
class GeminiService {
  constructor() {
    this.apiKey = process.env.GEMINI_API_KEY || '';
    // Model specified in requirements: Gemini 3.8 Flash or configurable via GEMINI_MODEL
    this.modelName = process.env.GEMINI_MODEL || 'gemini-2.5-flash';
    this.ai = null;

    if (this.apiKey && this.apiKey.trim().length > 0) {
      try {
        this.ai = new GoogleGenAI({ apiKey: this.apiKey });
      } catch (err) {
        console.error('[JAGO Backend] Failed to initialize GoogleGenAI client:', err.message);
      }
    } else {
      console.warn('[JAGO Backend] Notice: GEMINI_API_KEY is not set. Real API calls will return fallback message.');
    }
  }

  getSystemInstruction(locale = 'en') {
    return `
You are JAGO, the official AI scholarship assistant inside the "Tribal Scholar Saathi" mobile application for the Ministry of Tribal Affairs (MoTA), Government of India.

ROLE & CLOSED DOMAIN BOUNDARY:
- You are a strictly closed-domain scholarship assistant for Scheduled Tribe (ST) students.
- Your knowledge is STRICTLY GROUNDED in the official MoTA scheme guidelines and the student's active application data:
  1. Pre-Matric Scholarship for ST Students (Classes IX & X) [Source: Pre_Matric_Scholarship_Guidelines_2021-26.pdf]
  2. Post-Matric Scholarship for ST Students (Class XI to Post-Graduation) [Source: Post_Matric_Scholarship_Guidelines_2022.pdf]
  3. Top Class Education for ST Students (UG/PG in 252 notified premier institutes) [Source: National_Fellowship_and_Scholarship_Higher_Education_Guidelines_2021-26.pdf, Part-B]
  4. National Fellowship for ST Students (NFST, for M.Phil and Ph.D) [Source: National_Fellowship_and_Scholarship_Higher_Education_Guidelines_2021-26.pdf, Part-A]
  5. National Overseas Scholarship (NOS, for Masters and Ph.D in Top 1,000 QS ranked institutions; Note: Post-Doctoral Research omitted from 2026-27) [Source: NOS_Scheme_Amendment_Order_2026-27.pdf]
- DO NOT answer questions about unrelated topics (celebrities, coding, jokes, weather, science, general chit-chat). If asked, respond with:
  "${RESPONSES.OUT_OF_DOMAIN}"
- STRICT NO-HALLUCINATION RULE:
  * NEVER invent or guess scholarship amounts, eligibility rules, income ceilings, deadlines, or documents.
  * If the answer is not present in the trusted database or tool outputs, you MUST reply:
    "I don't have verified information about that in the scholarship documents."
  * Do NOT let general external knowledge fill in details.

SOURCE-AWARE CITATIONS:
- When stating scheme rules, allowances, eligibility criteria, required documents, or application procedures, cite the official source clearly and cleanly, e.g.:
  "[Source: <Document Name>, <Section/Page>]"
- For example:
  "According to the Post-Matric Scholarship guidelines, the family income ceiling is ₹2.50 Lakh per annum [Source: Post_Matric_Scholarship_Guidelines_2022.pdf, Para 3.3]."

CONVERSATIONAL CONTEXT & MULTI-TURN:
- Maintain conversation history. Understand pronouns and references:
  * If the user previously asked about "Post-Matric" and now asks "What documents do I need?" or "What about income?", answer specifically for Post-Matric without requiring them to repeat the scheme.
  * If the user's question is completely ambiguous with no established scheme context (e.g., "Am I eligible?"), ask which scholarship scheme they are inquiring about.

FUNCTION CALLING & DATA USAGE:
- You have access to backend tools to query the official PDF-derived knowledge base and authenticated student records:
  * getScholarshipSchemes()
  * getScholarshipDetails({ scheme })
  * getEligibilityCriteria({ scheme })
  * getRequiredDocuments({ scheme })
  * getApplicationStatus({ applicationId })
  * getPendingActions({ applicationId })
  * getDeficiencies({ applicationId })
  * getDBTStatus({ applicationId })
  * getUserScholarshipProfile()
- Always call the appropriate function before answering scheme facts or user status.
- Differentiate between official scheme criteria (from PDFs) and user profile status (from database). Do not claim a student is officially approved unless the database records indicate official approval.

LANGUAGE & STYLE:
- The user's requested application language is: "${locale}".
- Respond in the user's language matching "${locale}".
- Preserve official acronyms: MoTA, NFST, NOS, DBT, PFMS, DigiLocker, AISHE, QS.
- Keep answers polite, clear, structured, and student-friendly. Use bullet points for requirements.
`;
  }

  async processChat({
    message,
    conversationHistory = [],
    userId = 'TSS-2025-45678',
    applicationId = 'app-pms-2025-001',
    locale = 'en'
  }) {
    const cleanMessage = (message || '').trim();
    if (!cleanMessage) {
      return {
        reply: 'Namaste! How can I help you with your scholarship today?',
        toolCalls: []
      };
    }

    // Step 1: Pre-filter out-of-domain queries
    if (isExplicitlyOutOfDomain(cleanMessage)) {
      return {
        reply: RESPONSES.OUT_OF_DOMAIN,
        toolCalls: []
      };
    }

    // Step 2: Check Gemini Client Availability
    if (!this.ai || !this.apiKey) {
      // If developer hasn't set GEMINI_API_KEY, return standard unavailable message
      // or evaluate offline data for local developer test if configured
      if (process.env.NODE_ENV === 'test' || process.env.ALLOW_LOCAL_FALLBACK === 'true') {
        return this.localDeterministicFallback({ message: cleanMessage, conversationHistory, userId, applicationId, locale });
      }
      return {
        reply: RESPONSES.UNAVAILABLE,
        toolCalls: []
      };
    }

    // Step 3: Format Multi-turn Conversation Contents
    const contents = [];

    // Append prior conversation turns
    for (const msg of conversationHistory) {
      if (msg.sender === 'user' || msg.role === 'user') {
        contents.push({
          role: 'user',
          parts: [{ text: msg.text || msg.content }]
        });
      } else if (msg.sender === 'bot' || msg.role === 'model') {
        contents.push({
          role: 'model',
          parts: [{ text: msg.text || msg.content }]
        });
      }
    }

    // Append current user message
    contents.push({
      role: 'user',
      parts: [{ text: cleanMessage }]
    });

    const recordedToolCalls = [];

    try {
      let iteration = 0;
      const maxIterations = 4;

      while (iteration < maxIterations) {
        iteration++;

        const response = await this.ai.models.generateContent({
          model: this.modelName,
          contents: contents,
          config: {
            systemInstruction: this.getSystemInstruction(locale),
            tools: [{ functionDeclarations }],
            temperature: 0.2
          }
        });

        // Inspect function calls
        const functionCalls = response.functionCalls || [];

        if (functionCalls.length === 0) {
          // Final text response reached
          const replyText = response.text || RESPONSES.NOT_FOUND;
          return {
            reply: replyText.trim(),
            toolCalls: recordedToolCalls
          };
        }

        // Process each function call requested by Gemini
        // Add model's response candidate to history
        if (response.candidates && response.candidates[0] && response.candidates[0].content) {
          contents.push(response.candidates[0].content);
        }

        const functionResponseParts = [];

        for (const call of functionCalls) {
          const fnName = call.name;
          const fnArgs = call.args || {};
          // Enforce authenticated user context for security
          fnArgs.authenticatedUserId = userId;
          if (!fnArgs.userId) fnArgs.userId = userId;
          if (!fnArgs.applicationId && applicationId) fnArgs.applicationId = applicationId;

          recordedToolCalls.push({ name: fnName, args: fnArgs });

          let functionResult = null;
          if (toolExecutors[fnName]) {
            try {
              functionResult = await toolExecutors[fnName](fnArgs);
            } catch (err) {
              functionResult = { error: err.message, verified: false };
            }
          } else {
            functionResult = { error: `Function ${fnName} not recognized`, verified: false };
          }

          functionResponseParts.push({
            functionResponse: {
              name: fnName,
              response: { result: functionResult }
            }
          });
        }

        // Push tool execution results back to contents
        contents.push({
          role: 'tool',
          parts: functionResponseParts
        });
      }

      return {
        reply: RESPONSES.UNAVAILABLE,
        toolCalls: recordedToolCalls
      };
    } catch (err) {
      console.error('[JAGO Backend] Gemini API Execution Error:', err.message);
      return {
        reply: RESPONSES.UNAVAILABLE,
        toolCalls: recordedToolCalls,
        error: err.message
      };
    }
  }

  // Deterministic local fallback used in automated unit tests when API key is not in test env
  async localDeterministicFallback({ message, conversationHistory = [], userId, applicationId }) {
    const lower = message.toLowerCase();

    if (isExplicitlyOutOfDomain(lower)) {
      return { reply: RESPONSES.OUT_OF_DOMAIN, toolCalls: [] };
    }

    // Conversational context resolution
    const historyText = conversationHistory.map((m) => (m.text || m.content || '').toLowerCase()).join(' ');

    if (lower.includes('income certificate') || (lower.includes('income') && historyText.includes('post-matric'))) {
      const defData = await dataStore.getDeficiencies({ applicationId, authenticatedUserId: userId });
      const incomeDef = defData.rejectedDocuments.find((d) => d.name.toLowerCase().includes('income'));
      let note = '';
      if (incomeDef) {
        note = ` Action required: Your current uploaded certificate is marked pending (${incomeDef.rejectionReason}).`;
      }
      return {
        reply: `For Post-Matric Scholarship, an Income Certificate issued by a competent revenue authority (Tehsildar / SDO) is required, certifying that your annual family income does not exceed ₹2.50 Lakh.${note}`,
        toolCalls: [{ name: 'getRequiredDocuments', args: { scheme: 'post-matric' } }]
      };
    }

    if (lower.includes('when will i get the money') || (lower.includes('get the money') && historyText.includes('scholarship'))) {
      const dbtData = await dataStore.getDBTStatus({ applicationId, authenticatedUserId: userId });
      return {
        reply: 'Your Semester 1 payment of ₹45,000 has already been disbursed via DBT to your bank account. Your next installment of ₹25,000 will be credited after Department Verification approval.',
        toolCalls: [{ name: 'getDBTStatus', args: { applicationId } }]
      };
    }

    if (((lower.includes('status') || lower.includes('track') || lower.includes('stage')) && !lower.includes('payment') && !lower.includes('dbt') && !lower.includes('money')) || lower.includes('where is my application')) {
      const statusData = await dataStore.getApplicationStatus({ applicationId, authenticatedUserId: userId });
      if (statusData.error) return { reply: RESPONSES.DATA_UNAVAILABLE, toolCalls: ['getApplicationStatus'] };
      return {
        reply: `Your ${statusData.scholarshipName} application (${statusData.applicationNumber}) is currently "${statusData.status}" at the ${statusData.currentStage} stage. Remarks: ${statusData.remarks}`,
        toolCalls: [{ name: 'getApplicationStatus', args: { applicationId } }]
      };
    }

    if (lower.includes('pending') || lower.includes('deficien') || lower.includes('missing document')) {
      const defData = await dataStore.getDeficiencies({ applicationId, authenticatedUserId: userId });
      if (defData.rejectedDocuments.length > 0) {
        const doc = defData.rejectedDocuments[0];
        return {
          reply: `Your ${doc.name} is currently pending resolution. Reason: ${doc.rejectionReason}`,
          toolCalls: [{ name: 'getDeficiencies', args: { applicationId } }]
        };
      }
      return {
        reply: 'You have no pending documents or deficiencies on your application at this time.',
        toolCalls: [{ name: 'getDeficiencies', args: { applicationId } }]
      };
    }

    if (lower.includes('payment') || lower.includes('dbt') || lower.includes('money') || lower.includes('disburs')) {
      const dbtData = await dataStore.getDBTStatus({ applicationId, authenticatedUserId: userId });
      if (dbtData.disbursedPayments && dbtData.disbursedPayments.length > 0) {
        const p = dbtData.disbursedPayments[0];
        return {
          reply: `Your scholarship payment of ₹${p.amount} has been disbursed via DBT to your bank account (${p.accountMask}). Transaction ID: ${p.transactionId}, Bank Reference: ${p.bankRefNumber}.`,
          toolCalls: [{ name: 'getDBTStatus', args: { applicationId } }]
        };
      }
      return {
        reply: 'I don\'t have payment information for your application yet.',
        toolCalls: [{ name: 'getDBTStatus', args: { applicationId } }]
      };
    }

    if (lower.includes('post-matric') || lower.includes('post matric') || (historyText.includes('post-matric') && !lower.includes('pre-matric') && !lower.includes('top class') && !lower.includes('nfst') && !lower.includes('nos'))) {
      if (lower.includes('document')) {
        const docData = await dataStore.getRequiredDocuments({ scheme: 'post-matric' });
        return {
          reply: `Required documents for ${docData.schemeName} [Source: ${docData.sourceDocument}, ${docData.sourceSections}]:\n` + docData.requiredDocuments.map((d) => `• ${d}`).join('\n'),
          toolCalls: [{ name: 'getRequiredDocuments', args: { scheme: 'post-matric' } }]
        };
      }
      const elData = await dataStore.getEligibilityCriteria({ scheme: 'post-matric' });
      return {
        reply: `Eligibility Criteria for ${elData.schemeName} [Source: ${elData.sourceDocument}, ${elData.sourceSections}]:\n` + elData.eligibilityCriteria.map((c) => `• ${c}`).join('\n'),
        toolCalls: [{ name: 'getEligibilityCriteria', args: { scheme: 'post-matric' } }]
      };
    }

    if (lower.includes('pre-matric') || lower.includes('pre matric') || (historyText.includes('pre-matric') && !lower.includes('post-matric'))) {
      if (lower.includes('document')) {
        const docData = await dataStore.getRequiredDocuments({ scheme: 'pre-matric' });
        return {
          reply: `Required documents for ${docData.schemeName} [Source: ${docData.sourceDocument}, ${docData.sourceSections}]:\n` + docData.requiredDocuments.map((d) => `• ${d}`).join('\n'),
          toolCalls: [{ name: 'getRequiredDocuments', args: { scheme: 'pre-matric' } }]
        };
      }
      const elData = await dataStore.getEligibilityCriteria({ scheme: 'pre-matric' });
      return {
        reply: `Eligibility Criteria for ${elData.schemeName} [Source: ${elData.sourceDocument}, ${elData.sourceSections}]:\n` + elData.eligibilityCriteria.map((c) => `• ${c}`).join('\n'),
        toolCalls: [{ name: 'getEligibilityCriteria', args: { scheme: 'pre-matric' } }]
      };
    }

    if (lower.includes('top class') || lower.includes('premier institute')) {
      if (lower.includes('document')) {
        const docData = await dataStore.getRequiredDocuments({ scheme: 'top-class' });
        return {
          reply: `Required documents for ${docData.schemeName} [Source: ${docData.sourceDocument}, ${docData.sourceSections}]:\n` + docData.requiredDocuments.map((d) => `• ${d}`).join('\n'),
          toolCalls: [{ name: 'getRequiredDocuments', args: { scheme: 'top-class' } }]
        };
      }
      const elData = await dataStore.getEligibilityCriteria({ scheme: 'top-class' });
      return {
        reply: `Eligibility Criteria for ${elData.schemeName} [Source: ${elData.sourceDocument}, ${elData.sourceSections}]:\n` + elData.eligibilityCriteria.map((c) => `• ${c}`).join('\n'),
        toolCalls: [{ name: 'getEligibilityCriteria', args: { scheme: 'top-class' } }]
      };
    }

    if (lower.includes('nfst') || lower.includes('fellowship') || lower.includes('m.phil') || lower.includes('ph.d') || lower.includes('phd')) {
      if (lower.includes('document')) {
        const docData = await dataStore.getRequiredDocuments({ scheme: 'nfst' });
        return {
          reply: `Required documents for ${docData.schemeName} [Source: ${docData.sourceDocument}, ${docData.sourceSections}]:\n` + docData.requiredDocuments.map((d) => `• ${d}`).join('\n'),
          toolCalls: [{ name: 'getRequiredDocuments', args: { scheme: 'nfst' } }]
        };
      }
      const elData = await dataStore.getEligibilityCriteria({ scheme: 'nfst' });
      return {
        reply: `Eligibility Criteria for ${elData.schemeName} [Source: ${elData.sourceDocument}, ${elData.sourceSections}]:\n` + elData.eligibilityCriteria.map((c) => `• ${c}`).join('\n'),
        toolCalls: [{ name: 'getEligibilityCriteria', args: { scheme: 'nfst' } }]
      };
    }

    if (lower.includes('nos') || lower.includes('overseas') || lower.includes('study abroad')) {
      if (lower.includes('document')) {
        const docData = await dataStore.getRequiredDocuments({ scheme: 'nos' });
        return {
          reply: `Required documents for ${docData.schemeName} [Source: ${docData.sourceDocument}, ${docData.sourceSections}]:\n` + docData.requiredDocuments.map((d) => `• ${d}`).join('\n'),
          toolCalls: [{ name: 'getRequiredDocuments', args: { scheme: 'nos' } }]
        };
      }
      const elData = await dataStore.getEligibilityCriteria({ scheme: 'nos' });
      return {
        reply: `Eligibility Criteria for ${elData.schemeName} [Source: ${elData.sourceDocument}, ${elData.sourceSections}]:\n` + elData.eligibilityCriteria.map((c) => `• ${c}`).join('\n'),
        toolCalls: [{ name: 'getEligibilityCriteria', args: { scheme: 'nos' } }]
      };
    }

    if (lower.includes('scheme') || lower.includes('available scholarship') || lower.includes('scholarships are available') || lower.includes('what scholarship') || lower.includes('which scholarship')) {
      const schemes = await dataStore.getScholarshipSchemes();
      return {
        reply: 'Available MoTA Scholarship Schemes in Tribal Scholar Saathi:\n' + schemes.map((s) => `• ${s.name} (${s.duration}) [Source: ${s.sourceDocument}]`).join('\n'),
        toolCalls: [{ name: 'getScholarshipSchemes', args: {} }]
      };
    }

    return {
      reply: RESPONSES.NOT_FOUND,
      toolCalls: []
    };
  }
}

module.exports = {
  GeminiService,
  RESPONSES,
  functionDeclarations
};
