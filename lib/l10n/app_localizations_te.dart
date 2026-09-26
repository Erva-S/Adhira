// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Telugu (`te`).
class AppLocalizationsTe extends AppLocalizations {
  AppLocalizationsTe([String locale = 'te']) : super(locale);

  @override
  String get appTitle => 'Adhira';

  @override
  String get motaTitle => 'గిరిజన వ్యవహారాల మంత్రిత్వ శాఖ';

  @override
  String get motaGov => 'భారత ప్రభుత్వం';

  @override
  String get navHome => 'హోమ్';

  @override
  String get navSchemes => 'పథకాలు';

  @override
  String get navDocuments => 'పత్రాలు';

  @override
  String get navJago => 'జాగో (JAGO)';

  @override
  String get navProfile => 'ప్రొఫైల్';

  @override
  String get welcomeBack => 'స్వాగతం';

  @override
  String get createAccount => 'ఖాతా తెరవండి';

  @override
  String get signInSubtitle =>
      'మీ స్కాలర్‌షిప్ డ్యాష్‌బోర్డ్‌కు వెళ్లడానికి సైన్ ఇన్ చేయండి';

  @override
  String get registerSubtitle =>
      'MoTA స్కాలర్‌షిప్‌లను కనుగొనడానికి మరియు దరఖాస్తు చేసుకోవడానికి నమోదు చేసుకోండి';

  @override
  String get mobileNumber => 'మొబైల్ నంబర్';

  @override
  String get enterMobileNumber => '10-అంకెల మొబైల్ నంబర్‌ను నమోదు చేయండి';

  @override
  String get sendOtp => 'OTP పంపండి';

  @override
  String get sendingOtp => 'OTP పంపుతోంది...';

  @override
  String get otpVerification => 'OTP ధృవీకరణ';

  @override
  String get enterOtpSentTo => 'ఈ నంబర్‌కు పంపిన 6-అంకెల కోడ్‌ను నమోదు చేయండి:';

  @override
  String get verifyAndProceed => 'ధృవీకరించి ముందుకు సాగండి';

  @override
  String get verifying => 'ధృవీకరిస్తోంది...';

  @override
  String get resendOtp => 'OTP మళ్లీ పంపండి';

  @override
  String resendOtpIn(Object seconds) {
    return '$seconds సెకన్లలో OTP మళ్లీ పంపండి';
  }

  @override
  String get didNotReceiveOtp => 'కోడ్ రాలేదా?';

  @override
  String get logout => 'లాగౌట్';

  @override
  String get signOut => 'సైన్ అవుట్';

  @override
  String get signOutConfirmTitle => 'సైన్ అవుట్';

  @override
  String get signOutConfirmMsg =>
      'మీరు ఖచ్చితంగా మీ ఖాతా నుండి సైన్ అవుట్ చేయాలనుకుంటున్నారా?';

  @override
  String get cancel => 'రద్దు';

  @override
  String get confirm => 'నిర్ధారించండి';

  @override
  String get retry => 'మళ్లీ ప్రయత్నించండి';

  @override
  String get close => 'మూసివేయండి';

  @override
  String get back => 'వెనుకకు';

  @override
  String get next => 'తరువాత';

  @override
  String get nextStep => 'తదుపరి దశ';

  @override
  String get submit => 'సమర్పించండి';

  @override
  String get saveDraft => 'డ్రాఫ్ట్ సేవ్ చేయండి';

  @override
  String get reviewAndSubmit => 'సమీక్షించి సమర్పించండి';

  @override
  String get view => 'చూడండి';

  @override
  String get change => 'మార్చండి';

  @override
  String get status => 'స్థితి';

  @override
  String get actionRequired => 'చర్య అవసరం';

  @override
  String namasteUser(Object name) {
    return 'నమస్కారం, $name 🙏';
  }

  @override
  String profileCompletion(Object percent) {
    return 'ప్రొఫైల్: $percent% పూర్తయింది';
  }

  @override
  String get totalDisbursed => 'మొత్తం విడుదలైన మొత్తం';

  @override
  String get pendingDisbursement => 'పెండింగ్‌లో ఉన్న మొత్తం';

  @override
  String get activeApplications => 'క్రియాశీల దరఖాస్తులు';

  @override
  String get quickActions => 'శీఘ్ర చర్యలు';

