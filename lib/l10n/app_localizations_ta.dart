// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Tamil (`ta`).
class AppLocalizationsTa extends AppLocalizations {
  AppLocalizationsTa([String locale = 'ta']) : super(locale);

  @override
  String get appTitle => 'Adhira';

  @override
  String get motaTitle => 'பழங்குடியினர் விவகார அமைச்சகம்';

  @override
  String get motaGov => 'இந்திய அரசு';

  @override
  String get navHome => 'முகப்பு';

  @override
  String get navSchemes => 'திட்டங்கள்';

  @override
  String get navDocuments => 'ஆவணங்கள்';

  @override
  String get navJago => 'ஜாகோ (JAGO)';

  @override
  String get navProfile => 'சுயவிவரம்';

  @override
  String get welcomeBack => 'நல்வரவு';

  @override
  String get createAccount => 'கணக்கை உருவாக்கவும்';

  @override
  String get signInSubtitle =>
      'உங்கள் உதவித்தொகை டாஷ்போர்டிற்கு செல்ல உள்நுழையவும்';

  @override
  String get registerSubtitle =>
      'MoTA உதவித்தொகைகளை காண மற்றும் விண்ணப்பிக்க பதிவு செய்யவும்';

  @override
  String get mobileNumber => 'கைபேசி எண்';

  @override
  String get enterMobileNumber => '10-இலக்க கைபேசி எண்ணை உள்ளிடவும்';

  @override
  String get sendOtp => 'OTP அனுப்பவும்';

  @override
  String get sendingOtp => 'OTP அனுப்பப்படுகிறது...';

  @override
  String get otpVerification => 'OTP சரிபார்ப்பு';

  @override
  String get enterOtpSentTo =>
      'இந்த எண்ணிற்கு அனுப்பப்பட்ட 6-இலக்க குறியீட்டை உள்ளிடவும்:';

  @override
  String get verifyAndProceed => 'சரிபார்த்து தொடரவும்';

  @override
  String get verifying => 'சரிபார்க்கப்படுகிறது...';

  @override
  String get resendOtp => 'OTP-ஐ மீண்டும் அனுப்பவும்';

  @override
  String resendOtpIn(Object seconds) {
    return '$seconds வினாடிகளில் OTP மீண்டும் அனுப்பவும்';
  }

  @override
  String get didNotReceiveOtp => 'குறியீடு வரவில்லையா?';

  @override
  String get logout => 'வெளியேறு';

  @override
  String get signOut => 'வெளியேறு';

  @override
  String get signOutConfirmTitle => 'வெளியேறு';

  @override
  String get signOutConfirmMsg =>
      'உங்கள் கணக்கிலிருந்து வெளியேற விரும்புகிறீர்களா?';

  @override
  String get cancel => 'ரத்துசெய்';

  @override
  String get confirm => 'உறுதிசெய்';

  @override
  String get retry => 'மீண்டும் முயற்சி செய்';

  @override
  String get close => 'மூடு';

  @override
  String get back => 'பின்செல்';

  @override
  String get next => 'அடுத்து';

  @override
  String get nextStep => 'அடுத்த படி';

  @override
  String get submit => 'சமர்ப்பிக்கவும்';

  @override
  String get saveDraft => 'வரைவாக சேமி';

  @override
  String get reviewAndSubmit => 'சரிபார்த்து சமர்ப்பிக்கவும்';

  @override
  String get view => 'பார்';

  @override
  String get change => 'மாற்று';

  @override
  String get status => 'நிலை';

  @override
  String get actionRequired => 'நடவடிக்கை தேவை';

  @override
  String namasteUser(Object name) {
    return 'வணக்கம், $name 🙏';
  }

  @override
  String profileCompletion(Object percent) {
    return 'சுயவிவரம்: $percent% நிறைவு';
  }

  @override
  String get totalDisbursed => 'வழங்கப்பட்ட மொத்த தொகை';

  @override
  String get pendingDisbursement => 'நிலுவையிலுள்ள தொகை';

  @override
  String get activeApplications => 'செயலில் உள்ள விண்ணப்பங்கள்';

  @override
  String get quickActions => 'விரைவு நடவடிக்கைகள்';

  @override
  String get applyScheme => 'திட்டத்திற்கு விண்ணப்பிக்கவும்';

  @override
  String get trackStatus => 'நிலையைக் கண்காணிக்கவும்';

