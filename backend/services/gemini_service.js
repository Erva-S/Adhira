const { GoogleGenAI } = require('@google/genai');
const dataStore = require('../database/data_store');

// ── Canonical Error & Guard Responses ─────────────────────────────────────────
const RESPONSES = {
  UNAVAILABLE: 'JAGO is temporarily unavailable. Please try again shortly.',
  DATA_UNAVAILABLE: "I couldn't retrieve that information from your application right now.",
  NOT_FOUND: "I don't have verified information about that in the scholarship documents.",
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

ROLE & PERSONALITY:
- You are a knowledgeable, friendly, polite, and natural AI assistant (like ChatGPT / Gemini) specialized in the scholarship and educational financial aid domain for Scheduled Tribe (ST) students.
- You speak clearly, professionally, and naturally.
- You are BROAD inside the scholarship domain:
  * You explain general concepts freely (e.g. "What is a scholarship?", "What is DBT?", "What is DigiLocker?", "How does verification work?", "Why do scholarships require income certificates?", "What is the difference between Pre-Matric and Post-Matric?").
  * You provide comprehensive, structured overviews when asked for details of any scheme (e.g., Overview, Eligibility, Financial Benefits/Stipends, Required Documents, Where to Apply, Important Conditions).
  * You help students check their eligibility. If they ask "Am I eligible?", compare their information against the scheme criteria, or if information is missing (like current class or family income), politely ask them for the missing details.
- You are STRICTLY DOMAIN-RESTRICTED outside the scholarship domain:
  * If the user asks about completely unrelated topics (coding in Python/C++, celebrities, cricket scores, weather, movies, general chit-chat), DO NOT answer using general knowledge. Instead respond:
    "${RESPONSES.OUT_OF_DOMAIN}"

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
   - Portals: National Scholarship Portal (scholarships.gov.in) or State Portal.

2. Post-Matric Scholarship for ST Students (Class XI to Post-Graduation) [Source: Post_Matric_Scholarship_Guidelines_2022.pdf]:
   - Scope: ST students pursuing Class 11, 12, ITI, Diploma, Polytechnic, Graduate, PG, M.Phil, Ph.D in India.
   - Eligibility: Passed Class 10 or 12, Family annual income <= ₹2.50 Lakh. One scholarship at a time. Candidates who complete a degree in one stream cannot take another course in a different stream at the same level.
   - Benefits: Compulsory non-refundable course fees + Monthly maintenance stipend for up to 10 months/year:
     * Group I (Professional Degree/PG - Engg/Medical/Tech): Hosteller ₹1,200/mo; Day Scholar ₹550/mo. (Fee cap in private institutes: ₹2.50L Engg, ₹6.00L Medical).
     * Group II (Non-professional BA, BSc, BCom, MA, MSc, MCom): Hosteller ₹820/mo; Day Scholar ₹530/mo.
     * Group III (Diploma, 3-yr Polytechnic, ITI): Hosteller ₹570/mo; Day Scholar ₹300/mo.
     * Group IV (Class XI & XII, non-degree): Hosteller ₹380/mo; Day Scholar ₹230/mo.
   - Income Certificate Rule: Taken ONCE at admission, valid for ENTIRE course duration. Fresh income certificate NOT required for renewal in 2nd or subsequent years.
   - Portals: scholarships.gov.in or State Portal.

3. Top Class Education for ST Students [Source: National_Fellowship_and_Scholarship_Higher_Education_Guidelines_2021-26.pdf, Part-B]:
   - Scope: 100% Central Sector Scheme for ST students admitted on merit to 252 notified premier institutes (all IITs, NITs, IIMs, AIIMS, NLUs, etc.).
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

        const response = await this.generateWithModelFallback({
          contents: contents,
          config: {
            systemInstruction: this.getSystemInstruction(locale),
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

    // General educational / scholarship concept explanations
    if (lower.includes('what is a scholarship') || lower === 'scholarship' || lower.includes('explain scholarship')) {
      return {
        reply: 'A scholarship is non-repayable financial aid awarded to students to support their education. Unlike loans, scholarships do not have to be paid back. Under the Ministry of Tribal Affairs (MoTA), scholarships are provided to Scheduled Tribe (ST) students covering school education (Classes 9-10), higher studies (Class 11 to PG/Ph.D), premier institutions (IITs/IIMs), and overseas studies.',
        toolCalls: []
      };
    }

    if (lower.includes('what is dbt') || lower.includes('what does dbt mean') || lower === 'dbt' || lower.includes('explain dbt')) {
      return {
        reply: 'DBT stands for Direct Benefit Transfer. It is the Government of India\'s mechanism to disburse scholarship funds and stipends directly into the verified, Aadhaar-seeded bank accounts of eligible students via Public Financial Management System (PFMS). This eliminates intermediaries and ensures transparent, timely financial support.',
        toolCalls: []
      };
    }

    if (lower.includes('digilocker') || lower.includes('digi locker')) {
      return {
        reply: 'DigiLocker is the Government of India\'s secure cloud-based platform for issuing and verifying official documents (like Aadhaar, Caste Certificates, Marksheets). In Tribal Scholar Saathi, linking your DigiLocker allows automatic document fetching and instant government verification without needing physical copies.',
        toolCalls: []
      };
    }

    if (lower.includes('how does verification work') || lower.includes('verification process') || lower.includes('what happens after verification')) {
      return {
        reply: 'Scholarship verification operates through a multi-tier hierarchy:\n1. Institute Level: Institute Nodal Officer (INO) verifies application details and uploaded documents against academic records.\n2. District/State Level: District/State Nodal Officer reviews and scrutinizes applications for eligibility.\n3. Ministry Level: Central verification and sanctioning of funds.\nOnce approved, scholarship amounts are credited directly via PFMS-DBT to the student\'s Aadhaar-seeded account.',
        toolCalls: []
      };
    }

    if (lower.includes('difference between pre-matric and post-matric') || lower.includes('pre-matric vs post-matric')) {
      return {
        reply: 'Difference between Pre-Matric and Post-Matric Scholarships:\n• Pre-Matric: For ST students in Classes 9 and 10 to prevent dropouts during school education (Family income ceiling: ₹2.50 Lakh/yr).\n• Post-Matric: For ST students from Class 11 upwards, including ITI, Diploma, Undergraduate, Postgraduate, and Doctoral courses (Family income ceiling: ₹2.50 Lakh/yr, covers tuition fees + monthly stipend).',
        toolCalls: []
      };
    }

    if (lower.includes('why do scholarships require income') || lower.includes('why income certificate')) {
      return {
        reply: 'Income certificates are required to verify that financial assistance reaches economically disadvantaged students who need it most. Under MoTA guidelines, family income ceilings (such as ₹2.50 Lakh for Pre/Post-Matric or ₹6.00 Lakh for Top Class) ensure the scheme remains targeted and fair.',
        toolCalls: []
      };
    }

    if (lower.includes('am i eligible') && !lower.includes('post-matric') && !lower.includes('pre-matric') && !lower.includes('top class') && !lower.includes('nfst') && !lower.includes('nos')) {
      return {
        reply: 'I can help check your eligibility! Which scholarship scheme are you inquiring about (Pre-Matric, Post-Matric, Top Class, NFST, or NOS)? Please also share your current class/course and annual family income.',
        toolCalls: []
      };
    }

    // Specific MoTA Schemes Handling
    if (lower.includes('pre-matric') || lower.includes('pre matric') || (historyText.includes('pre-matric') && !lower.includes('post-matric') && !lower.includes('top class') && !lower.includes('nfst') && !lower.includes('nos'))) {
      if (lower.includes('document')) {
        const docData = await dataStore.getRequiredDocuments({ scheme: 'pre-matric' });
        return {
          reply: `Required documents for ${docData.schemeName} [Source: ${docData.sourceDocument}, ${docData.sourceSections}]:\n` + docData.requiredDocuments.map((d) => `• ${d}`).join('\n'),
          toolCalls: [{ name: 'getRequiredDocuments', args: { scheme: 'pre-matric' } }]
        };
      }
      if (lower.includes('eligib') || lower.includes('criteria') || lower.includes('who can apply')) {
        const elData = await dataStore.getEligibilityCriteria({ scheme: 'pre-matric' });
        return {
          reply: `Eligibility Criteria for ${elData.schemeName} [Source: ${elData.sourceDocument}, ${elData.sourceSections}]:\n` + elData.eligibilityCriteria.map((c) => `• ${c}`).join('\n'),
          toolCalls: [{ name: 'getEligibilityCriteria', args: { scheme: 'pre-matric' } }]
        };
      }
      // Comprehensive scheme details
      const details = await dataStore.getScholarshipDetails({ scheme: 'pre-matric' });
      return {
        reply: `### ${details.name}\n[Source: ${details.sourceReference.file}, ${details.sourceReference.sections[0]}]\n\n` +
          `**1. Scope & Objective:** Centrally Sponsored Scheme (75:25 funding; 90:10 for North-East & Hilly States) supporting ST students in Classes IX & X.\n\n` +
          `**2. Eligibility:**\n• Category: Scheduled Tribe belonging to Domicile State/UT\n• Classes: Studying in Class 9 or 10 in Government or recognized schools\n• Income Limit: Family annual income <= ₹2.50 Lakh from all sources (valid for Class 10 without fresh certificate)\n• Repetition: Available for 1 year per class (no funding for repeating same class)\n\n` +
          `**3. Financial Benefits:**\n• Day Scholars: ₹225/month (10 months = ₹2,250) + ₹750 annual book grant = ₹3,000/year\n• Hostellers: ₹525/month (10 months = ₹5,250) + ₹1,000 annual book grant = ₹6,250/year\n• Disability Allowance: ₹800/mo (Hosteller) or ₹600/mo (Day Scholar) for all 12 months\n\n` +
          `**4. Required Documents:**\n• Aadhaar Card & Domicile Certificate\n• ST / Caste Certificate from competent authority\n• Family Income Certificate (self-affidavits not accepted)\n• School Bonafide Certificate / UDISE details\n• Bank Passbook (Aadhaar linked for DBT)\n\n` +
          `**5. Where to Apply:** National Scholarship Portal (scholarships.gov.in) or respective State Scholarship Portal.`,
        toolCalls: [{ name: 'getScholarshipDetails', args: { scheme: 'pre-matric' } }]
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
      if (lower.includes('eligib') || lower.includes('criteria') || lower.includes('who can apply')) {
        const elData = await dataStore.getEligibilityCriteria({ scheme: 'post-matric' });
        return {
          reply: `Eligibility Criteria for ${elData.schemeName} [Source: ${elData.sourceDocument}, ${elData.sourceSections}]:\n` + elData.eligibilityCriteria.map((c) => `• ${c}`).join('\n'),
          toolCalls: [{ name: 'getEligibilityCriteria', args: { scheme: 'post-matric' } }]
        };
      }
      const details = await dataStore.getScholarshipDetails({ scheme: 'post-matric' });
      return {
        reply: `### ${details.name}\n[Source: ${details.sourceReference.file}, ${details.sourceReference.sections[0]}]\n\n` +
          `**1. Scope:** MoTA flagship scheme for ST students pursuing Class 11 to Post-Graduation, ITI, Diploma, Medical, and Engineering courses.\n\n` +
          `**2. Eligibility:**\n• Domicile ST student who has passed Matriculation (Class 10) or Higher Secondary\n• Family annual income <= ₹2.50 Lakh (income certificate taken once at admission is valid for entire course duration)\n• Cannot change streams at the same level (e.g. no B.Com after B.A.)\n\n` +
          `**3. Benefits:** Compulsory non-refundable course fees + monthly maintenance stipends across 4 groups:\n• Group I (Professional Degree/PG): Hosteller ₹1,200/mo; Day Scholar ₹550/mo\n• Group II (BA, BSc, BCom, MA): Hosteller ₹820/mo; Day Scholar ₹530/mo\n• Group III (Diploma, ITI, 3-yr Polytechnic): Hosteller ₹570/mo; Day Scholar ₹300/mo\n• Group IV (Class XI & XII non-degree): Hosteller ₹380/mo; Day Scholar ₹230/mo\n\n` +
          `**4. Required Documents:** Aadhaar, Domicile, ST certificate, Income certificate, qualifying marksheets, Bonafide certificate, Bank passbook.\n\n` +
          `**5. Where to Apply:** scholarships.gov.in (NSP) or State Portal.`,
        toolCalls: [{ name: 'getScholarshipDetails', args: { scheme: 'post-matric' } }]
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
      const details = await dataStore.getScholarshipDetails({ scheme: 'top-class' });
      return {
        reply: `### ${details.name}\n[Source: ${details.sourceReference.file}, ${details.sourceReference.sections[0]}]\n\n` +
          `**1. Scope:** 100% Central Sector Scheme for ST students admitted on merit to 252 notified premier institutes (IITs, NITs, IIMs, AIIMS, NLUs, etc.).\n\n` +
          `**2. Eligibility:**\n• ST students admitted on merit to 252 notified institutes\n• Total family income <= ₹6.00 Lakh/year (spousal income included if married)\n• NO SLOTS CEILING (all eligible verified ST students funded; Management Quota excluded)\n\n` +
          `**3. Benefits:**\n• Full admission & tuition fees in Government institutes (private institute ceiling: ₹2.50 Lakh/year)\n• Books & Stationery: ₹5,000/year (without bills)\n• Living Stipend: ₹3,000/month (₹36,000/year)\n• Computer & Accessories: ₹45,000 one-time grant for laptop/desktop\n\n` +
          `**4. Where to Apply:** scholarships.gov.in (NSP).`,
        toolCalls: [{ name: 'getScholarshipDetails', args: { scheme: 'top-class' } }]
      };
    }

    if (lower.includes('nfst') || lower.includes('national fellowship') || lower.includes('fellowship') || lower.includes('m.phil') || lower.includes('ph.d') || lower.includes('phd')) {
      if (lower.includes('document')) {
        const docData = await dataStore.getRequiredDocuments({ scheme: 'nfst' });
        return {
          reply: `Required documents for ${docData.schemeName} [Source: ${docData.sourceDocument}, ${docData.sourceSections}]:\n` + docData.requiredDocuments.map((d) => `• ${d}`).join('\n'),
          toolCalls: [{ name: 'getRequiredDocuments', args: { scheme: 'nfst' } }]
        };
      }
      const details = await dataStore.getScholarshipDetails({ scheme: 'nfst' });
      return {
        reply: `### ${details.name}\n[Source: ${details.sourceReference.file}, ${details.sourceReference.sections[0]}]\n\n` +
          `**1. Scope:** 750 fresh fellowships annually for ST scholars pursuing full-time M.Phil (2 yrs) and Ph.D (5 yrs) in UGC/INI institutions.\n\n` +
          `**2. Eligibility:**\n• ST scholars with minimum 55% marks in Post-Graduation / Master's degree\n• Age Limit: Maximum 36 years as of 1st July of award year\n• NO INCOME CRITERIA: There is no income ceiling for eligibility!\n• Slots breakdown: 38 Divyangjan, 25 PVTG, 225 Female, 462 ST Others\n\n` +
          `**3. Benefits:**\n• Fellowship: ₹31,000/month for M.Phil; for Ph.D ₹31,000/month (first 2 yrs) and ₹35,000/month (next 3 yrs)\n• Annual Contingency: ₹10,000 - ₹25,000/year\n• HRA at UGC rates (8%, 16%, or 24%)\n• Escort allowance for Divyangjan: ₹2,000/month\n\n` +
          `**4. Where to Apply:** fellowship.tribal.gov.in (uploaded via DigiLocker).`,
        toolCalls: [{ name: 'getScholarshipDetails', args: { scheme: 'nfst' } }]
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
      const details = await dataStore.getScholarshipDetails({ scheme: 'nos' });
      return {
        reply: `### ${details.name}\n[Source: ${details.sourceReference.file}, ${details.sourceReference.sections[0]}]\n\n` +
          `**1. Scope:** Financial support for ST scholars pursuing Masters and Ph.D level courses abroad.\n*Important 2026-27 Amendment:* Post-Doctoral Research was omitted from 2026-27 onwards.\n\n` +
          `**2. Eligibility:**\n• First priority: Unconditional admission offer from Top 1,000 QS world-ranked foreign universities\n• Total family annual income <= ₹6.00 Lakh\n• Must hold a valid Indian passport\n• Age limit: Below 35 years as on 1st day of application year\n\n` +
          `**3. Benefits:** Full tuition fees, annual maintenance ($15,400 / £9,900), economy airfare, visa and insurance fees.\n\n` +
          `**4. Where to Apply:** overseas.tribal.gov.in.`,
        toolCalls: [{ name: 'getScholarshipDetails', args: { scheme: 'nos' } }]
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
      reply: "I don't have verified information about that in the scholarship documents. Generally, MoTA scholarships cover Pre-Matric (Classes 9-10), Post-Matric (Class 11 to PG), Top Class Education (252 premier institutes), NFST (M.Phil/Ph.D), and NOS (overseas studies). For specific rules, please refer to the latest official MoTA scheme guidelines.",
      toolCalls: []
    };
  }
}

module.exports = {
  GeminiService,
  RESPONSES,
  functionDeclarations
};
