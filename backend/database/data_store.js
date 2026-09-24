const fs = require('fs');
const path = require('path');

// Load trusted scholarship knowledge layer extracted from official PDFs
const knowledgePath = path.join(__dirname, '..', 'knowledge', 'trusted_knowledge.json');
const knowledgeData = JSON.parse(fs.readFileSync(knowledgePath, 'utf8'));

// ── In-Memory Database Mirroring PostgreSQL Schema ───────────────────────────
const users = {
  'TSS-2025-45678': {
    id: 'TSS-2025-45678',
    authUserId: 'auth-user-001',
    fullName: 'Rajesh Soren',
    fatherName: 'Manoj Soren',
    motherName: 'Sunita Soren',
    gender: 'Male',
    category: 'ST',
    tribeName: 'Santal',
    isPVTG: false,
    stCertificateNumber: 'SC/OD/2023/12345',
    stCertificateVerified: true,
    mobileNumber: '9876543210',
    email: 'rajesh.soren@nitrkl.ac.in',
    state: 'Odisha',
    district: 'Mayurbhanj',
    address: 'Plot 42, Baripada',
    pinCode: '757001',
    educationLevel: 'Undergraduate',
    currentCourse: 'B.Tech Computer Science',
    currentYear: '2nd Year',
    institutionName: 'NIT Rourkela',
    institutionId: 'AISHE-U-0355',
    isPremierInstitute: true,
    bankAccountNumber: '****7890',
    ifscCode: 'SBIN0001234',
    bankName: 'State Bank of India',
    isAadhaarSeeded: true,
    profileCompletionPercent: 0.72
  }
};

const applications = [
  {
    id: 'app-pms-2025-001',
    applicationNumber: 'PMS-2025-78432',
    userId: 'TSS-2025-45678',
    scholarshipId: 'sch-post-matric',
    scholarshipName: 'Post-Matric Scholarship for ST Students',
    scholarshipType: 'POST_MATRIC',
    academicYear: '2025-26',
    status: 'under_review',
    statusLabel: 'Under Review',
    currentStage: 'department_verification',
    currentStageLabel: 'Department Verification',
    appliedDate: '2025-08-15',
    requestedAmount: 70000,
    sanctionedAmount: 70000,
    currency: 'INR',
    remarks: 'Application verified by NIT Rourkela Dean Academics. State Tribal Welfare Department verification currently underway.',
    institutionVerificationStatus: 'verified',
    departmentVerificationStatus: 'in_progress'
  }
];

const pendingActions = [
  {
    id: 'act-001',
    applicationId: 'app-pms-2025-001',
    userId: 'TSS-2025-45678',
    title: 'Update Income Certificate',
    description: 'The uploaded income certificate is dated AY 2023-24. Please re-upload a valid revenue department certificate for current AY 2025-26.',
    actionType: 'income_clarification',
    status: 'open',
    dueDate: '2025-10-15',
    isOpen: true
  }
];

const documents = [
  {
    id: 'doc-001',
    userId: 'TSS-2025-45678',
    name: 'Aadhaar Card',
    category: 'identity',
    status: 'verified',
    isFromDigiLocker: true
  },
  {
    id: 'doc-002',
    userId: 'TSS-2025-45678',
    name: 'ST Certificate',
    category: 'caste',
    status: 'verified',
    isFromDigiLocker: false
  },
  {
    id: 'doc-003',
    userId: 'TSS-2025-45678',
    name: 'Class 12 Marksheet',
    category: 'academic',
    status: 'verified',
    isFromDigiLocker: true
  },
  {
    id: 'doc-004',
    userId: 'TSS-2025-45678',
    name: 'College Enrollment Certificate',
    category: 'academic',
    status: 'verified',
    isFromDigiLocker: false
  },
  {
    id: 'doc-005',
    userId: 'TSS-2025-45678',
    name: 'Income Certificate',
    category: 'income',
    status: 'rejected',
    rejectionReason: 'Certificate expired (AY 2023-24). Please upload valid certificate for AY 2025-26.',
    isFromDigiLocker: false
  },
  {
    id: 'doc-006',
    userId: 'TSS-2025-45678',
    name: 'Bank Passbook Copy',
    category: 'bank',
    status: 'uploaded',
    isFromDigiLocker: false
  }
];

const payments = [
  {
    id: 'pay-001',
    applicationId: 'app-pms-2025-001',
    userId: 'TSS-2025-45678',
    scholarshipName: 'Post-Matric Scholarship for ST Students',
    status: 'disbursed',
    dbtStatus: 'credited',
    amount: 45000,
    currency: 'INR',
    installmentLabel: 'Tuition Fee — Semester 1 & Maintenance',
    sanctionedDate: '2025-08-25',
    disbursedDate: '2025-09-10',
    transactionId: 'TXN-PFMS-78432-001',
    bankRefNumber: 'SBI-UTR-99882211',
    referenceNumber: 'PFMS/MOTA/2025/44321',
    accountMask: '****7890'
  },
  {
    id: 'pay-002',
    applicationId: 'app-pms-2025-001',
    userId: 'TSS-2025-45678',
    scholarshipName: 'Post-Matric Scholarship for ST Students',
    status: 'pending',
    dbtStatus: 'payment_processing',
    amount: 25000,
    currency: 'INR',
    installmentLabel: 'Tuition Fee — Semester 2',
    sanctionedDate: null,
    disbursedDate: null,
    accountMask: '****7890'
  }
];

