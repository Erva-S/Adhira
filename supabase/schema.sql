-- ============================================================================
-- MoTA Scholarship Application — Tribal Scholar Saathi
-- PostgreSQL / Supabase Relational Database Schema with Row Level Security (RLS)
-- ============================================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ----------------------------------------------------------------------------
-- 1. USERS (Student Profiles)
-- Maps to Supabase auth.users via auth_user_id
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    auth_user_id UUID UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE,
    mobile_number VARCHAR(15) NOT NULL UNIQUE,
    full_name VARCHAR(150) NOT NULL,
    email VARCHAR(255),
    father_name VARCHAR(150),
    mother_name VARCHAR(150),
    date_of_birth DATE,
    gender VARCHAR(20),
    category VARCHAR(50) DEFAULT 'ST',
    tribe_name VARCHAR(100),
    is_pvtg BOOLEAN DEFAULT FALSE,
    st_certificate_number VARCHAR(100),
    aadhaar_masked VARCHAR(20),
    state VARCHAR(100),
    district VARCHAR(100),
    address TEXT,
    pin_code VARCHAR(10),
    education_level VARCHAR(50),
    institution_name VARCHAR(200),
    institution_id VARCHAR(50),
    course VARCHAR(150),
    year_of_study VARCHAR(50),
    bank_name VARCHAR(150),
    bank_account_number VARCHAR(50),
    ifsc_code VARCHAR(20),
    profile_completion_percent NUMERIC(5,2) DEFAULT 0.00,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_users_mobile ON public.users(mobile_number);
CREATE INDEX IF NOT EXISTS idx_users_auth_id ON public.users(auth_user_id);

-- ----------------------------------------------------------------------------
-- 2. SCHOLARSHIPS (Master Data for 5 MoTA Schemes)
-- Public read-only for authenticated students, writable only by admin
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.scholarships (
    id VARCHAR(50) PRIMARY KEY,
    type VARCHAR(50) NOT NULL UNIQUE,
    name VARCHAR(255) NOT NULL,
    short_code VARCHAR(20) NOT NULL,
    tagline TEXT,
    description TEXT NOT NULL,
    detailed_description TEXT,
    max_amount NUMERIC(12, 2),
    duration VARCHAR(50),
    eligibility_criteria TEXT[],
    required_documents TEXT[],
    application_start_date DATE,
    application_end_date DATE,
    portal_url TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ----------------------------------------------------------------------------
-- 3. APPLICATIONS (Scholarship Applications by Students)
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.applications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    application_number VARCHAR(50) NOT NULL UNIQUE,
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    scholarship_id VARCHAR(50) NOT NULL REFERENCES public.scholarships(id) ON DELETE RESTRICT,
    academic_year VARCHAR(20) NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'Submitted',
    current_stage VARCHAR(50) NOT NULL DEFAULT 'Application',
    requested_amount NUMERIC(12, 2),
    sanctioned_amount NUMERIC(12, 2),
    remarks TEXT,
    submitted_at TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT chk_app_status CHECK (status IN (
        'Draft', 'Submitted', 'Under Review', 'Verified', 'Approved', 
        'Sanctioned', 'Disbursement Initiated', 'Disbursed', 'Rejected', 'Withdrawn'
    )),
    CONSTRAINT chk_app_stage CHECK (current_stage IN (
        'Application', 'Document Verification', 'Institute Verification', 
        'Department Verification', 'Sanction', 'Disbursement'
    ))
);

CREATE INDEX IF NOT EXISTS idx_apps_user_id ON public.applications(user_id);
CREATE INDEX IF NOT EXISTS idx_apps_scholarship_id ON public.applications(scholarship_id);
CREATE INDEX IF NOT EXISTS idx_apps_status ON public.applications(status);

-- ----------------------------------------------------------------------------
-- 4. APPLICATION_STATUS_HISTORY (Timeline & Status Audit Trail)
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.application_status_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    application_id UUID NOT NULL REFERENCES public.applications(id) ON DELETE CASCADE,
    stage VARCHAR(50) NOT NULL,
    status VARCHAR(50) NOT NULL,
    message TEXT NOT NULL,
    changed_by VARCHAR(100) DEFAULT 'System',
    changed_at TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_hist_application_id ON public.application_status_history(application_id);

-- ----------------------------------------------------------------------------
-- 5. DOCUMENTS (Student Document Wallet)
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.documents (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    document_type VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    name VARCHAR(255) NOT NULL,
    storage_path TEXT NOT NULL,
    file_name VARCHAR(255),
    file_type VARCHAR(20),
    file_size_bytes BIGINT,
    verification_status VARCHAR(50) DEFAULT 'Pending',
    rejection_reason TEXT,
    is_digilocker BOOLEAN DEFAULT FALSE,
    issued_date DATE,
    expiry_date DATE,
    uploaded_at TIMESTAMPTZ DEFAULT NOW(),
    verified_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT chk_doc_status CHECK (verification_status IN (
        'Pending', 'Verified', 'Rejected', 'Expired', 'Action Required'
    ))
);

