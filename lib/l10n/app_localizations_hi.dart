// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'Adhira';

  @override
  String get motaTitle => 'जनजातीय कार्य मंत्रालय';

  @override
  String get motaGov => 'भारत सरकार';

  @override
  String get navHome => 'होम';

  @override
  String get navSchemes => 'योजनाएं';

  @override
  String get navDocuments => 'दस्तावेज़';

  @override
  String get navJago => 'जागो (JAGO)';

  @override
  String get navProfile => 'प्रोफ़ाइल';

  @override
  String get welcomeBack => 'स्वागत है';

  @override
  String get createAccount => 'खाता बनाएं';

  @override
  String get signInSubtitle =>
      'अपने छात्रवृत्ति डैशबोर्ड पर जाने के लिए साइन इन करें';

  @override
  String get registerSubtitle =>
      'MoTA छात्रवृत्ति खोजने और आवेदन करने के लिए पंजीकरण करें';

  @override
  String get mobileNumber => 'मोबाइल नंबर';

  @override
  String get enterMobileNumber => '10-अंकों का मोबाइल नंबर दर्ज करें';

  @override
  String get sendOtp => 'ओटीपी भेजें';

  @override
  String get sendingOtp => 'ओटीपी भेजा जा रहा है...';

  @override
  String get otpVerification => 'ओटीपी सत्यापन';

  @override
  String get enterOtpSentTo => 'इस नंबर पर भेजा गया 6-अंकों का कोड दर्ज करें:';

  @override
  String get verifyAndProceed => 'सत्यापित करें और आगे बढ़ें';

  @override
  String get verifying => 'सत्यापन हो रहा है...';

  @override
  String get resendOtp => 'ओटीपी पुनः भेजें';

  @override
  String resendOtpIn(Object seconds) {
    return '$seconds सेकंड में ओटीपी पुनः भेजें';
  }

  @override
  String get didNotReceiveOtp => 'कोड नहीं मिला?';

  @override
  String get logout => 'लॉगआउट';

  @override
  String get signOut => 'साइन आउट';

  @override
  String get signOutConfirmTitle => 'साइन आउट';

  @override
  String get signOutConfirmMsg =>
      'क्या आप वाकई अपने खाते से साइन आउट करना चाहते हैं? दोबारा लॉग इन करने के लिए मोबाइल नंबर सत्यापित करना होगा।';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get confirm => 'पुष्टि करें';

  @override
  String get retry => 'पुनः प्रयास करें';

  @override
  String get close => 'बंद करें';

  @override
  String get back => 'वापस';

  @override
  String get next => 'आगे';

  @override
  String get nextStep => 'अगला चरण';

  @override
  String get submit => 'जमा करें';

  @override
  String get saveDraft => 'ड्राफ्ट सहेजें';

  @override
  String get reviewAndSubmit => 'समीक्षा और सबमिट करें';

  @override
  String get view => 'देखें';

  @override
  String get change => 'बदलें';

  @override
  String get status => 'स्थिति';

  @override
  String get actionRequired => 'कार्रवाई आवश्यक';

  @override
  String namasteUser(Object name) {
    return 'नमस्ते, $name 🙏';
  }

  @override
  String profileCompletion(Object percent) {
    return 'प्रोफ़ाइल: $percent% पूर्ण';
  }

  @override
  String get totalDisbursed => 'कुल संवितरित राशि';

  @override
  String get pendingDisbursement => 'लंबित संवितरण';

  @override
  String get activeApplications => 'सक्रिय आवेदन';

  @override
  String get quickActions => 'त्वरित क्रियाएं';

  @override
  String get applyScheme => 'योजना के लिए आवेदन करें';

  @override
  String get trackStatus => 'स्थिति ट्रैक करें';

  @override
  String get docWallet => 'दस्तावेज़ वॉलेट';

  @override
  String get eligibilityCheck => 'पात्रता जांच';

  @override
  String get jagoAssistant => 'जागो सहायक';

  @override
  String get recentActivity => 'हाल की गतिविधि';

  @override
  String get scholarshipSchemes => 'छात्रवृत्ति योजनाएं';

  @override
  String get allSchemes => 'सभी योजनाएं';

  @override
  String get preMatric => 'प्री-मैट्रिक छात्रवृत्ति';

  @override
  String get preMatricDesc =>
      'कक्षा 9 और 10 के एसटी छात्रों के लिए वित्तीय सहायता';

  @override
  String get postMatric => 'पोस्ट-मैट्रिक छात्रवृत्ति';

  @override
  String get postMatricDesc =>
      'मैट्रिकोत्तर अध्ययन कर रहे एसटी छात्रों के लिए छात्रवृत्ति';

  @override
  String get topClass => 'टॉप क्लास शिक्षा';

  @override
  String get topClassDesc =>
      'शीर्ष राष्ट्रीय संस्थानों में एसटी छात्रों के लिए पूर्ण वित्तीय सहायता';

  @override
  String get nfst => 'राष्ट्रीय फैलोशिप (NFST)';

  @override
  String get nfstDesc =>
      'एम.फिल और पीएच.डी शोधकर्ताओं के लिए उच्च शिक्षा फैलोशिप';

  @override
  String get nos => 'राष्ट्रीय विदेशी छात्रवृत्ति (NOS)';

  @override
  String get nosDesc =>
      'विदेश में उच्च अध्ययन के लिए एसटी छात्रों को वित्तीय सहायता';

  @override
  String get applyNow => 'अभी आवेदन करें';

  @override
  String get schemeDetails => 'योजना का विवरण';

  @override
  String get benefits => 'लाभ';

  @override
  String get eligibilityCriteria => 'पात्रता मापदंड';

  @override
  String get requiredDocuments => 'आवश्यक दस्तावेज़';

  @override
  String get applicationDeadline => 'आवेदन की अंतिम तिथि';

  @override
  String get applicationFormTitle => 'छात्रवृत्ति आवेदन';

  @override
  String get stepPersonal => 'व्यक्तिगत';

  @override
  String get stepAddress => 'पता';

  @override
  String get stepAcademic => 'शैक्षणिक';

  @override
  String get stepBankDocs => 'बैंक और दस्तावेज़';

  @override
  String get stepReview => 'समीक्षा';

  @override
  String get personalInfo => 'व्यक्तिगत जानकारी';

  @override
  String get personalInfoSubtitle => 'आधार और डिजिलॉकर से सत्यापित विवरण।';

  @override
  String get fullName => 'पूरा नाम';

  @override
  String get fatherName => 'पिता का नाम';

  @override
  String get motherName => 'माता का नाम';

  @override
  String get dateOfBirth => 'जन्म तिथि';

  @override
  String get gender => 'लिंग';

  @override
  String get male => 'पुरुष';

  @override
  String get female => 'महिला';

  @override
  String get other => 'अन्य';

  @override
  String get category => 'श्रेणी';

  @override
  String get tribeName => 'जनजाति का नाम';

  @override
  String get pvtgStatus => 'विशेष रूप से कमजोर जनजातीय समूह (PVTG)';

  @override
  String get yes => 'हाँ';

  @override
  String get no => 'नहीं';

  @override
  String get addressInfo => 'पता और अधिवास';

  @override
  String get addressInfoSubtitle => 'स्थायी और पत्राचार का पता।';

  @override
  String get state => 'राज्य';

  @override
  String get district => 'ज़िला';

  @override
  String get selectState => 'राज्य चुनें';

  @override
  String get selectDistrict => 'ज़िला चुनें';

  @override
  String get stateRequired => 'राज्य चुनना अनिवार्य है';

  @override
  String get districtRequired => 'ज़िला चुनना अनिवार्य है';

  @override
  String get pincode => 'पिनकोड';

  @override
  String get addressLine => 'पता पंक्ति';

  @override
  String get academicInfo => 'शैक्षणिक विवरण';

  @override
  String get academicInfoSubtitle => 'वर्तमान संस्थान और पाठ्यक्रम की जानकारी।';

  @override
  String get institutionName => 'संस्थान का नाम';

  @override
  String get courseName => 'पाठ्यक्रम / डिग्री';

  @override
  String get currentYear => 'वर्तमान वर्ष / कक्षा';

  @override
  String get rollNumber => 'रोल / पंजीकरण संख्या';

  @override
  String get bankAndDocsInfo => 'बैंक खाता और दस्तावेज़';

  @override
  String get bankAndDocsSubtitle => 'प्रत्यक्ष लाभ अंतरण (DBT) विवरण।';

  @override
  String get bankName => 'बैंक का नाम';

  @override
  String get accountNumber => 'खाता संख्या';

  @override
  String get ifscCode => 'आईएफएससी कोड';

  @override
  String get branchName => 'शाखा का नाम';

  @override
  String get linkDigiLockerTitle => 'डिजिलॉकर से दस्तावेज़ लिंक करें';

  @override
  String get linkDigiLockerSubtitle =>
      'अपने डिजिलॉकर से सरकारी दस्तावेज़ संलग्न करें — डेमो';

  @override
  String get linkDigiLockerBtn => 'डिजिलॉकर से लिंक करें (डेमो)';

  @override
  String get digiLockerLinkedBanner => 'डिजिलॉकर लिंक हो गया — डेमो';

  @override
  String get digiLockerLinkedSubtitle =>
      'डिजिलॉकर के दस्तावेज़ आपके वॉलेट में जोड़ दिए गए हैं';

  @override
  String get declarationTitle => 'प्रामाणिकता की घोषणा';

  @override
  String get declarationSubtitle =>
      'मैं घोषणा करता/करती हूँ कि ऊपर दी गई सभी जानकारी मेरी जानकारी के अनुसार सत्य और सही है।';

  @override
  String get applicationSubmittedTitle => 'आवेदन जमा हो गया!';

  @override
  String get applicationSubmittedMsg =>
      'आपका छात्रवृत्ति आवेदन जनजातीय कार्य मंत्रालय को सफलतापूर्वक जमा कर दिया गया है।';

  @override
  String get keepApplicationNumber =>
      'ट्रैकिंग और सत्यापन के लिए इस आवेदन संख्या को सुरक्षित रखें।';

  @override
  String get goToDashboard => 'डैशबोर्ड';

  @override
  String get trackApplication => 'आवेदन ट्रैक करें';

  @override
  String get submittedDocsCount => 'जमा किए गए दस्तावेज़ (3)';

  @override
  String get verificationStatus => 'सत्यापन स्थिति';

  @override
  String get digiLockerDemoTitle => 'डिजिलॉकर — डेमो';

  @override
  String get digiLockerDemoBanner => 'डिजिलॉकर एकीकरण — डेमो';

  @override
  String get demoDataDisclaimer =>
      'डेमो डेटा: गोपनीयता के लिए संवेदनशील जानकारी छिपाई गई है।';

  @override
  String get connectToDigiLocker => 'डिजिलॉकर से कनेक्ट करें';

  @override
  String get connecting => 'कनेक्ट हो रहा है...';

  @override
  String get authenticating => 'प्रमाणीकरण हो रहा है...';

  @override
  String get fetchingDemoDocs =>
      'डिजिलॉकर से डेमो दस्तावेज़ प्राप्त किए जा रहे हैं…';

  @override
  String get documentsAvailable => 'दस्तावेज़ उपलब्ध हैं';

  @override
  String get noDocumentsAvailable => 'कोई डेमो दस्तावेज़ उपलब्ध नहीं है';

  @override
  String get connectionFailed => 'कनेक्शन विफल रहा';

  @override
  String get tryAgain => 'पुनः प्रयास करें';

  @override
  String get useSelectedDocs => 'चयनित दस्तावेज़ उपयोग करें';

  @override
  String importDocsBtn(Object count) {
    return '$count दस्तावेज़ आयात करें';
  }

  @override
  String get importComplete => 'आयात पूर्ण हुआ!';

  @override
  String get continueWithLinkedDocs =>
      'लिंक किए गए दस्तावेज़ों के साथ आगे बढ़ें';

  @override
  String get blurredForPrivacy => 'गोपनीयता के लिए धुंधला';

  @override
  String get aadhaarCard => 'आधार कार्ड';

  @override
  String get casteCertificate => 'जाति प्रमाण पत्र (SEBC / ST)';

  @override
  String get marksheet12 => 'कक्षा 12 की अंकतालिका';

  @override
  String get incomeCertificate => 'आय प्रमाण पत्र';

  @override
  String get bonafideCertificate => 'बोनाफाइड प्रमाण पत्र';

  @override
  String get govtVerified => 'सरकारी सत्यापित (डेमो)';

  @override
  String get jagoAssistantName => 'जागो';

  @override
  String get jagoAssistantSubtitle => 'छात्रवृत्ति सहायक';

  @override
  String get jagoGreeting =>
      'नमस्ते! 🙏 मैं जागो हूँ, आपका छात्रवृत्ति सहायक। आज मैं आपकी क्या मदद कर सकता हूँ?';

  @override
  String get jagoInputHint =>
      'छात्रवृत्ति, स्थिति या दस्तावेज़ों के बारे में पूछें...';

  @override
  String get jagoQuickAppStatus => '📋 आवेदन स्थिति';

  @override
  String get jagoQuickPayment => '💰 भुगतान स्थिति';

  @override
  String get jagoQuickDocs => '📄 दस्तावेज़ सहायता';

  @override
  String get jagoQuickEligibility => '❓ क्या मैं पात्र हूँ?';

  @override
  String get notificationsTitle => 'सूचनाएं';

  @override
  String get noNotifications => 'अभी कोई सूचना नहीं है';

  @override
  String get markAllRead => 'सभी को पढ़ा हुआ चिह्नित करें';

  @override
  String get myProfileTitle => 'मेरी प्रोफ़ाइल';

  @override
  String get editProfile => 'प्रोफ़ाइल संपादित करें';

  @override
  String get personalDetails => 'व्यक्तिगत विवरण';

  @override
  String get tribalDetails => 'एसटी/जनजातीय विवरण';

  @override
  String get educationDetails => 'शिक्षा';

  @override
  String get bankDetails => 'बैंक विवरण (DBT हेतु)';

  @override
  String get settingsTitle => 'सेटिंग्स';

  @override
  String get preferences => 'प्राथमिकताएं';

  @override
  String get language => 'भाषा';

  @override
  String get languageSubtitle => 'हिन्दी (Hindi)';

  @override
  String get security => 'सुरक्षा';

  @override
  String get support => 'सहायता';

  @override
  String get helpAndFaq => 'मदद और अक्सर पूछे जाने वाले प्रश्न';

  @override
  String get contactSupport => 'सहायता केंद्र से संपर्क करें';

  @override
  String get about => 'ऐप के बारे में';

  @override
  String get appVersion => 'ऐप संस्करण';

  @override
  String get motaWebsite => 'MoTA वेबसाइट';

  @override
  String get statusDraft => 'ड्राफ्ट';

  @override
  String get statusSubmitted => 'जमा किया गया';

  @override
  String get statusUnderReview => 'समीक्षाधीन';

  @override
  String get statusVerified => 'सत्यापित';

  @override
  String get statusApproved => 'स्वीकृत';

  @override
  String get statusSanctioned => 'स्वीकृत (मंजूर)';

  @override
  String get statusDisbursed => 'संवितरित';

  @override
  String get statusRejected => 'अस्वीकृत';

  @override
  String get statusPending => 'लंबित';

  @override
  String get selectLanguageTitle => 'भाषा चुनें';

  @override
  String get selectLanguageSubtitle => 'आवेदन के लिए अपनी पसंदीदा भाषा चुनें';

  @override
  String get myApplications => 'मेरे आवेदन';

  @override
  String get jagoLanguageTitle => 'जागो भाषा';

  @override
  String get jagoUseAppLanguage => 'ऐप भाषा उपयोग करें';

  @override
  String get jagoLanguageOverrideHint =>
      'जागो एक अलग भाषा उपयोग कर रहा है। ऐप भाषा का अनुसरण करने के लिए \"ऐप भाषा उपयोग करें\" पर टैप करें।';

  @override
  String get jagoLanguageDefaultHint =>
      'जागो ऐप भाषा का अनुसरण करता है। केवल जागो के लिए एक अलग भाषा चुनें।';

  @override
  String get jagoContextApplicationTracking =>
      'मैं इस आवेदन में आपकी मदद कर सकता हूँ। मुझसे इसकी स्थिति, लंबित कार्यवाहियाँ, आवश्यक दस्तावेज़ या आवेदन समयरेखा के बारे में पूछें।';

  @override
  String get jagoContextEligibility =>
      'मैं छात्रवृत्ति योजनाओं के लिए आपकी पात्रता जाँचने में मदद कर सकता हूँ। मुझसे विशिष्ट मानदंडों या कमियों के बारे में पूछें।';

  @override
  String get jagoContextDocuments =>
      'मैं आपके दस्तावेज़ों में मदद कर सकता हूँ। आवश्यक दस्तावेज़ों, सत्यापन स्थिति या डिजिलॉकर के बारे में पूछें।';

  @override
  String get jagoContextPayments =>
      'मैं आपकी भुगतान और डीबीटी स्थिति में मदद कर सकता हूँ। संवितरण, लंबित किस्तों या भुगतान समयरेखा के बारे में पूछें।';

  @override
  String get jagoSuggestionEligibility => 'मेरी पात्रता जाँचें';

  @override
  String get jagoSuggestionTrack => 'मेरा आवेदन ट्रैक करें';

  @override
  String get jagoSuggestionDocs => 'मुझे कौन से दस्तावेज़ चाहिए?';

  @override
  String get jagoSuggestionPending => 'कौन से दस्तावेज़ लंबित हैं?';

  @override
  String get jagoSuggestionPayment => 'मेरी भुगतान स्थिति जाँचें';

  @override
  String get jagoSuggestionWhichScholarship =>
      'मैं किस छात्रवृत्ति के लिए आवेदन कर रहा/रही हूँ?';

  @override
  String get jagoNavPromptApplications =>
      'क्या आप चाहते हैं कि मैं आवेदन ट्रैकिंग खोलूँ?';

  @override
  String get jagoNavPromptDocuments =>
      'क्या आप चाहते हैं कि मैं दस्तावेज़ वॉलेट खोलूँ?';

  @override
  String get jagoNavPromptPayments =>
      'क्या आप चाहते हैं कि मैं भुगतान अनुभाग खोलूँ?';

  @override
  String get jagoNavPromptEligibility =>
      'क्या आप चाहते हैं कि मैं पात्रता जाँच खोलूँ?';

  @override
  String get jagoAskJago => 'जागो से पूछें';

  @override
  String get jagoNeedHelp => 'इस आवेदन में मदद चाहिए?';

  @override
  String get jagoNeedHelpSubtitle =>
      'जागो AI से पूछें या अपने जिला जनजातीय अधिकारी से संपर्क करें।';

  @override
  String jagoOpenedFrom(Object screen) {
    return 'खोला गया: $screen';
  }
}