  @override
  String get docWallet => 'ஆவணப் பை (Wallet)';

  @override
  String get eligibilityCheck => 'தகுதி சரிபார்ப்பு';

  @override
  String get jagoAssistant => 'ஜாகோ உதவியாளர்';

  @override
  String get recentActivity => 'சமீபத்திய நடவடிக்கைகள்';

  @override
  String get scholarshipSchemes => 'உதவித்தொகை திட்டங்கள்';

  @override
  String get allSchemes => 'அனைத்து திட்டங்கள்';

  @override
  String get preMatric => 'பத்தாம் வகுப்புக்கு முந்தைய உதவித்தொகை';

  @override
  String get preMatricDesc =>
      '9 மற்றும் 10 ஆம் வகுப்பு எஸ்டி மாணவர்களுக்கான நிதியுதவி';

  @override
  String get postMatric => 'பத்தாம் வகுப்புக்கு பிந்தைய உதவித்தொகை';

  @override
  String get postMatricDesc =>
      'உயர்கல்வி பயிலும் எஸ்டி மாணவர்களுக்கான உதவித்தொகை';

  @override
  String get topClass => 'டாப் கிளாஸ் கல்வி';

  @override
  String get topClassDesc =>
      'முதன்மை தேசிய நிறுவனங்களில் பயிலும் எஸ்டி மாணவர்களுக்கு முழு உதவி';

  @override
  String get nfst => 'தேசிய ஆய்வு உதவித்தொகை (NFST)';

  @override
  String get nfstDesc =>
      'எம்.பில் மற்றும் பிஎச்.டி ஆய்வாளர்களுக்கான ஆய்வு உதவித்தொகை';

  @override
  String get nos => 'தேசிய வெளிநாட்டு உதவித்தொகை (NOS)';

  @override
  String get nosDesc =>
      'வெளிநாட்டில் உயர்கல்வி பயிலும் எஸ்டி மாணவர்களுக்கு நிதியுதவி';

  @override
  String get applyNow => 'இப்போதே விண்ணப்பிக்கவும்';

  @override
  String get schemeDetails => 'திட்டத்தின் விவரங்கள்';

  @override
  String get benefits => 'பயன்கள்';

  @override
  String get eligibilityCriteria => 'தகுதி வரம்புகள்';

  @override
  String get requiredDocuments => 'தேவையான ஆவணங்கள்';

  @override
  String get applicationDeadline => 'விண்ணப்பிக்க கடைசி தேதி';

  @override
  String get applicationFormTitle => 'உதவித்தொகை விண்ணப்பம்';

  @override
  String get stepPersonal => 'தனிநபர்';

  @override
  String get stepAddress => 'முகவரி';

  @override
  String get stepAcademic => 'கல்வி';

  @override
  String get stepBankDocs => 'வங்கி & ஆவணங்கள்';

  @override
  String get stepReview => 'சரிபார்த்தல்';

  @override
  String get personalInfo => 'தனிநபர் விவரங்கள்';

  @override
  String get personalInfoSubtitle =>
      'ஆதார் மற்றும் டிஜிலாக்கர் மூலம் சரிபார்க்கப்பட்ட விவரங்கள்.';

  @override
  String get fullName => 'முழு பெயர்';

  @override
  String get fatherName => 'தந்தை பெயர்';

  @override
  String get motherName => 'தாய் பெயர்';

  @override
  String get dateOfBirth => 'பிறந்த தேதி';

  @override
  String get gender => 'பாலினம்';

  @override
  String get male => 'ஆண்';

  @override
  String get female => 'பெண்';

  @override
  String get other => 'மற்றவை';

  @override
  String get category => 'பிரிவு';

  @override
  String get tribeName => 'பழங்குடி இனம்';

  @override
  String get pvtgStatus => 'குறிப்பாக பாதிக்கப்படக்கூடிய பழங்குடி குழு (PVTG)';

  @override
  String get yes => 'ஆம்';

  @override
  String get no => 'இல்லை';

  @override
  String get addressInfo => 'முகவரி மற்றும் இருப்பிடம்';

  @override
  String get addressInfoSubtitle => 'நிரந்தர மற்றும் தொடர்பு முகவரி.';

  @override
  String get state => 'மாநிலம்';

  @override
  String get district => 'மாவட்டம்';

  @override
  String get selectState => 'மாநிலத்தைத் தேர்ந்தெடுக்கவும்';