  @override
  String get applyScheme => 'పథకానికి దరఖాస్తు చేయండి';

  @override
  String get trackStatus => 'స్థితిని ట్రాక్ చేయండి';

  @override
  String get docWallet => 'పత్రాల వాలెట్';

  @override
  String get eligibilityCheck => 'అర్హత తనిఖీ';

  @override
  String get jagoAssistant => 'జాగో సహాయకుడు';

  @override
  String get recentActivity => 'ఇటీవలి కార్యాచరణ';

  @override
  String get scholarshipSchemes => 'స్కాలర్‌షిప్ పథకాలు';

  @override
  String get allSchemes => 'అన్ని పథకాలు';

  @override
  String get preMatric => 'ప్రీ-మెట్రిక్ స్కాలర్‌షిప్';

  @override
  String get preMatricDesc => '9, 10 తరగతుల ఎస్టీ విద్యార్థులకు ఆర్థిక సహాయం';

  @override
  String get postMatric => 'పోస్ట్-మెట్రిక్ స్కాలర్‌షిప్';

  @override
  String get postMatricDesc =>
      'ఉన్నత విద్య అభ్యసిస్తున్న ఎస్టీ విద్యార్థులకు స్కాలర్‌షిప్‌లు';

  @override
  String get topClass => 'టాప్ క్లాస్ ఎడ్యుకేషన్';

  @override
  String get topClassDesc =>
      'ప్రముఖ జాతీయ సంస్థలలో ఎస్టీ విద్యార్థులకు పూర్తి సహాయం';

  @override
  String get nfst => 'నేషనల్ ఫెలోషిప్ (NFST)';

  @override
  String get nfstDesc => 'ఎం.ఫిల్, పీహెచ్.డీ పరిశోధకులకు ఉన్నత విద్యా ఫెలోషిప్';

  @override
  String get nos => 'నేషనల్ ఓవర్సీస్ స్కాలర్‌షిప్ (NOS)';

  @override
  String get nosDesc =>
      'విదేశాలలో ఉన్నత విద్యను అభ్యసించే ఎస్టీ విద్యార్థులకు ఆర్థిక సహాయం';

  @override
  String get applyNow => 'ఇప్పుడే దరఖాస్తు చేయండి';

  @override
  String get schemeDetails => 'పథకం వివరాలు';

  @override
  String get benefits => 'ప్రయోజనాలు';

  @override
  String get eligibilityCriteria => 'అర్హత ప్రమాణాలు';

  @override
  String get requiredDocuments => 'అవసరమైన పత్రాలు';

  @override
  String get applicationDeadline => 'దరఖాస్తుకు చివరి తేదీ';

  @override
  String get applicationFormTitle => 'స్కాలర్‌షిప్ దరఖాస్తు';

  @override
  String get stepPersonal => 'వ్యక్తిగత';

  @override
  String get stepAddress => 'చిరునామా';

  @override
  String get stepAcademic => 'విద్యా వివరాలు';

  @override
  String get stepBankDocs => 'బ్యాంక్ & పత్రాలు';

  @override
  String get stepReview => 'సమీక్ష';

  @override
  String get personalInfo => 'వ్యక్తిగత సమాచారం';

  @override
  String get personalInfoSubtitle =>
      'ఆధార్ మరియు డిజిలాకర్ ద్వారా ధృవీకరించబడిన వివరాలు.';

  @override
  String get fullName => 'పూర్తి పేరు';

  @override
  String get fatherName => 'తండ్రి పేరు';

  @override
  String get motherName => 'తల్లి పేరు';

  @override
  String get dateOfBirth => 'పుట్టిన తేదీ';

  @override
  String get gender => 'లింగం';

  @override
  String get male => 'పురుషుడు';

  @override
  String get female => 'స్త్రీ';

  @override
  String get other => 'ఇతర';

  @override
  String get category => 'వర్గం';

  @override
  String get tribeName => 'తెగ పేరు';

  @override
  String get pvtgStatus => 'ప్రత్యేకించి బలహీన గిరిజన సమూహం (PVTG)';

  @override
  String get yes => 'అవును';

  @override
  String get no => 'కాదు';

  @override
  String get addressInfo => 'చిరునామా మరియు నివాసం';