CREATE INDEX IF NOT EXISTS idx_docs_user_id ON public.documents(user_id);
CREATE INDEX IF NOT EXISTS idx_docs_type ON public.documents(document_type);

-- ----------------------------------------------------------------------------
-- 6. APPLICATION_DOCUMENTS (Junction for Document Reuse across Applications)
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.application_documents (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    application_id UUID NOT NULL REFERENCES public.applications(id) ON DELETE CASCADE,
    document_id UUID NOT NULL REFERENCES public.documents(id) ON DELETE RESTRICT,
    document_type VARCHAR(100) NOT NULL,
    is_reused BOOLEAN DEFAULT FALSE,
    attached_at TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(application_id, document_id)
);

CREATE INDEX IF NOT EXISTS idx_app_docs_app_id ON public.application_documents(application_id);
CREATE INDEX IF NOT EXISTS idx_app_docs_doc_id ON public.application_documents(document_id);

-- ----------------------------------------------------------------------------
-- 7. APPLICATION_ACTIONS (Pending Actions / Deficiencies)
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.application_actions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    application_id UUID NOT NULL REFERENCES public.applications(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    action_type VARCHAR(50) NOT NULL,
    status VARCHAR(50) DEFAULT 'Open',
    due_date DATE,
    resolved_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT chk_action_status CHECK (status IN (
        'Open', 'In Progress', 'Resolved', 'Dismissed'
    ))
);

CREATE INDEX IF NOT EXISTS idx_actions_user_id ON public.application_actions(user_id);
CREATE INDEX IF NOT EXISTS idx_actions_app_id ON public.application_actions(application_id);
CREATE INDEX IF NOT EXISTS idx_actions_status ON public.application_actions(status);

-- ----------------------------------------------------------------------------
-- 8. PAYMENTS (DBT / Direct Benefit Transfer Records)
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.payments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    application_id UUID NOT NULL REFERENCES public.applications(id) ON DELETE RESTRICT,
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    amount NUMERIC(12, 2) NOT NULL,
    payment_status VARCHAR(50) NOT NULL,
    dbt_status VARCHAR(50) NOT NULL DEFAULT 'Initiated',
    installment_label VARCHAR(100),
    academic_year VARCHAR(20),
    payment_date TIMESTAMPTZ,
    reference_number VARCHAR(100),
    transaction_reference VARCHAR(100),
    failure_reason TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT chk_payment_status CHECK (payment_status IN (
        'Sanctioned', 'Processing', 'Disbursed', 'Failed', 'Pending', 'Returned'
    )),
    CONSTRAINT chk_dbt_status CHECK (dbt_status IN (
        'Sanctioned', 'Payment Processing', 'Payment Processed', 'DBT Initiated', 'Credited', 'Failed'
    ))
);

CREATE INDEX IF NOT EXISTS idx_payments_user_id ON public.payments(user_id);
CREATE INDEX IF NOT EXISTS idx_payments_app_id ON public.payments(application_id);

-- ----------------------------------------------------------------------------
-- 9. NOTIFICATIONS (User-Isolated Notifications)
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    type VARCHAR(50) NOT NULL,
    related_id VARCHAR(100),
    action_route VARCHAR(255),
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON public.notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_is_read ON public.notifications(user_id, is_read);

-- ============================================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- Ensures user data isolation: User A CANNOT read or write User B's records
-- ============================================================================

-- Enable RLS on all tables
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.scholarships ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.applications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.application_status_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.application_documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.application_actions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- 1. USERS POLICIES
CREATE POLICY "Users can view own profile" 
    ON public.users FOR SELECT 
    USING (auth.uid() = auth_user_id);

CREATE POLICY "Users can update own profile" 
    ON public.users FOR UPDATE 
    USING (auth.uid() = auth_user_id);

CREATE POLICY "Users can insert own profile" 
    ON public.users FOR INSERT 
    WITH CHECK (auth.uid() = auth_user_id);

-- 2. SCHOLARSHIPS POLICIES (Public read-only for authenticated students)
CREATE POLICY "Authenticated users can view active scholarships" 
    ON public.scholarships FOR SELECT 
    TO authenticated 
    USING (is_active = TRUE);

-- 3. APPLICATIONS POLICIES (Strictly isolated by user_id)
CREATE POLICY "Users can view own applications" 
    ON public.applications FOR SELECT 
    USING (user_id IN (SELECT id FROM public.users WHERE auth_user_id = auth.uid()));

CREATE POLICY "Users can insert own applications" 
    ON public.applications FOR INSERT 
    WITH CHECK (user_id IN (SELECT id FROM public.users WHERE auth_user_id = auth.uid()));

