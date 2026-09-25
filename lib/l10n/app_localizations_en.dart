// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Adhira';

  @override
  String get motaTitle => 'Ministry of Tribal Affairs';

  @override
  String get motaGov => 'Government of India';

  @override
  String get navHome => 'Home';

  @override
  String get navSchemes => 'Schemes';

  @override
  String get navDocuments => 'Documents';

  @override
  String get navJago => 'JAGO';

  @override
  String get navProfile => 'Profile';

  @override
  String get welcomeBack => 'Welcome Back';

  @override
  String get createAccount => 'Create Account';

  @override
  String get signInSubtitle =>
      'Sign in to continue to your scholarship dashboard';

  @override
  String get registerSubtitle =>
      'Register to discover and apply for MoTA scholarships';

  @override
  String get mobileNumber => 'Mobile Number';

  @override
  String get enterMobileNumber => 'Enter 10-digit mobile number';

  @override
  String get sendOtp => 'Send OTP';

  @override
  String get sendingOtp => 'Sending OTP...';

  @override
  String get otpVerification => 'OTP Verification';

  @override
  String get enterOtpSentTo => 'Enter the 6-digit verification code sent to';

  @override
  String get verifyAndProceed => 'Verify & Proceed';

  @override
  String get verifying => 'Verifying...';

  @override
  String get resendOtp => 'Resend OTP';

  @override
  String resendOtpIn(Object seconds) {
    return 'Resend OTP in ${seconds}s';
  }

  @override
  String get didNotReceiveOtp => 'Didn\'t receive the code?';

  @override
  String get logout => 'Logout';

  @override
  String get signOut => 'Sign Out';

  @override
  String get signOutConfirmTitle => 'Sign Out';

  @override
  String get signOutConfirmMsg =>
      'Are you sure you want to sign out of your account? You will need to verify your mobile number again to log in.';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get retry => 'Retry';

  @override
  String get close => 'Close';

  @override
  String get back => 'Back';

  @override
  String get next => 'Next';

  @override
  String get nextStep => 'Next Step';

  @override
  String get submit => 'Submit';

  @override
  String get saveDraft => 'Save Draft';

  @override
  String get reviewAndSubmit => 'Review & Submit';

  @override
  String get view => 'View';

  @override
  String get change => 'Change';

  @override
  String get status => 'Status';

  @override
  String get actionRequired => 'Action Required';

  @override
  String namasteUser(Object name) {
    return 'Namaste, $name 🙏';
  }

  @override
  String profileCompletion(Object percent) {
    return 'Profile: $percent% Complete';
  }

  @override
  String get totalDisbursed => 'Total Disbursed';

  @override
  String get pendingDisbursement => 'Pending Disbursement';

  @override
  String get activeApplications => 'Active Applications';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get applyScheme => 'Apply for Scheme';

  @override
  String get trackStatus => 'Track Status';

  @override
  String get docWallet => 'Document Wallet';

  @override
  String get eligibilityCheck => 'Eligibility Check';

  @override
  String get jagoAssistant => 'JAGO Assistant';

  @override
  String get recentActivity => 'Recent Activity';

  @override
  String get scholarshipSchemes => 'Scholarship Schemes';

  @override
  String get allSchemes => 'All Schemes';

  @override
  String get preMatric => 'Pre-Matric Scholarship';

  @override
  String get preMatricDesc =>
      'Financial support for ST students in classes 9 and 10';

  @override
  String get postMatric => 'Post-Matric Scholarship';

  @override
  String get postMatricDesc =>
      'Scholarships for ST students pursuing post-secondary studies';

  @override
  String get topClass => 'Top Class Education';

  @override
  String get topClassDesc =>
      'Full financial aid for ST students in premier national institutions';

  @override
  String get nfst => 'National Fellowship for ST';

  @override
  String get nfstDesc =>
      'Higher education fellowship for M.Phil and Ph.D researchers';

  @override
  String get nos => 'National Overseas Scholarship';

  @override
  String get nosDesc => 'Financial assistance for ST students studying abroad';

  @override
  String get applyNow => 'Apply Now';

  @override
  String get schemeDetails => 'Scheme Details';

  @override
  String get benefits => 'Benefits';

  @override
  String get eligibilityCriteria => 'Eligibility Criteria';

  @override
  String get requiredDocuments => 'Required Documents';

  @override
  String get applicationDeadline => 'Application Deadline';

  @override
  String get applicationFormTitle => 'Scholarship Application';

  @override
  String get stepPersonal => 'Personal';

  @override
  String get stepAddress => 'Address';

  @override
  String get stepAcademic => 'Academic';

  @override
  String get stepBankDocs => 'Bank & Docs';

  @override
  String get stepReview => 'Review';

  @override
  String get personalInfo => 'Personal Information';

  @override
  String get personalInfoSubtitle =>
      'Details verified from Aadhaar & DigiLocker.';

  @override
  String get fullName => 'Full Name';

  @override
  String get fatherName => 'Father\'s Name';

  @override
  String get motherName => 'Mother\'s Name';

  @override
  String get dateOfBirth => 'Date of Birth';

  @override
  String get gender => 'Gender';

  @override
  String get male => 'Male';

  @override
  String get female => 'Female';

  @override
  String get other => 'Other';

  @override
  String get category => 'Category';

  @override
  String get tribeName => 'Tribe Name';

  @override
  String get pvtgStatus => 'Particularly Vulnerable Tribal Group (PVTG)';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get addressInfo => 'Address & Domicile';

  @override
  String get addressInfoSubtitle => 'Permanent and correspondence address.';

  @override
  String get state => 'State';

  @override
  String get district => 'District';

  @override
  String get selectState => 'Select State';

  @override
  String get selectDistrict => 'Select District';

  @override
  String get stateRequired => 'State is required';

  @override
  String get districtRequired => 'District is required';

  @override
  String get pincode => 'Pincode';

  @override
  String get addressLine => 'Address Line';

  @override
  String get academicInfo => 'Academic Details';

  @override
  String get academicInfoSubtitle =>
      'Current institution and course information.';

  @override
  String get institutionName => 'Institution Name';

  @override
  String get courseName => 'Course / Degree';

  @override
  String get currentYear => 'Current Year / Class';

  @override
  String get rollNumber => 'Roll / Registration Number';

  @override
  String get bankAndDocsInfo => 'Bank Account & Documents';

  @override
  String get bankAndDocsSubtitle => 'Direct Benefit Transfer (DBT) details.';

  @override
  String get bankName => 'Bank Name';

  @override
  String get accountNumber => 'Account Number';

  @override
  String get ifscCode => 'IFSC Code';

  @override
  String get branchName => 'Branch Name';

  @override
  String get linkDigiLockerTitle => 'Link Documents via DigiLocker';

  @override
  String get linkDigiLockerSubtitle =>
      'Attach government-issued documents from your DigiLocker — Demo';

  @override
  String get linkDigiLockerBtn => 'Link from DigiLocker (Demo)';

  @override
  String get digiLockerLinkedBanner => 'DigiLocker Linked — Demo';

  @override
  String get digiLockerLinkedSubtitle =>
      'Documents from DigiLocker added to your wallet';

  @override
  String get declarationTitle => 'Declaration of Authenticity';

  @override
  String get declarationSubtitle =>
      'I hereby declare that all the information provided above is true and correct to the best of my knowledge.';

  @override
  String get applicationSubmittedTitle => 'Application Submitted!';

  @override
  String get applicationSubmittedMsg =>
      'Your application has been submitted to the Ministry of Tribal Affairs.';

  @override
  String get keepApplicationNumber =>
      'Keep this number for tracking and verification purposes.';

  @override
  String get goToDashboard => 'Dashboard';

  @override
  String get trackApplication => 'Track Application';

  @override
  String get submittedDocsCount => 'Submitted Documents (3)';

  @override
  String get verificationStatus => 'Verification Status';

  @override
  String get digiLockerDemoTitle => 'DigiLocker — Demo';

  @override
  String get digiLockerDemoBanner => 'DigiLocker Integration — Demo';

  @override
  String get demoDataDisclaimer =>
      'Demo Data: Sensitive information is masked for privacy.';

  @override
  String get connectToDigiLocker => 'Connect to DigiLocker';

  @override
  String get connecting => 'Connecting...';

  @override
  String get authenticating => 'Authenticating...';

  @override
  String get fetchingDemoDocs => 'Fetching demo documents from DigiLocker…';

  @override
  String get documentsAvailable => 'Documents Available';

  @override
  String get noDocumentsAvailable => 'No demo documents available';

  @override
  String get connectionFailed => 'Connection Failed';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get useSelectedDocs => 'Use Selected Documents';

  @override
  String importDocsBtn(Object count) {
    return 'Import $count Document(s)';
  }

  @override
  String get importComplete => 'Import Complete!';

  @override
  String get continueWithLinkedDocs => 'Continue with Linked Documents';

  @override
  String get blurredForPrivacy => 'Blurred for Privacy';

  @override
  String get aadhaarCard => 'Aadhaar Card';

  @override
  String get casteCertificate => 'Caste Certificate (SEBC / ST)';

  @override
  String get marksheet12 => 'Class 12 Marksheet';

  @override
  String get incomeCertificate => 'Income Certificate';

  @override
  String get bonafideCertificate => 'Bonafide Certificate';

  @override
  String get govtVerified => 'Govt. Verified (Demo)';

  @override
  String get jagoAssistantName => 'JAGO';

  @override
  String get jagoAssistantSubtitle => 'Scholarship Assistant';

  @override
  String get jagoGreeting =>
      'Namaste! 🙏 I\'m JAGO, your scholarship assistant. How can I help you today?';

  @override
  String get jagoInputHint => 'Ask about scholarships, status, documents...';

  @override
  String get jagoQuickAppStatus => '📋 Application Status';

  @override
  String get jagoQuickPayment => '💰 Payment Status';

  @override
  String get jagoQuickDocs => '📄 Document Help';

  @override
  String get jagoQuickEligibility => '❓ Am I Eligible?';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get noNotifications => 'No notifications yet';

  @override
  String get markAllRead => 'Mark all as read';

  @override
  String get myProfileTitle => 'My Profile';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get personalDetails => 'Personal Details';

  @override
  String get tribalDetails => 'ST/Tribal Details';

  @override
  String get educationDetails => 'Education';

  @override
  String get bankDetails => 'Bank Details (for DBT)';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get preferences => 'Preferences';

  @override
  String get language => 'Language';

  @override
  String get languageSubtitle => 'English (English)';

  @override
  String get security => 'Security';

  @override
  String get support => 'Support';

  @override
  String get helpAndFaq => 'Help & FAQ';

  @override
  String get contactSupport => 'Contact Support';

  @override
  String get about => 'About';

  @override
  String get appVersion => 'App Version';

  @override
  String get motaWebsite => 'MoTA Website';

  @override
  String get statusDraft => 'Draft';

  @override
  String get statusSubmitted => 'Submitted';

  @override
  String get statusUnderReview => 'Under Review';

  @override
  String get statusVerified => 'Verified';

  @override
  String get statusApproved => 'Approved';

  @override
  String get statusSanctioned => 'Sanctioned';

  @override
  String get statusDisbursed => 'Disbursed';

  @override
  String get statusRejected => 'Rejected';

  @override
  String get statusPending => 'Pending';

  @override
  String get selectLanguageTitle => 'Select Language';

  @override
  String get selectLanguageSubtitle =>
      'Choose your preferred language for the application';

  @override
  String get myApplications => 'My Applications';
}