  @override
  String get addressInfoSubtitle => 'శాశ్వత మరియు సంప్రదింపు చిరునామా.';

  @override
  String get state => 'రాష్ట్రం';

  @override
  String get district => 'జిల్లా';

  @override
  String get selectState => 'రాష్ట్రాన్ని ఎంచుకోండి';

  @override
  String get selectDistrict => 'జిల్లాను ఎంచుకోండి';

  @override
  String get stateRequired => 'రాష్ట్రం ఎంచుకోవడం తప్పనిసరి';

  @override
  String get districtRequired => 'జిల్లా ఎంచుకోవడం తప్పనిసరి';

  @override
  String get pincode => 'పిన్‌కోడ్';

  @override
  String get addressLine => 'చిరునామా లైన్';

  @override
  String get academicInfo => 'విద్యా వివరాలు';

  @override
  String get academicInfoSubtitle =>
      'ప్రస్తుత విద్యాసంస్థ మరియు కోర్సు సమాచారం.';

  @override
  String get institutionName => 'సంస్థ పేరు';

  @override
  String get courseName => 'కోర్సు / డిగ్రీ';

  @override
  String get currentYear => 'ప్రస్తుత సంవత్సరం / తరగతి';

  @override
  String get rollNumber => 'రోల్ / రిజిస్ట్రేషన్ సంఖ్య';

  @override
  String get bankAndDocsInfo => 'బ్యాంక్ ఖాతా & పత్రాలు';

  @override
  String get bankAndDocsSubtitle =>
      'డైరెక్ట్ బెనిఫిట్ ట్రాన్స్‌ఫర్ (DBT) వివరాలు.';

  @override
  String get bankName => 'బ్యాంక్ పేరు';

  @override
  String get accountNumber => 'ఖాతా సంఖ్య';

  @override
  String get ifscCode => 'IFSC కోడ్';

  @override
  String get branchName => 'శాఖ పేరు';

  @override
  String get linkDigiLockerTitle => 'డిజిలాకర్ ద్వారా పత్రాలను లింక్ చేయండి';

  @override
  String get linkDigiLockerSubtitle =>
      'మీ డిజిలాకర్ నుండి ప్రభుత్వ పత్రాలను జతచేయండి — డెమో';

  @override
  String get linkDigiLockerBtn => 'డిజిలాకర్ నుండి లింక్ చేయండి (డెమో)';

  @override
  String get digiLockerLinkedBanner => 'డిజిలాకర్ లింక్ చేయబడింది — డెమో';

  @override
  String get digiLockerLinkedSubtitle =>
      'డిజిలాకర్ పత్రాలు మీ వాలెట్‌కు జోడించబడ్డాయి';

  @override
  String get declarationTitle => 'ప్రామాణికత ప్రకటన';

  @override
  String get declarationSubtitle =>
      'పైన అందించిన సమాచారం అంతా నా పరిజ్ఞానం మేరకు నిజమని ప్రకటిస్తున్నాను.';

  @override
  String get applicationSubmittedTitle => 'దరఖాస్తు సమర్పించబడింది!';

  @override
  String get applicationSubmittedMsg =>
      'మీ స్కాలర్‌షిప్ దరఖాస్తు గిరిజన వ్యవహారాల మంత్రిత్వ శాఖకు విజయవంతంగా సమర్పించబడింది.';

  @override
  String get keepApplicationNumber =>
      'ట్రాకింగ్ మరియు ధృవీకరణ కోసం ఈ నంబర్‌ను భద్రపరుచుకోండి.';

  @override
  String get goToDashboard => 'డ్యాష్‌బోర్డ్';

  @override
  String get trackApplication => 'దరఖాస్తును ట్రాక్ చేయండి';

  @override
  String get submittedDocsCount => 'సమర్పించిన పత్రాలు (3)';

  @override
  String get verificationStatus => 'ధృవీకరణ స్థితి';

  @override
  String get digiLockerDemoTitle => 'డిజిలాకర్ — డెమో';

  @override
  String get digiLockerDemoBanner => 'డిజిలాకర్ అనుసంధానం — డెమో';

  @override
  String get demoDataDisclaimer =>
      'డెమో డేటా: గోప్యత కోసం సున్నితమైన సమాచారం దాచబడింది.';

