// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Marathi (`mr`).
class AppLocalizationsMr extends AppLocalizations {
  AppLocalizationsMr([String locale = 'mr']) : super(locale);

  @override
  String get appTitle => 'Adhira';

  @override
  String get motaTitle => 'जनजातीय कार्य मंत्रालय';

  @override
  String get motaGov => 'भारत सरकार';

  @override
  String get navHome => 'मुख्यपृष्ठ';

  @override
  String get navSchemes => 'योजना';

  @override
  String get navDocuments => 'कागदपत्रे';

  @override
  String get navJago => 'जागो (JAGO)';

  @override
  String get navProfile => 'प्रोफाइल';

  @override
  String get welcomeBack => 'स्वागत आहे';

  @override
  String get createAccount => 'खाते तयार करा';

  @override
  String get signInSubtitle =>
      'आपल्या शिष्यवृत्ती डॅशबोर्डवर जाण्यासाठी साइन इन करा';

  @override
  String get registerSubtitle =>
      'MoTA शिष्यवृत्ती शोधण्यासाठी आणि अर्ज करण्यासाठी नोंदणी करा';

  @override
  String get mobileNumber => 'मोबाईल नंबर';

  @override
  String get enterMobileNumber => '10-अंकी मोबाईल नंबर प्रविष्ट करा';

  @override
  String get sendOtp => 'ओटीपी पाठवा';

  @override
  String get sendingOtp => 'ओटीपी पाठवला जात आहे...';

  @override
  String get otpVerification => 'ओटीपी पडताळणी';

  @override
  String get enterOtpSentTo =>
      'या क्रमांकावर पाठवलेला 6-अंकी कोड प्रविष्ट करा:';

  @override
  String get verifyAndProceed => 'पडताळणी करा आणि पुढे जा';

  @override
  String get verifying => 'पडताळणी सुरू आहे...';

  @override
  String get resendOtp => 'ओटीपी पुन्हा पाठवा';

  @override
  String resendOtpIn(Object seconds) {
    return '$seconds सेकंदात ओटीपी पुन्हा पाठवा';
  }

  @override
  String get didNotReceiveOtp => 'कोड मिळाला नाही?';

  @override
  String get logout => 'लॉग आउट';

  @override
  String get signOut => 'साइन आउट';

  @override
  String get signOutConfirmTitle => 'साइन आउट';

  @override
  String get signOutConfirmMsg =>
      'तुम्हाला नक्की आपल्या खात्यातून साइन आउट करायचे आहे का?';

  @override
  String get cancel => 'रद्द करा';

  @override
  String get confirm => 'नक्की करा';

  @override
  String get retry => 'पुन्हा प्रयत्न करा';

  @override
  String get close => 'बंद करा';

  @override
  String get back => 'मागे';

  @override
  String get next => 'पुढे';

  @override
  String get nextStep => 'पुढील पायरी';

  @override
  String get submit => 'सादर करा';

  @override
  String get saveDraft => 'मसुदा जतन करा';

  @override
  String get reviewAndSubmit => 'पुनरावलोकन आणि सबमिट';

  @override
  String get view => 'पहा';

  @override
  String get change => 'बदला';

  @override
  String get status => 'स्थिती';

  @override
  String get actionRequired => 'कृती आवश्यक';

  @override
  String namasteUser(Object name) {
    return 'नमस्ते, $name 🙏';
  }

  @override
  String profileCompletion(Object percent) {
    return 'प्रोफाइल: $percent% पूर्ण';
  }

  @override
  String get totalDisbursed => 'एकूण वितरित रक्कम';

  @override
  String get pendingDisbursement => 'प्रलंबित वितरण';

  @override
  String get activeApplications => 'सक्रिय अर्ज';

  @override
  String get quickActions => 'द्रुत कृती';

  @override
  String get applyScheme => 'योजनेसाठी अर्ज करा';

