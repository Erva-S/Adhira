/// Status of a scholarship application through its lifecycle.
enum ApplicationStatus {
  draft('Draft', 'Application saved but not submitted'),
  submitted('Submitted', 'Application submitted for review'),
  underReview('Under Review', 'Application is being reviewed'),
  verified('Verified', 'All verifications passed'),
  approved('Approved', 'Application approved for scholarship'),
  sanctioned('Sanctioned', 'Scholarship amount sanctioned'),
  disbursementInitiated('Disbursement Initiated', 'Payment transfer initiated'),
  disbursed('Disbursed', 'Amount transferred to bank account'),
  rejected('Rejected', 'Application was rejected'),
  incomplete('Incomplete', 'Application has missing information'),
  withdrawn('Withdrawn', 'Application withdrawn by student');

  final String label;
  final String description;
  const ApplicationStatus(this.label, this.description);
}

/// Verification and approval stages of a scholarship application.
enum ApplicationStage {
  application('Application', 'Application submission stage'),
  documentVerification('Document Verification', 'Document verification by verifier'),
  instituteVerification('Institute Verification', 'Enrollment & bonafide verification by institute'),
  departmentVerification('Department Verification', 'State Tribal Welfare Department review'),
  sanction('Sanction', 'Scholarship amount sanction by MoTA'),
  disbursement('Disbursement', 'Direct Benefit Transfer (DBT) to bank account');

  final String label;
  final String description;
  const ApplicationStage(this.label, this.description);
}

/// Status of a pending action / deficiency on an application.
enum ActionStatus {
  open('Open'),
  inProgress('In Progress'),
  resolved('Resolved'),
  dismissed('Dismissed');

  final String label;
  const ActionStatus(this.label);
}

/// Category / type of pending action.
enum ActionType {
  documentUpdate('Document Update'),
  bankVerification('Bank Verification'),
  instituteVerification('Institute Verification'),
  incomeClarification('Income Clarification'),
  general('General Action');

  final String label;
  const ActionType(this.label);
}

/// State of DBT (Direct Benefit Transfer) processing.
enum DbtStatus {
  sanctioned('Sanctioned'),
  paymentProcessing('Payment Processing'),
  paymentProcessed('Payment Processed'),
  dbtInitiated('DBT Initiated'),
  credited('Credited'),
  failed('Failed');

  final String label;
  const DbtStatus(this.label);
}

/// Status of an individual verification check.
enum VerificationStatus {
  pending('Pending', 'Verification not yet started'),
  inProgress('In Progress', 'Verification is underway'),
  verified('Verified', 'Successfully verified'),
  failed('Failed', 'Verification failed'),
  mismatch('Mismatch', 'Data mismatch detected — needs resolution'),
  manualReview('Manual Review', 'Sent for manual review by verifier'),
  notApplicable('N/A', 'Verification not applicable');

  final String label;
  final String description;
  const VerificationStatus(this.label, this.description);
}

/// Status of a payment / disbursement.
enum PaymentStatus {
  sanctioned('Sanctioned', 'Amount has been sanctioned'),
  processing('Processing', 'Payment is being processed'),
  disbursed('Disbursed', 'Amount has been transferred'),
  failed('Failed', 'Payment failed — will be retried'),
  pending('Pending', 'Awaiting sanction'),
  returned('Returned', 'Payment returned by bank');

  final String label;
  final String description;
  const PaymentStatus(this.label, this.description);
}

/// Status of a document in the document wallet.
enum DocumentStatus {
  notUploaded('Not Uploaded', 'Document has not been uploaded yet'),
  uploaded('Uploaded', 'Document uploaded, pending verification'),
  verified('Verified', 'Document has been verified'),
  rejected('Rejected', 'Document was rejected — reupload required'),
  expired('Expired', 'Document has expired'),
  digilockerLinked('DigiLocker', 'Fetched from DigiLocker');

  final String label;
  final String description;
  const DocumentStatus(this.label, this.description);
}

/// Types of notifications.
enum NotificationType {
  application('Application'),
  verification('Verification'),
  payment('Payment'),
  document('Document'),
  alert('Important Alert'),
  system('System'),
  reminder('Reminder');

  final String label;
  const NotificationType(this.label);
}

/// The five MoTA scholarship schemes.
enum ScholarshipType {
  preMatric('Pre-Matric Scholarship', 'PMS', 'For ST students in classes 9-10'),
  postMatric('Post-Matric Scholarship', 'PMS-ST', 'For ST students in post-matric courses'),
  topClass('Top Class Education', 'TCE', 'For ST students in top institutions'),
  nfst('National Fellowship for ST', 'NFST', 'Fellowship for M.Phil/Ph.D research'),
  nos('National Overseas Scholarship', 'NOS', 'For studying abroad at Masters/PhD level');

  final String fullName;
  final String shortCode;
  final String tagline;
  const ScholarshipType(this.fullName, this.shortCode, this.tagline);
}

/// Verification types that can be performed.
enum VerificationType {
  identity('Identity Verification'),
  stCertificate('ST/PVTG Certificate'),
  income('Income Verification'),
  academic('Academic Verification'),
  institution('Institution Verification'),
  domicile('Domicile Verification'),
  disability('Disability Certificate'),
  netJrf('NET/JRF Qualification'),
  bankAccount('Bank Account Verification');

  final String label;
  const VerificationType(this.label);
}

/// Document categories.
enum DocumentCategory {
  identity('Identity'),
  caste('Caste/Tribe'),
  income('Income'),
  academic('Academic'),
  address('Address'),
  bank('Bank'),
  photo('Photo'),
  other('Other');

  final String label;
  const DocumentCategory(this.label);
}

/// Chat message sender type.
enum ChatSender {
  user,
  bot,
  system,
}