  @override
  String get connectToDigiLocker => 'డిజిలాకర్‌కు కనెక్ట్ చేయండి';

  @override
  String get connecting => 'కనెక్ట్ అవుతోంది...';

  @override
  String get authenticating => 'ప్రామాణీకరణ జరుగుతోంది...';

  @override
  String get fetchingDemoDocs =>
      'డిజిలాకర్ నుండి డెమో పత్రాలు పొందబడుతున్నాయి…';

  @override
  String get documentsAvailable => 'పత్రాలు అందుబాటులో ఉన్నాయి';

  @override
  String get noDocumentsAvailable => 'డెమో పత్రాలు అందుబాటులో లేవు';

  @override
  String get connectionFailed => 'కనెక్షన్ విఫలమైంది';

  @override
  String get tryAgain => 'మళ్లీ ప్రయత్నించండి';

  @override
  String get useSelectedDocs => 'ఎంచుకున్న పత్రాలను ఉపయోగించండి';

  @override
  String importDocsBtn(Object count) {
    return '$count పత్రాలను దిగుమతి చేయండి';
  }

  @override
  String get importComplete => 'దిగుమతి పూర్తయింది!';

  @override
  String get continueWithLinkedDocs => 'లింక్ చేసిన పత్రాలతో ముందుకు సాగండి';

  @override
  String get blurredForPrivacy => 'గోప్యత కోసం అస్పష్టంగా ఉంది';

  @override
  String get aadhaarCard => 'ఆధార్ కార్డు';

  @override
  String get casteCertificate => 'కుల ధృవీకరణ పత్రం (SEBC / ST)';

  @override
  String get marksheet12 => '12వ తరగతి మార్కుల జాబితా';

  @override
  String get incomeCertificate => 'ఆదాయ ధృవీకరణ పత్రం';

  @override
  String get bonafideCertificate => 'బోనాఫైడ్ సర్టిఫికెట్';

  @override
  String get govtVerified => 'ప్రభుత్వ ధృవీకృతం (డెమో)';

  @override
  String get jagoAssistantName => 'జాగో';

  @override
  String get jagoAssistantSubtitle => 'స్కాలర్‌షిప్ సహాయకుడు';

  @override
  String get jagoGreeting =>
      'నమస్కారం! 🙏 నేను జాగో, మీ స్కాలర్‌షిప్ సహాయకుడిని. ఈ రోజు మీకు ఎలా సహాయపడగలను?';

  @override
  String get jagoInputHint =>
      'స్కాలర్‌షిప్‌లు, స్థితి లేదా పత్రాల గురించి అడగండి...';

  @override
  String get jagoQuickAppStatus => '📋 దరఖాస్తు స్థితి';

  @override
  String get jagoQuickPayment => '💰 చెల్లింపు స్థితి';

  @override
  String get jagoQuickDocs => '📄 పత్రాల సహాయం';

  @override
  String get jagoQuickEligibility => '❓ నేను అర్హుడినా?';

  @override
  String get notificationsTitle => 'నోటిఫికేషన్‌లు';

  @override
  String get noNotifications => 'ఇంకా నోటిఫికేషన్‌లు లేవు';

  @override
  String get markAllRead => 'అన్నీ చదివినట్లు గుర్తించండి';

  @override
  String get myProfileTitle => 'నా ప్రొఫైల్';

  @override
  String get editProfile => 'ప్రొఫైల్ సవరించండి';

  @override
  String get personalDetails => 'వ్యక్తిగత వివరాలు';

  @override
  String get tribalDetails => 'ఎస్టీ/గిరిజన వివరాలు';

  @override
  String get educationDetails => 'విద్య';

  @override
  String get bankDetails => 'బ్యాంక్ వివరాలు (DBT కొరకు)';

  @override
  String get settingsTitle => 'సెట్టింగ్‌లు';

  @override
  String get preferences => 'ప్రాధాన్యతలు';

  @override
  String get language => 'భాష';

  @override
  String get languageSubtitle => 'తెలుగు (Telugu)';

  @override
  String get security => 'భద్రత';

  @override
  String get support => 'మద్దతు';

  @override
  String get helpAndFaq => 'సహాయం & తరచుగా అడిగే ప్రశ్నలు';

  @override
  String get contactSupport => 'సహాయ కేంద్రాన్ని సంప్రదించండి';