  @override
  String get trackStatus => 'स्थिती ट्रॅक करा';

  @override
  String get docWallet => 'कागदपत्र वॉलेट';

  @override
  String get eligibilityCheck => 'पात्रता तपासणी';

  @override
  String get jagoAssistant => 'जागो सहाय्यक';

  @override
  String get recentActivity => 'अलीकडील क्रियाकलाप';

  @override
  String get scholarshipSchemes => 'शिष्यवृत्ती योजना';

  @override
  String get allSchemes => 'सर्व योजना';

  @override
  String get preMatric => 'मॅट्रिकपूर्व शिष्यवृत्ती';

  @override
  String get preMatricDesc =>
      'इयत्ता 9 आणि 10 मधील एसटी विद्यार्थ्यांसाठी आर्थिक साहाय्य';

  @override
  String get postMatric => 'मॅट्रिकोत्तर शिष्यवृत्ती';

  @override
  String get postMatricDesc =>
      'मॅट्रिकोत्तर शिक्षण घेणाऱ्या एसटी विद्यार्थ्यांसाठी शिष्यवृत्ती';

  @override
  String get topClass => 'टॉप क्लास शिक्षण';

  @override
  String get topClassDesc =>
      'प्रमुख राष्ट्रीय संस्थांमधील एसटी विद्यार्थ्यांसाठी पूर्ण साहाय्य';

  @override
  String get nfst => 'राष्ट्रीय फेलोशिप (NFST)';

  @override
  String get nfstDesc => 'एम.फिल आणि पीएच.डी संशोधकांसाठी उच्च शिक्षण फेलोशिप';

  @override
  String get nos => 'राष्ट्रीय विदेशी शिष्यवृत्ती (NOS)';

  @override
  String get nosDesc =>
      'परदेशात उच्च शिक्षणासाठी एसटी विद्यार्थ्यांना आर्थिक साहाय्य';

  @override
  String get applyNow => 'आता अर्ज करा';

  @override
  String get schemeDetails => 'योजनेचा तपशील';

  @override
  String get benefits => 'फायदे';

  @override
  String get eligibilityCriteria => 'पात्रता निकष';

  @override
  String get requiredDocuments => 'आवश्यक कागदपत्रे';

  @override
  String get applicationDeadline => 'अर्जाची अंतिम तारीख';

  @override
  String get applicationFormTitle => 'शिष्यवृत्ती अर्ज';

  @override
  String get stepPersonal => 'वैयक्तिक';

  @override
  String get stepAddress => 'पत्ता';

  @override
  String get stepAcademic => 'शैक्षणिक';

  @override
  String get stepBankDocs => 'बँक आणि कागदपत्रे';

  @override
  String get stepReview => 'पुनरावलोकन';

  @override
  String get personalInfo => 'वैयक्तिक माहिती';

  @override
  String get personalInfoSubtitle =>
      'आधार आणि डिजिलॉकरद्वारे पडताळलेली माहिती.';

  @override
  String get fullName => 'पूर्ण नाव';

  @override
  String get fatherName => 'वडिलांचे नाव';

  @override
  String get motherName => 'आईचे नाव';

  @override
  String get dateOfBirth => 'जन्मतारीख';

  @override
  String get gender => 'लिंग';

  @override
  String get male => 'पुरुष';

  @override
  String get female => 'महिला';

  @override
  String get other => 'इतर';

  @override
  String get category => 'प्रवर्ग';

  @override
  String get tribeName => 'जमातीचे नाव';

  @override
  String get pvtgStatus => 'विशेषतः असुरक्षित आदिवासी गट (PVTG)';

  @override
  String get yes => 'होय';

  @override
  String get no => 'नाही';

  @override
  String get addressInfo => 'पत्ता आणि अधिवास';

  @override
  String get addressInfoSubtitle => 'कायमचा आणि पत्रव्यवहाराचा पत्ता.';

  @override
  String get state => 'राज्य';