CREATE POLICY "Users can update own applications" 
    ON public.applications FOR UPDATE 
    USING (user_id IN (SELECT id FROM public.users WHERE auth_user_id = auth.uid()));

-- 4. APPLICATION STATUS HISTORY POLICIES
CREATE POLICY "Users can view history of own applications" 
    ON public.application_status_history FOR SELECT 
    USING (application_id IN (
        SELECT id FROM public.applications 
        WHERE user_id IN (SELECT id FROM public.users WHERE auth_user_id = auth.uid())
    ));

-- 5. DOCUMENTS POLICIES
CREATE POLICY "Users can view own documents" 
    ON public.documents FOR SELECT 
    USING (user_id IN (SELECT id FROM public.users WHERE auth_user_id = auth.uid()));

CREATE POLICY "Users can insert own documents" 
    ON public.documents FOR INSERT 
    WITH CHECK (user_id IN (SELECT id FROM public.users WHERE auth_user_id = auth.uid()));

CREATE POLICY "Users can update own documents" 
    ON public.documents FOR UPDATE 
    USING (user_id IN (SELECT id FROM public.users WHERE auth_user_id = auth.uid()));

CREATE POLICY "Users can delete own documents" 
    ON public.documents FOR DELETE 
    USING (user_id IN (SELECT id FROM public.users WHERE auth_user_id = auth.uid()));

-- 6. APPLICATION DOCUMENTS POLICIES
CREATE POLICY "Users can view own application document links" 
    ON public.application_documents FOR SELECT 
    USING (application_id IN (
        SELECT id FROM public.applications 
        WHERE user_id IN (SELECT id FROM public.users WHERE auth_user_id = auth.uid())
    ));

CREATE POLICY "Users can insert own application document links" 
    ON public.application_documents FOR INSERT 
    WITH CHECK (application_id IN (
        SELECT id FROM public.applications 
        WHERE user_id IN (SELECT id FROM public.users WHERE auth_user_id = auth.uid())
    ));

-- 7. APPLICATION ACTIONS POLICIES
CREATE POLICY "Users can view own actions" 
    ON public.application_actions FOR SELECT 
    USING (user_id IN (SELECT id FROM public.users WHERE auth_user_id = auth.uid()));

CREATE POLICY "Users can update own actions" 
    ON public.application_actions FOR UPDATE 
    USING (user_id IN (SELECT id FROM public.users WHERE auth_user_id = auth.uid()));

-- 8. PAYMENTS POLICIES
CREATE POLICY "Users can view own payments" 
    ON public.payments FOR SELECT 
    USING (user_id IN (SELECT id FROM public.users WHERE auth_user_id = auth.uid()));

-- 9. NOTIFICATIONS POLICIES
CREATE POLICY "Users can view own notifications" 
    ON public.notifications FOR SELECT 
    USING (user_id IN (SELECT id FROM public.users WHERE auth_user_id = auth.uid()));

CREATE POLICY "Users can update own notifications" 
    ON public.notifications FOR UPDATE 
    USING (user_id IN (SELECT id FROM public.users WHERE auth_user_id = auth.uid()));

-- ============================================================================
-- STORAGE BUCKET POLICIES (Supabase Storage: 'documents')
-- Isolates uploaded document files by authenticated user path: documents/{user_id}/{doc_id}
-- ============================================================================
-- INSERT INTO storage.buckets (id, name, public) VALUES ('documents', 'documents', false);

-- CREATE POLICY "Users can access own document files"
--     ON storage.objects FOR SELECT
--     USING (bucket_id = 'documents' AND (storage.foldername(name))[1] = auth.uid()::text);

-- CREATE POLICY "Users can upload own document files"
--     ON storage.objects FOR INSERT
--     WITH CHECK (bucket_id = 'documents' AND (storage.foldername(name))[1] = auth.uid()::text);