  @override
  String get about => 'యాప్ గురించి';

  @override
  String get appVersion => 'యాప్ వెర్షన్';

  @override
  String get motaWebsite => 'MoTA వెబ్‌సైట్';

  @override
  String get statusDraft => 'డ్రాఫ్ట్';

  @override
  String get statusSubmitted => 'సమర్పించబడింది';

  @override
  String get statusUnderReview => 'సమీక్షలో ఉంది';

  @override
  String get statusVerified => 'ధృవీకరించబడింది';

  @override
  String get statusApproved => 'ఆమోదించబడింది';

  @override
  String get statusSanctioned => 'మంజూరు చేయబడింది';

  @override
  String get statusDisbursed => 'విడుదల చేయబడింది';

  @override
  String get statusRejected => 'తిరస్కరించబడింది';

  @override
  String get statusPending => 'పెండింగ్‌లో ఉంది';

  @override
  String get selectLanguageTitle => 'భాషను ఎంచుకోండి';

  @override
  String get selectLanguageSubtitle =>
      'దరఖాస్తు కోసం మీకు నచ్చిన భాషను ఎంచుకోండి';

  @override
  String get myApplications => 'నా దరఖాస్తులు';

  @override
  String get jagoLanguageTitle => 'జాగో భాష';

  @override
  String get jagoUseAppLanguage => 'యాప్ భాషను ఉపయోగించండి';

  @override
  String get jagoLanguageOverrideHint =>
      'జాగో వేరే భాషను ఉపయోగిస్తోంది. యాప్ భాషను అనుసరించడానికి \"యాప్ భాషను ఉపయోగించండి\" నొక్కండి.';

  @override
  String get jagoLanguageDefaultHint =>
      'జాగో యాప్ భాషను అనుసరిస్తుంది. జాగో కోసమే వేరే భాషను ఎంచుకోండి.';

  @override
  String get jagoContextApplicationTracking =>
      'ఈ దరఖాస్తులో మీకు సహాయం చేయగలను.';

  @override
  String get jagoContextEligibility =>
      'స్కాలర్‌షిప్ పథకాలకు మీ అర్హతను తనిఖీ చేయడంలో సహాయం చేయగలను.';

  @override
  String get jagoContextDocuments => 'మీ పత్రాల గురించి సహాయం చేయగలను.';

  @override
  String get jagoContextPayments =>
      'మీ చెల్లింపు మరియు DBT స్థితి గురించి సహాయం చేయగలను.';

  @override
  String get jagoSuggestionEligibility => 'నా అర్హతను తనిఖీ చేయండి';

  @override
  String get jagoSuggestionTrack => 'నా దరఖాస్తును ట్రాక్ చేయండి';

  @override
  String get jagoSuggestionDocs => 'నాకు ఏ పత్రాలు అవసరం?';

  @override
  String get jagoSuggestionPending => 'ఏ పత్రాలు పెండింగ్‌లో ఉన్నాయి?';

  @override
  String get jagoSuggestionPayment => 'నా చెల్లింపు స్థితిని తనిఖీ చేయండి';

  @override
  String get jagoSuggestionWhichScholarship =>
      'నేను ఏ స్కాలర్‌షిప్ కోసం దరఖాస్తు చేస్తున్నాను?';

  @override
  String get jagoNavPromptApplications => 'దరఖాస్తు ట్రాకింగ్ తెరవాలా?';

  @override
  String get jagoNavPromptDocuments => 'డాక్యుమెంట్ వాలెట్ తెరవాలా?';

  @override
  String get jagoNavPromptPayments => 'చెల్లింపుల విభాగం తెరవాలా?';

  @override
  String get jagoNavPromptEligibility => 'అర్హత తనిఖీ తెరవాలా?';

  @override
  String get jagoAskJago => 'జాగోను అడగండి';

  @override
  String get jagoNeedHelp => 'ఈ దరఖాస్తులో సహాయం కావాలా?';

  @override
  String get jagoNeedHelpSubtitle =>
      'జాగో AI ని అడగండి లేదా మీ జిల్లా గిరిజన అధికారిని సంప్రదించండి.';

  @override
  String jagoOpenedFrom(Object screen) {
    return 'తెరవబడింది: $screen';
  }
}