  @override
  String get selectDistrict => 'மாவட்டத்தைத் தேர்ந்தெடுக்கவும்';

  @override
  String get stateRequired => 'மாநிலத்தைத் தேர்ந்தெடுப்பது கட்டாயம்';

  @override
  String get districtRequired => 'மாவட்டத்தைத் தேர்ந்தெடுப்பது கட்டாயம்';

  @override
  String get pincode => 'அஞ்சல் குறியீடு (Pincode)';

  @override
  String get addressLine => 'முகவரி வரி';

  @override
  String get academicInfo => 'கல்வி விவரங்கள்';

  @override
  String get academicInfoSubtitle =>
      'தற்போதைய கல்வி நிறுவனம் மற்றும் படிப்பு விவரங்கள்.';

  @override
  String get institutionName => 'நிறுவனத்தின் பெயர்';

  @override
  String get courseName => 'படிப்பு / பட்டம்';

  @override
  String get currentYear => 'தற்போதைய ஆண்டு / வகுப்பு';

  @override
  String get rollNumber => 'பதிவு எண் / ரோல் எண்';

  @override
  String get bankAndDocsInfo => 'வங்கி கணக்கு & ஆவணங்கள்';

  @override
  String get bankAndDocsSubtitle => 'நேரடி நன்மை பரிமாற்றம் (DBT) விவரங்கள்.';

  @override
  String get bankName => 'வங்கியின் பெயர்';

  @override
  String get accountNumber => 'கணக்கு எண்';

  @override
  String get ifscCode => 'IFSC குறியீடு';

  @override
  String get branchName => 'கிளையின் பெயர்';

  @override
  String get linkDigiLockerTitle => 'டிஜிலாக்கர் மூலம் ஆவணங்களை இணைக்கவும்';

  @override
  String get linkDigiLockerSubtitle =>
      'உங்கள் டிஜிலாக்கரிலிருந்து அரசு ஆவணங்களை இணைக்கவும் — டெமோ';

  @override
  String get linkDigiLockerBtn => 'டிஜிலாக்கரிலிருந்து இணைக்கவும் (டெமோ)';

  @override
  String get digiLockerLinkedBanner => 'டிஜிலாக்கர் இணைக்கப்பட்டது — டெமோ';

  @override
  String get digiLockerLinkedSubtitle =>
      'டிஜிலாக்கர் ஆவணங்கள் உங்கள் வாலட்டில் சேர்க்கப்பட்டுள்ளன';

  @override
  String get declarationTitle => 'உண்மைத்தன்மை பிரகடனம்';

  @override
  String get declarationSubtitle =>
      'மேலே கொடுக்கப்பட்டுள்ள அனைத்து விவரங்களும் உண்மை என உறுதியளிக்கிறேன்.';

  @override
  String get applicationSubmittedTitle => 'விண்ணப்பம் சமர்ப்பிக்கப்பட்டது!';

  @override
  String get applicationSubmittedMsg =>
      'உங்கள் உதவித்தொகை விண்ணப்பம் பழங்குடியினர் விவகார அமைச்சகத்திற்கு வெற்றிகரமாக சமர்ப்பிக்கப்பட்டது.';

  @override
  String get keepApplicationNumber =>
      'சரிபார்ப்பு மற்றும் கண்காணிப்பிற்கு இந்த எண்ணை சேமிக்கவும்.';

  @override
  String get goToDashboard => 'டாஷ்போர்டு';

  @override
  String get trackApplication => 'விண்ணப்பத்தைக் கண்காணிக்கவும்';

  @override
  String get submittedDocsCount => 'சமர்ப்பிக்கப்பட்ட ஆவணங்கள் (3)';

  @override
  String get verificationStatus => 'சரிபார்ப்பு நிலை';

  @override
  String get digiLockerDemoTitle => 'டிஜிலாக்கர் — டெமோ';

  @override
  String get digiLockerDemoBanner => 'டிஜிலாக்கர் ஒருங்கிணைப்பு — டெமோ';

  @override
  String get demoDataDisclaimer =>
      'டெமோ தரவு: தனியுரிமைக்காக முக்கியமான விவரங்கள் மறைக்கப்பட்டுள்ளன.';

  @override
  String get connectToDigiLocker => 'டிஜிலாக்கருடன் இணைக்கவும்';

  @override
  String get connecting => 'இணைக்கப்படுகிறது...';

  @override
  String get authenticating => 'அங்கீகரிக்கப்படுகிறது...';