  @override
  String get district => 'जिल्हा';

  @override
  String get selectState => 'राज्य निवडा';

  @override
  String get selectDistrict => 'जिल्हा निवडा';

  @override
  String get stateRequired => 'राज्य निवडणे आवश्यक आहे';

  @override
  String get districtRequired => 'जिल्हा निवडणे आवश्यक आहे';

  @override
  String get pincode => 'पिनकोड';

  @override
  String get addressLine => 'पत्ता ओळ';

  @override
  String get academicInfo => 'शैक्षणिक तपशील';

  @override
  String get academicInfoSubtitle => 'सध्याची संस्था आणि अभ्यासक्रमाची माहिती.';

  @override
  String get institutionName => 'संस्थेचे नाव';

  @override
  String get courseName => 'अभ्यासक्रम / पदवी';

  @override
  String get currentYear => 'चालू वर्ष / वर्ग';

  @override
  String get rollNumber => 'हजेरी / नोंदणी क्रमांक';

  @override
  String get bankAndDocsInfo => 'बँक खाते आणि कागदपत्रे';

  @override
  String get bankAndDocsSubtitle => 'थेट लाभ हस्तांतरण (DBT) तपशील.';

  @override
  String get bankName => 'बँकेचे नाव';

  @override
  String get accountNumber => 'खाते क्रमांक';

  @override
  String get ifscCode => 'IFSC कोड';

  @override
  String get branchName => 'शाखेचे नाव';

  @override
  String get linkDigiLockerTitle => 'डिजिलॉकरवरून कागदपत्रे लिंक करा';

  @override
  String get linkDigiLockerSubtitle =>
      'आपल्या डिजिलॉकरमधील सरकारी कागदपत्रे जोडा — डेमो';

  @override
  String get linkDigiLockerBtn => 'डिजिलॉकरवरून लिंक करा (डेमो)';

  @override
  String get digiLockerLinkedBanner => 'डिजिलॉकर लिंक झाले — डेमो';

  @override
  String get digiLockerLinkedSubtitle =>
      'डिजिलॉकरमधील कागदपत्रे आपल्या वॉलेटमध्ये जोडली गेली आहेत';

  @override
  String get declarationTitle => 'सत्यतेची घोषणा';

  @override
  String get declarationSubtitle =>
      'मी घोषित करतो/करते की वर दिलेली सर्व माहिती माझ्या माहितीनुसार खरी आहे.';

  @override
  String get applicationSubmittedTitle => 'अर्ज सादर केला!';

  @override
  String get applicationSubmittedMsg =>
      'आपला शिष्यवृत्ती अर्ज जनजातीय कार्य मंत्रालयाकडे यशस्वीरीत्या सादर केला गेला आहे.';

  @override
  String get keepApplicationNumber =>
      'ट्रॅकिंग आणि पडताळणीसाठी हा अर्ज क्रमांक सुरक्षित ठेवा.';

  @override
  String get goToDashboard => 'डॅशबोर्ड';

  @override
  String get trackApplication => 'अर्ज ट्रॅक करा';

  @override
  String get submittedDocsCount => 'सादर केलेली कागदपत्रे (3)';

  @override
  String get verificationStatus => 'पडताळणी स्थिती';

  @override
  String get digiLockerDemoTitle => 'डिजिलॉकर — डेमो';

  @override
  String get digiLockerDemoBanner => 'डिजिलॉकर एकत्रीकरण — डेमो';

  @override
  String get demoDataDisclaimer =>
      'डेमो डेटा: गोपनीयतेसाठी संवेदनशील माहिती लपवली आहे.';

  @override
  String get connectToDigiLocker => 'डिजिलॉकरशी कनेक्ट करा';

  @override
  String get connecting => 'कनेक्ट होत आहे...';

  @override
  String get authenticating => 'प्रमाणीकरण सुरू आहे...';