// Helper to normalize scheme names for lookup
function normalizeScheme(input) {
  if (!input) return null;
  const s = input.toLowerCase().replace(/[\-_]/g, ' ');
  if (s.includes('pre') && s.includes('matric')) return 'sch-pre-matric';
  if (s.includes('post') && s.includes('matric')) return 'sch-post-matric';
  if (s.includes('top class') || s.includes('higher education') || s.includes('premier')) return 'sch-top-class';
  if (s.includes('nfst') || s.includes('fellowship') || s.includes('mphil') || s.includes('phd')) return 'sch-nfst';
  if (s.includes('nos') || s.includes('overseas') || s.includes('abroad')) return 'sch-nos';
  return null;
}

// ── Required JAGO Backend Tools / Functions ─────────────────────────────────

function formatEligibilityCriteria(eligibility) {
  if (!eligibility) return [];
  if (Array.isArray(eligibility.generalCriteria)) return eligibility.generalCriteria;
  const list = [];
  if (eligibility.caste) list.push(eligibility.caste);
  if (eligibility.academics) list.push(eligibility.academics);
  if (eligibility.qualification) list.push(eligibility.qualification);
  if (eligibility.incomeCeiling) list.push(`Income Ceiling: ${eligibility.incomeCeiling}`);
  if (eligibility.incomeCriteria) list.push(`Income Criteria: ${eligibility.incomeCriteria}`);
  if (eligibility.instituteCoverage) list.push(eligibility.instituteCoverage);
  if (eligibility.institutesCovered) list.push(eligibility.institutesCovered);
  if (eligibility.slotsRule) list.push(eligibility.slotsRule);
  if (eligibility.ageLimit) list.push(`Age Limit: ${eligibility.ageLimit}`);
  if (eligibility.priorityRule) list.push(eligibility.priorityRule);
  if (eligibility.bankAccount) list.push(eligibility.bankAccount);
  if (eligibility.otherScholarships) list.push(eligibility.otherScholarships);
  return list;
}