  @override
  String get fetchingDemoDocs =>
      'டிஜிலாக்கரிலிருந்து டெமோ ஆவணங்கள் பெறப்படுகின்றன…';

  @override
  String get documentsAvailable => 'ஆவணங்கள் தயாராக உள்ளன';

  @override
  String get noDocumentsAvailable => 'டெமோ ஆவணங்கள் எதுவும் இல்லை';

  @override
  String get connectionFailed => 'இணைப்பு தோல்வியடைந்தது';

  @override
  String get tryAgain => 'மீண்டும் முயற்சி செய்';

  @override
  String get useSelectedDocs => 'தேர்ந்தெடுத்த ஆவணங்களைப் பயன்படுத்துங்கள்';

  @override
  String importDocsBtn(Object count) {
    return '$count ஆவணங்களை இறக்குமதி செய்க';
  }

  @override
  String get importComplete => 'இறக்குமதி முடிந்தது!';

  @override
  String get continueWithLinkedDocs => 'இணைக்கப்பட்ட ஆவணங்களுடன் தொடரவும்';

  @override
  String get blurredForPrivacy => 'தனியுரிமைக்காக மங்கலாக்கப்பட்டது';

  @override
  String get aadhaarCard => 'ஆதார் அட்டை';

  @override
  String get casteCertificate => 'சாதிச் சான்றிதழ் (SEBC / ST)';

  @override
  String get marksheet12 => '12 ஆம் வகுப்பு மதிப்பெண் பட்டியல்';

  @override
  String get incomeCertificate => 'வருமானச் சான்றிதழ்';

  @override
  String get bonafideCertificate => 'படிப்புச் சான்றிதழ் (Bonafide)';

  @override
  String get govtVerified => 'அரசு சரிபார்க்கப்பட்டது (டெமோ)';

  @override
  String get jagoAssistantName => 'ஜாகோ';

  @override
  String get jagoAssistantSubtitle => 'உதவித்தொகை உதவியாளர்';

  @override
  String get jagoGreeting =>
      'வணக்கம்! 🙏 நான் ஜாகோ, உங்கள் உதவித்தொகை உதவியாளர். இன்று நான் உங்களுக்கு எப்படி உதவ முடியும்?';

  @override
  String get jagoInputHint =>
      'உதவித்தொகை, நிலை அல்லது ஆவணங்கள் பற்றி கேளுங்கள்...';

  @override
  String get jagoQuickAppStatus => '📋 விண்ணப்ப நிலை';

  @override
  String get jagoQuickPayment => '💰 பணம் வழங்கும் நிலை';

  @override
  String get jagoQuickDocs => '📄 ஆவண உதவி';

  @override
  String get jagoQuickEligibility => '❓ நான் தகுதியுடையவரா?';

  @override
  String get notificationsTitle => 'அறிவிப்புகள்';

  @override
  String get noNotifications => 'அறிவிப்புகள் எதுவும் இல்லை';

  @override
  String get markAllRead => 'அனைத்தையும் படித்ததாகக் குறிக்கவும்';

  @override
  String get myProfileTitle => 'என் சுயவிவரம்';

  @override
  String get editProfile => 'சுயவிவரத்தைத் திருத்து';

  @override
  String get personalDetails => 'தனிநபர் விவரங்கள்';

  @override
  String get tribalDetails => 'எஸ்டி/பழங்குடி விவரங்கள்';

  @override
  String get educationDetails => 'கல்வி';

  @override
  String get bankDetails => 'வங்கி விவரங்கள் (DBT க்காக)';

  @override
  String get settingsTitle => 'அமைப்புகள்';

  @override
  String get preferences => 'விருப்பத்தேர்வுகள்';

  @override
  String get language => 'மொழி';

  @override
  String get languageSubtitle => 'தமிழ் (Tamil)';

  @override
  String get security => 'பாதுகாப்பு';

  @override
  String get support => 'உதவி';

  @override
  String get helpAndFaq => 'உதவி & அடிக்கடி கேட்கப்படும் கேள்விகள்';

  @override
  String get contactSupport => 'உதவி மைய தொடர்பு';

  @override
  String get about => 'செயலி பற்றி';

  @override
  String get appVersion => 'செயலி பதிப்பு';

  @override
  String get motaWebsite => 'MoTA வலைத்தளம்';

  @override
  String get statusDraft => 'வரைவு';

