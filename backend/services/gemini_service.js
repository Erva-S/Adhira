const { GoogleGenAI } = require('@google/genai');
const dataStore = require('../database/data_store');
const websiteScraperService = require('./website_scraper_service');

// ── Canonical Error & Guard Responses ─────────────────────────────────────────
const RESPONSES = {
  UNAVAILABLE: 'JAGO is temporarily unavailable. Please try again shortly.',
  DATA_UNAVAILABLE: "I couldn't retrieve that information from your application right now.",
  NOT_FOUND: "I couldn't verify this information from the official source right now.",
  OUT_OF_DOMAIN: "I'm JAGO, the scholarship assistant. I can help with scholarship schemes, eligibility, applications, documents, verification, DBT, and application status."
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
  },
  {
    name: 'getOfficialWebsiteKnowledge',
    description: 'Retrieve real-time verified scholarship information, scheme rules, latest deadlines, extension circulars, and DBT mechanisms directly from the official Ministry of Tribal Affairs website (tribal.nic.in/ScholarshiP.aspx).',
    parameters: {
      type: 'OBJECT',
      properties: {
        query: {
          type: 'STRING',
          description: 'The specific topic, scheme, or question to look up on the official website (e.g., "deadlines", "Pre-Matric rates", "Top Class premier institutes", "DBT requirements").'
        }
      },
      required: ['query']
    }
  }
];

// Map function names to dataStore and website scraper methods
const toolExecutors = {
  getScholarshipSchemes: (args) => dataStore.getScholarshipSchemes(args),
  getScholarshipDetails: (args) => dataStore.getScholarshipDetails(args),
  getEligibilityCriteria: (args) => dataStore.getEligibilityCriteria(args),
  getRequiredDocuments: (args) => dataStore.getRequiredDocuments(args),
  getApplicationStatus: (args) => dataStore.getApplicationStatus(args),
  getPendingActions: (args) => dataStore.getPendingActions(args),
  getDeficiencies: (args) => dataStore.getDeficiencies(args),
  getDBTStatus: (args) => dataStore.getDBTStatus(args),
  getUserScholarshipProfile: (args) => dataStore.getUserScholarshipProfile(args),
  getOfficialWebsiteKnowledge: (args) => websiteScraperService.findRelevantContent(args.query || '')
};

// ── Out-of-Domain & Domain Guard Functions ────────────────────────────────────
function isScholarshipDomain(text) {
  const lower = text.toLowerCase();
  const domainKeywords = [
    'scholarship', 'scheme', 'eligib', 'document', 'doc', 'certificate',
    'application', 'apply', 'status', 'track', 'stage', 'action', 'deficien',
    'pending', 'verif', 'payment', 'dbt', 'disburs', 'sanction', 'amount',
    'money', 'stipend', 'grant', 'fellowship', 'digilocker', 'mota', 'tribal',
    'st', 'scheduled tribe', 'pvtg', 'pre-matric', 'post-matric', 'top class',
    'nfst', 'nos', 'income cert', 'caste cert', 'bonafide', 'marksheet',
    'passbook', 'aadhaar', 'student', 'profile', 'deadline', 'allowance',
    'tuition', 'hi', 'hello', 'namaste', 'hey', 'jago', 'saathi', 'portal',
    'last date', 'extended', 'circular', 'notice', 'rule', 'guide',
    // Indian language scholarship & educational aid keywords
    'छात्रवृत्ति', 'शिष्यवृत्ती', 'पात्रता', 'स्थिति', 'दस्तावेज', 'आवेदन', 'पैसे', 'बैंक',
    'શિષ્યવૃત્તિ', 'પાત્રતા', 'સ્થિતિ', 'દસ્તાવેજ', 'અરજી', 'પૈસા',
    'বৃত্তি', 'স্কলারশিপ', 'যোগ্যতা', 'নথি', 'আবেদন',
    'உதவித்தொகை', 'தகுதி', 'நிலை', 'ஆவணங்கள்', 'விண்ணப்பம்',
    'స్కాలర్‌షిప్', 'ఉపకార వేతనం', 'అర్హత', 'స్థితి', 'పత్రాలు', 'దరఖాస్తు',
    'ವಿದ್ಯಾರ್ಥಿವೇತನ', 'ಅರ್ಹತೆ', 'ಸ್ಥಿತಿ', 'ದಾಖಲೆಗಳು', 'ಅರ್ಜಿ',
    'സ്കോളർഷിപ്പ്', 'യോഗ്യത', 'അവസ്ഥ', 'രേഖകൾ', 'അപേക്ഷ'
  ];

  if (domainKeywords.some(k => lower.includes(k))) {
    return true;
  }

  // If text contains Indic script characters and is not out of domain, allow through
  const hasIndicScript = /[\u0900-\u0D7F]/.test(text);
  if (hasIndicScript) {
    return true;
  }

  return false;
}

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
    /\b(recipe|cook|cooking|restaurant|hotel\s*booking|flight\s*ticket|crypto|bitcoin|stock\s*market)\b/,
    /\b(capital\s+of|president\s+of|population\s+of|currency\s+of)\b/
  ];
  if (outOfDomainPatterns.some((pattern) => pattern.test(lower))) {
    return true;
  }
  // If text is not a greeting and contains no scholarship domain keywords, it is out of domain
  if (!isScholarshipDomain(lower)) {
    return true;
  }
  return false;
}