  @override
  String get fetchingDemoDocs => 'डिजिलॉकरवरून डेमो कागदपत्रे मिळवत आहोत…';

  @override
  String get documentsAvailable => 'कागदपत्रे उपलब्ध आहेत';

  @override
  String get noDocumentsAvailable => 'कागदपत्रे उपलब्ध नाहीत';

  @override
  String get connectionFailed => 'कनेक्शन अयशस्वी';

  @override
  String get tryAgain => 'पुन्हा प्रयत्न करा';

  @override
  String get useSelectedDocs => 'निवडलेली कागदपत्रे वापरा';

  @override
  String importDocsBtn(Object count) {
    return '$count कागदपत्रे आयात करा';
  }

  @override
  String get importComplete => 'आयात पूर्ण झाली!';

  @override
  String get continueWithLinkedDocs => 'लिंक केलेल्या कागदपत्रांसह पुढे जा';

  @override
  String get blurredForPrivacy => 'गोपनीयतेसाठी अस्पष्ट';

  @override
  String get aadhaarCard => 'आधार कार्ड';

  @override
  String get casteCertificate => 'जात प्रमाणपत्र (SEBC / ST)';

  @override
  String get marksheet12 => 'इयत्ता 12 वी गुणपत्रिका';

  @override
  String get incomeCertificate => 'उत्पन्न प्रमाणपत्र';

  @override
  String get bonafideCertificate => 'बोनाफाईड प्रमाणपत्र';

  @override
  String get govtVerified => 'शासकीय पडताळणीकृत (डेमो)';

  @override
  String get jagoAssistantName => 'जागो';

  @override
  String get jagoAssistantSubtitle => 'शिष्यवृत्ती सहाय्यक';

  @override
  String get jagoGreeting =>
      'नमस्ते! 🙏 मी जागो आहे, तुमचा शिष्यवृत्ती सहाय्यक. मी आज तुम्हाला कशी मदत करू शकतो?';

  @override
  String get jagoInputHint =>
      'शिष्यवृत्ती, स्थिती किंवा कागदपत्रांबद्दल विचारा...';

  @override
  String get jagoQuickAppStatus => '📋 अर्ज स्थिती';

  @override
  String get jagoQuickPayment => '💰 पेमेंट स्थिती';

  @override
  String get jagoQuickDocs => '📄 कागदपत्र मदत';

  @override
  String get jagoQuickEligibility => '❓ मी पात्र आहे का?';

  @override
  String get notificationsTitle => 'सूचना';

  @override
  String get noNotifications => 'अद्याप कोणतीही सूचना नाही';

  @override
  String get markAllRead => 'सर्व वाचलेले म्हणून चिन्हांकित करा';

  @override
  String get myProfileTitle => 'माझी प्रोफाइल';

  @override
  String get editProfile => 'प्रोफाइल संपादित करा';

  @override
  String get personalDetails => 'वैयक्तिक तपशील';

  @override
  String get tribalDetails => 'एसटी/जनजाती तपशील';

  @override
  String get educationDetails => 'शिक्षण';

  @override
  String get bankDetails => 'बँक तपशील (DBT साठी)';

  @override
  String get settingsTitle => 'सेटिंग्ज';

  @override
  String get preferences => 'प्राधान्ये';

  @override
  String get language => 'भाषा';

  @override
  String get languageSubtitle => 'मराठी (Marathi)';

  @override
  String get security => 'सुरक्षा';

  @override
  String get support => 'मदत';

  @override
  String get helpAndFaq => 'मदत आणि सामान्य प्रश्न';

  @override
  String get contactSupport => 'सहाय्यता केंद्र संपर्क';

  @override
  String get about => 'अ‍ॅपबद्दल';

  @override
  String get appVersion => 'अ‍ॅप आवृत्ती';

  @override
  String get motaWebsite => 'MoTA संकेतस्थळ';

  @override
  String get statusDraft => 'मसुदा';