const dataStore = {
  // 1. getScholarshipSchemes()
  getScholarshipSchemes: async () => {
    return knowledgeData.schemes.map((s) => ({
      id: s.id,
      code: s.code,
      name: s.name,
      schemeType: s.schemeType,
      targetAudience: s.targetAudience,
      purpose: s.purpose,
      duration: s.duration || 'Entire Course Duration',
      sourceDocument: s.sourceReference.file,
      sourceSections: s.sourceReference.sections
    }));
  },

  // 2. getScholarshipDetails(scheme)
  getScholarshipDetails: async ({ scheme }) => {
    const schemeId = normalizeScheme(scheme);
    if (!schemeId) {
      return {
        error: `Scheme '${scheme}' is not found in the verified MoTA scholarship database.`,
        verified: false
      };
    }
    const found = knowledgeData.schemes.find((s) => s.id === schemeId);
    return {
      ...found,
      eligibilityCriteria: formatEligibilityCriteria(found.eligibility),
      verified: true
    };
  },

  // 3. getEligibilityCriteria(scheme)
  getEligibilityCriteria: async ({ scheme }) => {
    const schemeId = normalizeScheme(scheme);
    if (!schemeId) {
      return {
        error: `Scheme '${scheme}' is not recognized. Only official MoTA schemes (Pre-Matric, Post-Matric, Top Class, NFST, NOS) are supported.`,
        verified: false
      };
    }
    const found = knowledgeData.schemes.find((s) => s.id === schemeId);
    return {
      schemeName: found.name,
      sourceDocument: found.sourceReference.file,
      sourceSections: found.sourceReference.sections,
      eligibilityDetails: found.eligibility,
      eligibilityCriteria: formatEligibilityCriteria(found.eligibility),
      verified: true
    };
  },

  // 4. getRequiredDocuments(scheme)
  getRequiredDocuments: async ({ scheme }) => {
    const schemeId = normalizeScheme(scheme);
    if (!schemeId) {
      return {
        error: `Scheme '${scheme}' is not found in official records.`,
        verified: false
      };
    }
    const found = knowledgeData.schemes.find((s) => s.id === schemeId);
    return {
      schemeName: found.name,
      sourceDocument: found.sourceReference.file,
      sourceSections: found.sourceReference.sections,
      requiredDocuments: found.requiredDocuments,
      verified: true
    };
  },

  // 5. getApplicationStatus(applicationId, userId)
  getApplicationStatus: async ({ applicationId, userId, authenticatedUserId }) => {
    const effectiveUserId = authenticatedUserId || userId;
    let app = null;

    if (applicationId) {
      app = applications.find((a) => a.id === applicationId || a.applicationNumber === applicationId);
      if (app && app.userId !== effectiveUserId) {
        return {
          error: 'Access denied: You are only authorized to view your own application status.',
          verified: false
        };
      }
    } else if (effectiveUserId) {
      app = applications.find((a) => a.userId === effectiveUserId);
    }

    if (!app) {
      return {
        error: 'No application record found for this user/id in the scholarship database.',
        verified: false
      };
    }

    return {
      applicationId: app.id,
      applicationNumber: app.applicationNumber,
      scholarshipName: app.scholarshipName,
      status: app.statusLabel,
      currentStage: app.currentStageLabel,
      appliedDate: app.appliedDate,
      requestedAmount: app.requestedAmount,
      sanctionedAmount: app.sanctionedAmount,
      remarks: app.remarks,
      verified: true
    };
  },

  // 6. getPendingActions(applicationId, userId)
  getPendingActions: async ({ applicationId, userId, authenticatedUserId }) => {
    const effectiveUserId = authenticatedUserId || userId;
    const actions = pendingActions.filter((a) => {
      if (applicationId && a.applicationId !== applicationId) return false;
      if (effectiveUserId && a.userId !== effectiveUserId) return false;
      return a.isOpen;
    });

    return {
      userId: effectiveUserId,
      openActionsCount: actions.length,
      pendingActions: actions.map((a) => ({
        id: a.id,
        title: a.title,
        description: a.description,
        actionType: a.actionType,
        dueDate: a.dueDate
      })),
      verified: true
    };
  },

  // 7. getDeficiencies(applicationId, userId)
  getDeficiencies: async ({ applicationId, userId, authenticatedUserId }) => {
    const effectiveUserId = authenticatedUserId || userId;
    const userDocs = documents.filter((d) => d.userId === effectiveUserId);
    const rejectedDocs = userDocs.filter((d) => d.status === 'rejected');
    const actions = pendingActions.filter((a) => a.userId === effectiveUserId && a.isOpen);

    return {
      userId: effectiveUserId,
      hasDeficiencies: rejectedDocs.length > 0 || actions.length > 0,
      rejectedDocuments: rejectedDocs.map((d) => ({
        name: d.name,
        category: d.category,
        rejectionReason: d.rejectionReason
      })),
      openActions: actions.map((a) => ({
        title: a.title,
        description: a.description,
        dueDate: a.dueDate
      })),
      verified: true
    };
  },

  // 8. getDBTStatus(applicationId, userId)
  getDBTStatus: async ({ applicationId, userId, authenticatedUserId }) => {
    const effectiveUserId = authenticatedUserId || userId;
    const userPayments = payments.filter((p) => {
      if (applicationId && p.applicationId !== applicationId) return false;
      if (effectiveUserId && p.userId !== effectiveUserId) return false;
      return true;
    });

    if (userPayments.length === 0) {
      return {
        userId: effectiveUserId,
        hasPayments: false,
        message: 'No payment or DBT record found for this application yet.',
        verified: true
      };
    }

    const disbursed = userPayments.filter((p) => p.status === 'disbursed');
    const pending = userPayments.filter((p) => p.status !== 'disbursed');

    return {
      userId: effectiveUserId,
      hasPayments: true,
      disbursedPayments: disbursed.map((p) => ({
        amount: p.amount,
        currency: p.currency,
        installment: p.installmentLabel,
        dbtStatus: p.dbtStatus,
        transactionId: p.transactionId,
        bankRefNumber: p.bankRefNumber,
        disbursedDate: p.disbursedDate,
        accountMask: p.accountMask
      })),
      pendingPayments: pending.map((p) => ({
        amount: p.amount,
        currency: p.currency,
        installment: p.installmentLabel,
        dbtStatus: p.dbtStatus,
        accountMask: p.accountMask
      })),
      verified: true
    };
  },

  // 9. getUserScholarshipProfile(userId)
  getUserScholarshipProfile: async ({ userId, authenticatedUserId }) => {
    const effectiveUserId = authenticatedUserId || userId;
    const user = users[effectiveUserId];
    if (!user) {
      return {
        error: `User profile with id '${effectiveUserId}' not found.`,
        verified: false
      };
    }

    return {
      userId: user.id,
      fullName: user.fullName,
      category: user.category,
      tribeName: user.tribeName,
      isPVTG: user.isPVTG,
      stCertificateVerified: user.stCertificateVerified,
      course: user.currentCourse,
      currentYear: user.currentYear,
      institution: user.institutionName,
      isPremierInstitute: user.isPremierInstitute,
      state: user.state,
      bankAccountSeededWithAadhaar: user.isAadhaarSeeded,
      verified: true
    };
  },

  // Helper for direct lookup
  getUser: (userId) => users[userId] || null,
  getApplicationsForUser: (userId) => applications.filter((a) => a.userId === userId)
};

module.exports = dataStore;