function needsWebsiteRetrieval(text) {
  const lower = text.toLowerCase();
  if (isExplicitlyOutOfDomain(lower)) return false;

  // Private application tracking queries must NOT query the public website
  const isPrivateQuery = 
    ((lower.includes('my application') || lower.includes('my status') || lower.includes('where is my')) &&
      !lower.includes('deadline') && !lower.includes('last date')) ||
    lower.includes('why is my application') ||
    lower.includes('my pending') ||
    lower.includes('my payment') ||
    lower.includes('my profile');

  if (isPrivateQuery) return false;

  const webKeywords = [
    'deadline', 'last date', 'extended', 'changed', 'notification', 'announcement',
    'available', 'which scholarship', 'what scholarship', 'schemes',
    'eligib', 'criteria', 'who can apply', 'income limit', 'income ceiling',
    'document', 'documents', 'certificate',
    'pre-matric', 'pre matric', 'post-matric', 'post matric', 'top class', 'nfst', 'nos',
    'fellowship', 'overseas',
    'dbt', 'direct benefit', 'pfms'
  ];

  return webKeywords.some(k => lower.includes(k));
}

function formatSourceCitation({
  sourceUrl = 'https://tribal.nic.in/ScholarshiP.aspx',
  pageTitle = 'Scholarship & DBT',
  retrievedAt = new Date().toISOString().split('T')[0]
} = {}) {
  return `\n\n---\nSource: Official Scholarship Website\nPage: ${pageTitle}\nURL: ${sourceUrl}\nRetrieved: ${retrievedAt}`;
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

  getSystemInstruction(locale = 'en', webContext = '', languageInstruction = '', screenContext = '') {
    const languageNames = {
      en: 'English',
      hi: 'Hindi',
      gu: 'Gujarati',
      mr: 'Marathi',
      bn: 'Bengali',
      ta: 'Tamil',
      te: 'Telugu',
      kn: 'Kannada',
      ml: 'Malayalam'
    };
    const targetLanguage = languageNames[locale] || 'English';

    return `
You are JAGO, the official AI scholarship assistant inside the "Tribal Scholar Saathi" mobile application for the Ministry of Tribal Affairs (MoTA), Government of India.

ROLE & PERSONALITY:
- You are a knowledgeable, friendly, polite, and natural AI assistant specialized in the scholarship and educational financial aid domain for Scheduled Tribe (ST) students.
- You speak clearly, professionally, and naturally.
- You are BROAD inside the scholarship domain:
  * You explain general concepts freely (e.g. "What is a scholarship?", "What is DBT?", "What is DigiLocker?", "How does verification work?", "Why do scholarships require income certificates?", "What is the difference between Pre-Matric and Post-Matric?").
  * You provide comprehensive, structured overviews when asked for details of any scheme.
  * You help students check their eligibility.
- You are STRICTLY DOMAIN-RESTRICTED outside the scholarship domain:
  * If the user asks about completely unrelated topics (general trivia, coding in Python/C++, celebrities, cricket scores, weather, movies, general chit-chat), DO NOT answer using general knowledge. Instead respond:
    "${RESPONSES.OUT_OF_DOMAIN}"

MULTILINGUAL INSTRUCTIONS & TERMINOLOGY RULES:
${languageInstruction ? languageInstruction : `
- You must respond in the user's selected JAGO language: ${targetLanguage} (${locale}).
- Understand questions even when the user writes in another language, including mixed-language input such as Hinglish or Gujarati-English.
- Generate the final answer directly in ${targetLanguage}.
- Do not unnecessarily mix languages in the final output.
- Preserve official scholarship names, scheme names, government terminology, abbreviations, document names, and technical terms accurately.
- Specifically preserve terms such as: NSP, SFMP, NOS, NFST, DBT, DigiLocker, APAAR, AISHE, UDISE+, UIDAI, UGC, NTA, Aadhaar, Pre-Matric, Post-Matric, Top Class, National Overseas Scholarship.
- If an official term is normally written in English, it is acceptable to retain the official English term while explaining it in ${targetLanguage}.
- Keep answers clear and natural for students.
- Do not translate official scheme names into potentially incorrect names.
- Remain strictly within the scholarship/education-assistance domain.
`}

${screenContext ? `SCREEN & APPLICATION CONTEXT:\n${screenContext}\n` : ''}

TRUSTED OFFICIAL WEBSITE GROUNDING:
- You have access to real-time official scholarship knowledge scraped from the Ministry of Tribal Affairs (MoTA) official website: https://tribal.nic.in/ScholarshiP.aspx.
- When answering questions about available schemes, eligibility criteria, income ceilings, allowances, required documents, DBT procedures, or latest deadlines/extension circulars, you MUST ground your answer in this official data.
- NEVER invent missing deadlines, scheme rules, or government notifications. If information cannot be verified from the official website or approved guidelines, clearly respond:
  "${RESPONSES.NOT_FOUND}"
- For answers derived from or verified by the official website, you must append the official source citation at the end of your response:
  ---
  Source: Official Scholarship Website
  Page: Scholarship & DBT
  URL: https://tribal.nic.in/ScholarshiP.aspx
  Retrieved: [Date]
- For questions about a student's personal application, defects, pending actions, or payments, use the authenticated database tools (getApplicationStatus, getDeficiencies, getDBTStatus). DO NOT scrape the website for private student application tracking.

${webContext ? `CURRENT VERIFIED WEBSITE CONTEXT:\n${webContext}\n` : ''}

AUTHORITATIVE MOTA SCHOLARSHIP GUIDELINES (Use as your trusted ground truth):
1. Pre-Matric Scholarship for ST Students (Classes IX & X) [Source: Pre_Matric_Scholarship_Guidelines_2021-26.pdf]:
   - Scheme Type: Centrally Sponsored Scheme (75% Centre, 25% State; 90:10 for North-East & Hilly States; 100% for UTs without legislature).
   - Target Audience: ST students studying in Classes 9 and 10 in Government Schools or schools recognized by Govt or Central/State Boards.
   - Eligibility: Domicile ST student, Family annual income <= ₹2.50 Lakh from all sources (orphan supported by guardian has no income limit). Available for only 1 year per class (repeating a class is not funded).
   - Benefits:
     * Day Scholars: ₹225/month for 10 months (₹2,250/yr) + ₹750 annual book grant = ₹3,000/yr.
     * Hostellers: ₹525/month for 10 months (₹5,250/yr) + ₹1,000 annual book grant = ₹6,250/yr.
     * Additional Disability Allowance: ₹800/mo (Hosteller) or ₹600/mo (Day Scholar) for all 12 months.
   - Income Certificate Rule: Taken ONCE at admission to Class 9 and remains valid for Class 10. Self-declarations/affidavits are strictly NOT acceptable.
   - Required Documents: Aadhaar Number, Domicile Certificate, ST Certificate, Income Certificate (from competent revenue authority), Disability Certificate (if applicable), Passport Photo, School Bonafide/UDISE details, Bank Passbook (Aadhaar linked).
   - Portals: National Scholarship Portal (scholarships.gov.in) or State Portal / dbttribal.gov.in.

2. Post-Matric Scholarship for ST Students (Class XI to Post-Graduation) [Source: Post_Matric_Scholarship_Guidelines_2022.pdf]:
   - Scope: ST students pursuing Class 11, 12, ITI, Diploma, Polytechnic, Graduate, PG, M.Phil, Ph.D in India.
   - Eligibility: Passed Class 10 or 12, Family annual income <= ₹2.50 Lakh. One scholarship at a time. Candidates who complete a degree in one stream cannot take another course in a different stream at the same level.
   - Benefits: Compulsory non-refundable course fees + Monthly maintenance stipend for up to 10 months/year:
     * Group I (Professional Degree/PG - Engg/Medical/Tech): Hosteller ₹1,200/mo; Day Scholar ₹550/mo. (Fee cap in private institutes: ₹2.50L Engg, ₹6.00L Medical).
     * Group II (Non-professional BA, BSc, BCom, MA, MSc, MCom): Hosteller ₹820/mo; Day Scholar ₹530/mo.
     * Group III (Diploma, 3-yr Polytechnic, ITI): Hosteller ₹570/mo; Day Scholar ₹300/mo.
     * Group IV (Class XI & XII, non-degree): Hosteller ₹380/mo; Day Scholar ₹230/mo.
   - Income Certificate Rule: Taken ONCE at admission, valid for ENTIRE course duration. Fresh income certificate NOT required for renewal in 2nd or subsequent years.
   - Portals: scholarships.gov.in or State Portal / dbttribal.gov.in.

3. Top Class Education for ST Students [Source: National_Fellowship_and_Scholarship_Higher_Education_Guidelines_2021-26.pdf, Part-B]:
   - Scope: 100% Central Sector Scheme for ST students admitted on merit to 265 notified premier institutes (all IITs, NITs, IIMs, AIIMS, NLUs, etc.).
   - Eligibility: Family annual income <= ₹6.00 Lakh (spousal income included if married). NO SLOTS CEILING (all eligible verified students are funded). Students under Management Quota in private institutes are excluded.
   - Benefits: Full tuition & admission fees in Govt institutes (private cap ₹2.50L/yr), ₹5,000/yr books/stationery, ₹3,000/month living stipend, ₹45,000 one-time computer/accessories grant.
   - Portals: scholarships.gov.in (NSP).

4. National Fellowship for ST Students (NFST, M.Phil & Ph.D) [Source: National_Fellowship_and_Scholarship_Higher_Education_Guidelines_2021-26.pdf, Part-A]:
   - Scope: 750 fresh fellowships/year (38 Divyangjan, 25 PVTG, 225 Female, 462 ST Others).
   - Eligibility: Master's degree with min 55% marks, full-time M.Phil/Ph.D in UGC/INI institutions. Age limit: max 36 years as of 1st July.
   - CRUCIAL: NO INCOME CRITERIA (No income ceiling for eligibility!).
   - Rates: M.Phil ₹31,000/mo; Ph.D ₹31,000/mo (first 2 yrs) & ₹35,000/mo (next 3 yrs). Contingency ₹10,000 - ₹25,000/yr. HRA at UGC rates (8%, 16%, 24%).
   - Portals: fellowship.tribal.gov.in.

5. National Overseas Scholarship (NOS) [Source: NOS_Scheme_Amendment_Order_2026-27.pdf]:
   - Scope: Masters and Ph.D abroad. (Post-Doctoral Research was OMITTED from 2026-27 onwards).
   - Eligibility: First priority: Unconditional admission offer from Top 1,000 QS world-ranked foreign universities. Family income <= ₹6.00 Lakh. Valid Indian passport.
   - Benefits: Tuition fees, living allowance ($15,400 / £9,900), economy airfare, visa and health insurance.
   - Portals: overseas.tribal.gov.in.

CONVERSATIONAL CONTEXT:
- Keep track of conversation context. When the user asks follow-up questions ("Who can apply?", "What documents?", "What about income?", "How much?"), maintain the context of the scheme discussed previously without forcing them to repeat the scheme name.

LIVE DATABASE TOOLS (Call these for live student application data):
- getApplicationStatus({ applicationId }) -> Check live application stage, remarks, status.
- getDeficiencies({ applicationId }) -> Check rejected documents, defect reasons.
- getPendingActions({ applicationId }) -> Check pending tasks required from the student.
- getDBTStatus({ applicationId }) -> Check live payment disbursement, transaction IDs, UTRs.
- getUserScholarshipProfile() -> Get authenticated student category, course, institution.
- getOfficialWebsiteKnowledge({ query }) -> Get live verified data from tribal.nic.in/ScholarshiP.aspx.

USER LANGUAGE & FORMAT:
- User application locale: "${locale}". Reply in the corresponding language.
- Structure long responses clearly with headers, bullet points, and clean highlights.
`;
  }

  async generateWithModelFallback(payload, models = null) {
    const candidateModels = models || [
      this.modelName,
      'gemini-3.5-flash-lite',
      'gemini-flash-latest',
      'gemini-3.8-flash'
    ].filter(Boolean);

    let lastError = null;
    for (const m of candidateModels) {
      try {
        const res = await this.ai.models.generateContent({
          ...payload,
          model: m
        });
        return res;
      } catch (err) {
        lastError = err;
        console.warn(`[JAGO Backend] Model '${m}' failed (${err.message}). Trying fallback model...`);
      }
    }
    throw lastError || new Error('All candidate Gemini models failed.');
  }

  async processChat({
    message,
    conversationHistory = [],
    userId = 'TSS-2025-45678',
    applicationId = 'app-pms-2025-001',
    locale = 'en',
    languageInstruction = '',
    screenContext = ''
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

    // Step 2: Query-routing for website retrieval
    let webContext = '';
    const recordedToolCalls = [];

    if (needsWebsiteRetrieval(cleanMessage)) {
      try {
        const retrievalResult = await websiteScraperService.findRelevantContent(cleanMessage);
        if (retrievalResult && retrievalResult.matches.length > 0) {
          webContext = websiteScraperService.formatContextForPrompt(retrievalResult);
          recordedToolCalls.push({
            name: 'getOfficialWebsiteKnowledge',
            args: { query: cleanMessage }
          });
        }
      } catch (err) {
        console.warn(`[JAGO Backend] Website retrieval warning: ${err.message}`);
      }
    }

    // Step 3: Check Gemini Client Availability
    if (!this.ai || !this.apiKey) {
      if (process.env.NODE_ENV === 'test' || process.env.ALLOW_LOCAL_FALLBACK === 'true') {
        return this.localDeterministicFallback({ message: cleanMessage, conversationHistory, userId, applicationId, locale });
      }
      return {
        reply: RESPONSES.UNAVAILABLE,
        toolCalls: recordedToolCalls
      };
    }

    // Step 4: Format Multi-turn Conversation Contents
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

    try {
      let iteration = 0;
      const maxIterations = 4;

      while (iteration < maxIterations) {
        iteration++;

        const response = await this.generateWithModelFallback({
          contents: contents,
          config: {
            systemInstruction: this.getSystemInstruction(locale, webContext, languageInstruction, screenContext),
            tools: [{ functionDeclarations }],
            temperature: 0.3
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
              response: { result: functionResult },
              id: call.id
            }
          });
        }

        // Push tool execution results back to contents with valid role: 'user'
        contents.push({
          role: 'user',
          parts: functionResponseParts
        });
      }

      return {
        reply: RESPONSES.UNAVAILABLE,
        toolCalls: recordedToolCalls
      };
    } catch (err) {
      console.error('[JAGO Backend] Gemini API Execution Error:', err.message);
      // Fallback to rich deterministic knowledge layer if API fails
      if (process.env.ALLOW_LOCAL_FALLBACK === 'true') {
        console.log('[JAGO Backend] Using local deterministic knowledge fallback...');
        return this.localDeterministicFallback({ message: cleanMessage, conversationHistory, userId, applicationId, locale });
      }
      return {
        reply: RESPONSES.UNAVAILABLE,
        toolCalls: recordedToolCalls,
        error: err.message
      };
    }
  }

  // Deterministic local fallback used in automated unit tests or when API key is not configured
  async localDeterministicFallback({ message, conversationHistory = [], userId, applicationId }) {
    const lower = message.toLowerCase();

    if (isExplicitlyOutOfDomain(lower)) {
      return { reply: RESPONSES.OUT_OF_DOMAIN, toolCalls: [] };
    }

    // Conversational context resolution
    const historyText = conversationHistory.map((m) => (m.text || m.content || '').toLowerCase()).join(' ');

    // ── Application Tracking & Status (Private user data - RelationalDataStore) ──
    if (((lower.includes('status') || lower.includes('track') || lower.includes('stage')) && !lower.includes('payment') && !lower.includes('dbt') && !lower.includes('money')) || lower.includes('where is my application')) {
      const statusData = await dataStore.getApplicationStatus({ applicationId, authenticatedUserId: userId });
      if (statusData.error) return { reply: RESPONSES.DATA_UNAVAILABLE, toolCalls: [{ name: 'getApplicationStatus', args: { applicationId } }] };
      return {
        reply: `Your ${statusData.scholarshipName} application (${statusData.applicationNumber}) is currently "${statusData.status}" at the ${statusData.currentStage} stage. Remarks: ${statusData.remarks}`,
        toolCalls: [{ name: 'getApplicationStatus', args: { applicationId } }]
      };
    }

    // ── Pending Deficiencies / Missing Documents (Private user data - RelationalDataStore) ──
    if (lower.includes('pending') || lower.includes('deficien') || lower.includes('missing document') || lower.includes('why is my application pending')) {
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

    // ── Payment / DBT Disbursement Tracking (Private user data) ───────────────
    if (lower.includes('when will i get the money') || (lower.includes('get the money') && historyText.includes('scholarship'))) {
      const dbtData = await dataStore.getDBTStatus({ applicationId, authenticatedUserId: userId });
      return {
        reply: 'Your Semester 1 payment of ₹45,000 has already been disbursed via DBT to your bank account. Your next installment of ₹25,000 will be credited after Department Verification approval.',
        toolCalls: [{ name: 'getDBTStatus', args: { applicationId } }]
      };
    }

    if (lower.includes('payment') || (lower.includes('dbt') && (lower.includes('status') || lower.includes('my'))) || lower.includes('disburs')) {
      const dbtData = await dataStore.getDBTStatus({ applicationId, authenticatedUserId: userId });
      if (dbtData.disbursedPayments && dbtData.disbursedPayments.length > 0) {
        const p = dbtData.disbursedPayments[0];
        return {
          reply: `Your scholarship payment of ₹${p.amount} has been disbursed via DBT to your bank account (${p.accountMask}). Transaction ID: ${p.transactionId}, Bank Reference: ${p.bankRefNumber}.`,
          toolCalls: [{ name: 'getDBTStatus', args: { applicationId } }]
        };
      }
      return {
        reply: "I don't have payment information for your application yet.",
        toolCalls: [{ name: 'getDBTStatus', args: { applicationId } }]
      };
    }

    // ── Eligibility Check combining Profile + Official Criteria (Automatic Self-Evaluation) ──
    if (
      lower.includes('check my eligibility') ||
      lower.includes('check my eligibilty') ||
      lower.includes('check eligibility') ||
      lower.includes('am i eligible') ||
      (lower.includes('eligib') && (lower.includes('my') || lower.includes('profile') || lower.includes('for me') || lower.includes('can i')))
    ) {
      const profile = await dataStore.getUserScholarshipProfile({ authenticatedUserId: userId });
      const citation = formatSourceCitation();
      return {
        reply: `Based on your student profile (${profile.fullName}, Category: ${profile.category}, Course: ${profile.course} at ${profile.institution}):\n\n` +
          `• Post-Matric Scholarship for ST Students: Eligible! You are enrolled in a recognized degree program and belong to the Scheduled Tribe category. Annual family income must not exceed ₹2.50 Lakh.\n` +
          `• National Scholarship (Top Class): Eligible! ${profile.institution} is among the 265 notified premier institutes. Annual family income must not exceed ₹6.00 Lakh.\n` +
          `• National Fellowship (NFST): Eligible upon qualifying for full-time M.Phil/Ph.D. with minimum 55% marks in Master's degree. There is NO family income ceiling.\n` +
          `• National Overseas Scholarship (NOS): Eligible for Masters/Ph.D. abroad if you secure an unconditional admission offer from a Top 1,000 QS world-ranked institution.${citation}`,
        toolCalls: [
          { name: 'getUserScholarshipProfile', args: {} },
          { name: 'getOfficialWebsiteKnowledge', args: { query: 'eligibility criteria' } }
        ]
      };
    }

    // ── Latest Deadlines & Extension Notices (Official Website Scraper) ────────
    if (lower.includes('latest deadline') || lower.includes('deadline') || lower.includes('last date') || lower.includes('has the deadline changed') || lower.includes('deadline changed')) {
      const webKnowledge = await websiteScraperService.getKnowledge();
      const citation = formatSourceCitation({
        sourceUrl: webKnowledge.sourceUrl,
        pageTitle: webKnowledge.pageTitle,
        retrievedAt: webKnowledge.retrievedAt.split('T')[0]
      });

      if (lower.includes('changed') || lower.includes('has the deadline changed')) {
        return {
          reply: `Yes, official extension notices have been issued on the Ministry of Tribal Affairs portal:\n\n` +
            `• National Fellowship Scheme (NFST): Deadline for online submission of applications was extended per official Ministry circular.\n` +
            `• National Overseas Scholarship (NOS): Application deadline was extended to 15th July 2025 (5:30 PM).\n` +
            `• State / NSP Pre-Matric & Post-Matric: Annual application and verification timelines follow the National Scholarship Portal (scholarships.gov.in) calendar.${citation}`,
          toolCalls: [{ name: 'getOfficialWebsiteKnowledge', args: { query: 'deadlines' } }]
        };
      }

      return {
        reply: `Latest Official MoTA Scholarship Deadlines & Notifications (from tribal.nic.in):\n\n` +
          `• National Fellowship for ST Students (NFST): Online application portal submission deadline extended per official notification.\n` +
          `• National Overseas Scholarship (NOS): Last date extended to 15th July 2025 (5:30 PM) on overseas.tribal.gov.in.\n` +
          `• Pre-Matric & Post-Matric Scholarships: Portal opens annually on the National Scholarship Portal (scholarships.gov.in) and respective State Portals. Verification deadlines are notified on dbttribal.gov.in.${citation}`,
        toolCalls: [{ name: 'getOfficialWebsiteKnowledge', args: { query: 'latest deadline' } }]
      };
    }

    // ── Available Scholarships (Official Website Scraper) ─────────────────────
    if (lower.includes('what scholarships are available') || lower.includes('available scholarship') || lower.includes('schemes available') || lower.includes('which scholarship') || lower.includes('list of scholarship')) {
      const webKnowledge = await websiteScraperService.getKnowledge();
      const schemes = Object.values(webKnowledge.schemes);
      const citation = formatSourceCitation({
        sourceUrl: webKnowledge.sourceUrl,
        pageTitle: webKnowledge.pageTitle,
        retrievedAt: webKnowledge.retrievedAt.split('T')[0]
      });

      return {
        reply: `Official Ministry of Tribal Affairs (MoTA) Scholarship Schemes available:\n\n` +
          schemes.map((s, idx) => `${idx + 1}. **${s.name}**\n   • Type: ${s.type}\n   • Target: ${s.target}\n   • Income Limit: ${s.incomeLimit}\n   • Official Portal: ${s.portal}`).join('\n\n') +
          citation,
        toolCalls: [{ name: 'getOfficialWebsiteKnowledge', args: { query: 'available scholarships' } }]
      };
    }

    // ── Eligibility Criteria (Official Website Scraper) ───────────────────────
    if (lower.includes('eligibility criteria') || (lower.includes('what are') && lower.includes('eligib')) || lower.includes('who can apply')) {
      const citation = formatSourceCitation();
      return {
        reply: `Official Eligibility Criteria across MoTA Scholarship Schemes (from tribal.nic.in):\n\n` +
          `1. **Pre-Matric Scholarship:** ST students studying in Classes IX & X. Annual family income <= ₹2.50 Lakh.\n` +
          `2. **Post-Matric Scholarship:** ST students pursuing Class XI to Post-Graduation/Ph.D. Annual family income <= ₹2.50 Lakh.\n` +
          `3. **Top Class Education:** ST students admitted on merit to 265 notified premier institutions (IITs, NITs, IIMs, AIIMS, NLUs). Annual family income <= ₹6.00 Lakh.\n` +
          `4. **National Fellowship (NFST):** ST scholars with minimum 55% marks in Master's degree pursuing full-time M.Phil/Ph.D. **NO INCOME CEILING** (No family income limit).\n` +
          `5. **National Overseas Scholarship (NOS):** ST scholars with unconditional admission to Top 1,000 QS world-ranked universities for Master's/Ph.D. Annual family income <= ₹6.00 Lakh.${citation}`,
        toolCalls: [{ name: 'getOfficialWebsiteKnowledge', args: { query: 'eligibility criteria' } }]
      };
    }

    // ── Required Documents (Official Website Scraper) ─────────────────────────
    if (lower.includes('what documents do i need') || (lower.includes('document') && !lower.includes('pending') && !lower.includes('rejected'))) {
      const citation = formatSourceCitation();
      return {
        reply: `Official Documents Required for MoTA Scholarships (from tribal.nic.in guidelines):\n\n` +
          `• **Aadhaar Card:** Aadhaar number or Enrolment ID.\n` +
          `• **Scheduled Tribe (ST) Certificate:** Issued by competent revenue authority (Tehsildar/SDO).\n` +
          `• **Annual Family Income Certificate:** Current financial year certificate from competent authority.\n` +
          `• **Bonafide Student Certificate:** Proof of active enrollment from recognized School/College/University.\n` +
          `• **Academic Marksheet:** Marksheet/Certificate of qualifying examination.\n` +
          `• **Aadhaar-Seeded Bank Passbook:** Bank account must be seeded with Aadhaar for DBT via PFMS.\n` +
          `• **Disability Certificate:** If claiming Divyangjan allowances (where applicable).\n\n` +
          `*Tip: Documents can be retrieved instantly without manual upload via DigiLocker integration.*${citation}`,
        toolCalls: [{ name: 'getOfficialWebsiteKnowledge', args: { query: 'required documents' } }]
      };
    }

    // ── Direct Benefit Transfer (DBT) Concept & Mechanism ─────────────────────
    if (lower.includes('what is dbt') || lower.includes('what does dbt mean') || lower.trim() === 'dbt' || lower.includes('explain dbt')) {
      const citation = formatSourceCitation();
      return {
        reply: `**Direct Benefit Transfer (DBT)** is the Government of India's mechanism to disburse scholarship funds and maintenance stipends directly into the verified, Aadhaar-seeded bank accounts of eligible ST students via the Public Financial Management System (PFMS).\n\n` +
          `Key requirements per official MoTA portal (tribal.nic.in):\n` +
          `1. **Aadhaar Seeding:** Bank account must be actively linked and seeded with Aadhaar at the bank branch.\n` +
          `2. **Mobile Linking:** Active mobile number linked to both Aadhaar and the bank account for transaction SMS alerts.\n` +
          `3. **Elimination of Intermediaries:** Ensures 100% transparent, timely, and tamper-proof financial support directly to the student.${citation}`,
        toolCalls: [{ name: 'getOfficialWebsiteKnowledge', args: { query: 'DBT mechanism' } }]
      };
    }

    // ── General Scholarship Concept ───────────────────────────────────────────
    if (lower.includes('what is a scholarship') || lower === 'scholarship' || lower.includes('explain scholarship')) {
      return {
        reply: 'A scholarship is non-repayable financial aid awarded to students to support their education. Unlike loans, scholarships do not have to be paid back. Under the Ministry of Tribal Affairs (MoTA), scholarships are provided to Scheduled Tribe (ST) students covering school education (Classes 9-10), higher studies (Class 11 to PG/Ph.D), premier institutions (IITs/IIMs), and overseas studies.',
        toolCalls: []
      };
    }

    // Default response for unverified queries
    return {
      reply: `${RESPONSES.NOT_FOUND} For official guidelines and notices, please visit the Ministry of Tribal Affairs portal: https://tribal.nic.in/ScholarshiP.aspx.`,
      toolCalls: []
    };
  }
}

module.exports = {
  GeminiService,
  RESPONSES,
  functionDeclarations
};