  @override
  String get statusSubmitted => 'சமர்ப்பிக்கப்பட்டது';

  @override
  String get statusUnderReview => 'மதிப்பாய்வில் உள்ளது';

  @override
  String get statusVerified => 'சரிபார்க்கப்பட்டது';

  @override
  String get statusApproved => 'ஒப்புதல் அளிக்கப்பட்டது';

  @override
  String get statusSanctioned => 'அனுமதிக்கப்பட்டது';

  @override
  String get statusDisbursed => 'வழங்கப்பட்டது';

  @override
  String get statusRejected => 'நிராகரிக்கப்பட்டது';

  @override
  String get statusPending => 'நிலுவையில் உள்ளது';

  @override
  String get selectLanguageTitle => 'மொழியைத் தேர்ந்தெடுக்கவும்';

  @override
  String get selectLanguageSubtitle =>
      'விண்ணப்பத்திற்கு உங்கள் விருப்பமான மொழியைத் தேர்ந்தெடுக்கவும்';

  @override
  String get myApplications => 'எனது விண்ணப்பங்கள்';

  @override
  String get jagoLanguageTitle => 'ஜாகோ மொழி';

  @override
  String get jagoUseAppLanguage => 'ஆப் மொழியைப் பயன்படுத்து';

  @override
  String get jagoLanguageOverrideHint =>
      'ஜாகோ வேறு மொழியைப் பயன்படுத்துகிறது। ஆப் மொழியைப் பின்பற்ற \"ஆப் மொழியைப் பயன்படுத்து\" என்பதைத் தட்டவும்.';

  @override
  String get jagoLanguageDefaultHint =>
      'ஜாகோ ஆப் மொழியைப் பின்பற்றுகிறது. ஜாகோவுக்கு மட்டும் வேறு மொழியைத் தேர்ந்தெடுக்கவும்.';

  @override
  String get jagoContextApplicationTracking =>
      'இந்த விண்ணப்பத்தில் உங்களுக்கு உதவ முடியும்.';

  @override
  String get jagoContextEligibility =>
      'உதவித்தொகை திட்டங்களுக்கான உங்கள் தகுதியை சரிபார்க்க உதவ முடியும்.';

  @override
  String get jagoContextDocuments => 'உங்கள் ஆவணங்கள் பற்றி உதவ முடியும்.';

  @override
  String get jagoContextPayments =>
      'உங்கள் கட்டணம் மற்றும் DBT நிலை பற்றி உதவ முடியும்.';

  @override
  String get jagoSuggestionEligibility => 'எனது தகுதியை சரிபார்க்கவும்';

  @override
  String get jagoSuggestionTrack => 'எனது விண்ணப்பத்தை கண்காணிக்கவும்';

  @override
  String get jagoSuggestionDocs => 'எனக்கு என்ன ஆவணங்கள் தேவை?';

  @override
  String get jagoSuggestionPending => 'என்ன ஆவணங்கள் நிலுவையில் உள்ளன?';

  @override
  String get jagoSuggestionPayment => 'எனது கட்டண நிலையை சரிபார்க்கவும்';

  @override
  String get jagoSuggestionWhichScholarship =>
      'நான் எந்த உதவித்தொகைக்கு விண்ணப்பிக்கிறேன்?';

  @override
  String get jagoNavPromptApplications =>
      'விண்ணப்ப கண்காணிப்பைத் திறக்க வேண்டுமா?';

  @override
  String get jagoNavPromptDocuments => 'ஆவண வாலட்டைத் திறக்க வேண்டுமா?';

  @override
  String get jagoNavPromptPayments => 'கட்டண பிரிவைத் திறக்க வேண்டுமா?';

  @override
  String get jagoNavPromptEligibility => 'தகுதி சரிபார்ப்பைத் திறக்க வேண்டுமா?';

  @override
  String get jagoAskJago => 'ஜாகோவிடம் கேளுங்கள்';

  @override
  String get jagoNeedHelp => 'இந்த விண்ணப்பத்தில் உதவி தேவையா?';

  @override
  String get jagoNeedHelpSubtitle =>
      'ஜாகோ AI யிடம் கேளுங்கள் அல்லது உங்கள் மாவட்ட பழங்குடியினர் அதிகாரியை தொடர்பு கொள்ளுங்கள்.';

  @override
  String jagoOpenedFrom(Object screen) {
    return 'திறக்கப்பட்டது: $screen';
  }
}