  @override
  String get statusSubmitted => 'सादर केले';

  @override
  String get statusUnderReview => 'पुनरावलोकनाधीन';

  @override
  String get statusVerified => 'पडताळणीकृत';

  @override
  String get statusApproved => 'मंजूर';

  @override
  String get statusSanctioned => 'मंजूर (संमत)';

  @override
  String get statusDisbursed => 'वितरित';

  @override
  String get statusRejected => 'नाकारले';

  @override
  String get statusPending => 'प्रलंबित';

  @override
  String get selectLanguageTitle => 'भाषा निवडा';

  @override
  String get selectLanguageSubtitle => 'अर्जासाठी आपली पसंतीची भाषा निवडा';

  @override
  String get myApplications => 'माझे अर्ज';

  @override
  String get jagoLanguageTitle => 'जागो भाषा';

  @override
  String get jagoUseAppLanguage => 'अ‍ॅप भाषा वापरा';

  @override
  String get jagoLanguageOverrideHint =>
      'जागो वेगळी भाषा वापरत आहे। अ‍ॅप भाषेचे अनुसरण करण्यासाठी \"अ‍ॅप भाषा वापरा\" वर टॅप करा.';

  @override
  String get jagoLanguageDefaultHint =>
      'जागो अ‍ॅप भाषेचे अनुसरण करतो. फक्त जागोसाठी वेगळी भाषा निवडा.';

  @override
  String get jagoContextApplicationTracking =>
      'मी या अर्जात तुम्हाला मदत करू शकतो. मला त्याची स्थिती, प्रलंबित कृती, आवश्यक कागदपत्रे किंवा अर्ज कालरेषेबद्दल विचारा.';

  @override
  String get jagoContextEligibility =>
      'मी शिष्यवृत्ती योजनांसाठी तुमची पात्रता तपासण्यात मदत करू शकतो.';

  @override
  String get jagoContextDocuments => 'मी तुमच्या कागदपत्रांबद्दल मदत करू शकतो.';

  @override
  String get jagoContextPayments =>
      'मी तुमच्या पेमेंट आणि DBT स्थितीबद्दल मदत करू शकतो.';

  @override
  String get jagoSuggestionEligibility => 'माझी पात्रता तपासा';

  @override
  String get jagoSuggestionTrack => 'माझा अर्ज ट्रॅक करा';

  @override
  String get jagoSuggestionDocs => 'मला कोणती कागदपत्रे लागतात?';

  @override
  String get jagoSuggestionPending => 'कोणती कागदपत्रे प्रलंबित आहेत?';

  @override
  String get jagoSuggestionPayment => 'माझी पेमेंट स्थिती तपासा';

  @override
  String get jagoSuggestionWhichScholarship =>
      'मी कोणत्या शिष्यवृत्तीसाठी अर्ज करत आहे?';

  @override
  String get jagoNavPromptApplications =>
      'तुम्हाला हवे आहे का मी अर्ज ट्रॅकिंग उघडू?';

  @override
  String get jagoNavPromptDocuments =>
      'तुम्हाला हवे आहे का मी कागदपत्र वॉलेट उघडू?';

  @override
  String get jagoNavPromptPayments =>
      'तुम्हाला हवे आहे का मी पेमेंट विभाग उघडू?';

  @override
  String get jagoNavPromptEligibility =>
      'तुम्हाला हवे आहे का मी पात्रता तपासणी उघडू?';

  @override
  String get jagoAskJago => 'जागोला विचारा';

  @override
  String get jagoNeedHelp => 'या अर्जात मदत हवी आहे?';

  @override
  String get jagoNeedHelpSubtitle =>
      'जागो AI ला विचारा किंवा तुमच्या जिल्हा जनजाती अधिकाऱ्यांशी संपर्क साधा.';

  @override
  String jagoOpenedFrom(Object screen) {
    return 'उघडले: $screen';
  }
}