-- ============================================================================
-- MASTER SEED DATA: 5 MoTA SCHEMES
-- ============================================================================
INSERT INTO public.scholarships (
    id, type, name, short_code, tagline, description, detailed_description,
    max_amount, duration, eligibility_criteria, required_documents, portal_url, is_active
) VALUES 
(
    'sch-pre-matric',
    'preMatric',
    'Pre-Matric Scholarship for ST Students',
    'PMS',
    'Financial support for ST students in Class 9 & 10',
    'Centrally sponsored scheme to support ST students studying in classes 9 and 10 to reduce drop-out rate and transition to post-matric education.',
    'Provides monthly stipend, book grant, and hostel allowance for eligible Scheduled Tribe students studying in recognized government and private schools.',
    22500,
    '10 Months/Year',
    ARRAY['Must belong to Scheduled Tribe (ST)', 'Studying in Class 9 or 10', 'Annual family income <= Rs. 2,50,000', 'Regular attendance in recognized school'],
    ARRAY['ST Certificate', 'Income Certificate', 'Previous Class Marksheet', 'Bank Passbook Copy', 'Aadhaar Card'],
    'https://scholarships.gov.in',
    TRUE
),
(
    'sch-post-matric',
    'postMatric',
    'Post-Matric Scholarship for ST Students',
    'PMS-ST',
    'Comprehensive support for Class 11 to Post-Graduate studies',
    'Provides financial assistance to Scheduled Tribe students studying at post-matriculation or post-secondary stages including ITI, Diploma, Degree, PG courses.',
    'Covers mandatory non-refundable fees, maintenance allowance, study tour charges, thesis typing/printing charges, and book allowance.',
    70000,
    'Course Duration',
    ARRAY['Must belong to Scheduled Tribe (ST)', 'Studying in Class 11, 12, ITI, Diploma, Degree, or PG', 'Annual family income <= Rs. 2,50,000', 'Enrolled in an institution with valid AISHE code'],
    ARRAY['ST Certificate', 'Income Certificate', 'Class 10/12 Marksheet', 'Institution Bonafide Certificate', 'Bank Passbook / Cancelled Cheque', 'Aadhaar Card'],
    'https://scholarships.gov.in',
    TRUE
),
(
    'sch-top-class',
    'topClass',
    'National Scholarship for Higher Education (Top Class)',
    'TCE',
    'Full tuition fee and allowances at notified premier institutions',
    'Enables meritorious ST students to pursue studies in premier institutions like IITs, NITs, IIMs, AIIMS, NLUs, and other notified institutes of excellence.',
    'Covers full tuition fee (up to Rs. 2.50 lakh in private institutions), living expenses of Rs. 3,000/month, book & stationery grant of Rs. 5,000/year, and a computer allowance of Rs. 45,000.',
    250000,
    'Full Degree Duration',
    ARRAY['Must belong to Scheduled Tribe (ST)', 'Admitted into notified Top Class institutions (IITs, NITs, IIMs, etc.)', 'Annual family income <= Rs. 6,00,000', 'Selected through national entrance exams (JEE, NEET, CAT, CLAT)'],
    ARRAY['ST Certificate', 'Income Certificate', 'Allotment Letter / Entrance Exam Rank Card', 'Fee Receipt from Institution', 'Aadhaar Card', 'Bank Passbook'],
    'https://scholarships.gov.in',
    TRUE
),
(
    'sch-nfst',
    'nfst',
    'National Fellowship for ST Students',
    'NFST',
    'Fellowship support for M.Phil and Ph.D research scholars',
    'Provides financial assistance to ST scholars pursuing regular and full-time M.Phil and Ph.D courses in Sciences, Humanities, Social Sciences, and Engineering.',
    'JRF fellowship of Rs. 37,000/month for initial 2 years; SRF fellowship of Rs. 42,000/month for remaining period, plus contingency grants up to Rs. 25,000/year and HRA.',
    42000,
    'Up to 5 Years',
    ARRAY['Must belong to Scheduled Tribe (ST)', 'Qualified UGC-NET or CSIR-NET', 'Admitted to regular full-time M.Phil / Ph.D program in recognized university', 'No income ceiling for fellowship award'],
    ARRAY['ST Certificate', 'NET/JRF Scorecard / Award Letter', 'Ph.D/M.Phil Admission Letter', 'Research Proposal Summary', 'Bonafide from University Dean', 'Aadhaar Card'],
    'https://fellowship.tribal.gov.in',
    TRUE
),
(
    'sch-nos',
    'nos',
    'National Overseas Scholarship for ST Candidates',
    'NOS',
    'Prestigious scholarship for Master, Ph.D, and Post-Doctoral abroad',
    'Facilitates low-income ST students to pursue higher education abroad in accredited universities in USA, UK, Germany, Canada, Australia, etc.',
    'Covers complete annual tuition fees, contingency allowance, visa fees, medical insurance, and maintenance allowance (USD 15,400/year or GBP 9,900/year).',
    1500000,
    'Masters: 2-3 yrs, PhD: 4-5 yrs',
    ARRAY['Must belong to Scheduled Tribe (ST)', 'Admitted into QS Top 500 / accredited foreign university', 'Annual family income <= Rs. 6,00,000', 'Minimum 55% marks in qualifying bachelor/master degree'],
    ARRAY['ST Certificate', 'Income Certificate', 'Unconditional Offer Letter from Foreign University', 'GRE/GMAT/IELTS/TOEFL Scorecard', 'Valid Indian Passport', 'Statement of Purpose (SOP)'],
    'https://overseas.tribal.gov.in',
    TRUE
)
ON CONFLICT (id) DO NOTHING;
