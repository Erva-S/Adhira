// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Gujarati (`gu`).
class AppLocalizationsGu extends AppLocalizations {
  AppLocalizationsGu([String locale = 'gu']) : super(locale);

  @override
  String get appTitle => 'Adhira';

  @override
  String get motaTitle => 'જનજાતીય કાર્ય મંત્રાલય';

  @override
  String get motaGov => 'ભારત સરકાર';

  @override
  String get navHome => 'હોમ';

  @override
  String get navSchemes => 'યોજનાઓ';

  @override
  String get navDocuments => 'દસ્તાવેજો';

  @override
  String get navJago => 'જાગો (JAGO)';

  @override
  String get navProfile => 'પ્રોફાઇલ';

  @override
  String get welcomeBack => 'સ્વાગત છે';

  @override
  String get createAccount => 'ખાતું બનાવો';

  @override
  String get signInSubtitle =>
      'તમારા સ્કોલરશીપ ડેશબોર્ડ પર જવા માટે સાઇન ઇન કરો';

  @override
  String get registerSubtitle =>
      'MoTA સ્કોલરશીપ શોધવા અને અરજી કરવા માટે નોંધણી કરો';

  @override
  String get mobileNumber => 'મોબાઇલ નંબર';

  @override
  String get enterMobileNumber => '10-અંકનો મોબાઇલ નંબર દાખલ કરો';

  @override
  String get sendOtp => 'ઓટીપી મોકલો';

  @override
  String get sendingOtp => 'ઓટીપી મોકલાઈ રહ્યો છે...';

  @override
  String get otpVerification => 'ઓટીપી વેરિફિકેશન';

  @override
  String get enterOtpSentTo => 'આ નંબર પર મોકલેલ 6-અંકનો કોડ દાખલ કરો:';

  @override
  String get verifyAndProceed => 'ચકાસો અને આગળ વધો';

  @override
  String get verifying => 'ચકાસણી ચાલુ છે...';

  @override
  String get resendOtp => 'ઓટીપી ફરી મોકલો';

  @override
  String resendOtpIn(Object seconds) {
    return '$seconds સેકન્ડમાં ઓટીપી ફરી મોકલો';
  }

  @override
  String get didNotReceiveOtp => 'કોડ નથી મળ્યો?';

  @override
  String get logout => 'લૉગ આઉટ';

  @override
  String get signOut => 'સાઇન આઉટ';

  @override
  String get signOutConfirmTitle => 'સાઇન આઉટ';

  @override
  String get signOutConfirmMsg =>
      'શું તમે ખરેખર તમારા ખાતામાંથી સાઇન આઉટ કરવા માંગો છો?';

  @override
  String get cancel => 'રદ કરો';

  @override
  String get confirm => 'પુષ્ટિ કરો';

  @override
  String get retry => 'ફરી પ્રયાસ કરો';

  @override
  String get close => 'બંધ કરો';

  @override
  String get back => 'પાછળ';

  @override
  String get next => 'આગળ';

  @override
  String get nextStep => 'આગળનું પગલું';

  @override
  String get submit => 'સબમિટ કરો';

  @override
  String get saveDraft => 'ડ્રાફ્ટ સાચવો';

  @override
  String get reviewAndSubmit => 'સમીક્ષા અને સબમિટ';

  @override
  String get view => 'જુઓ';

  @override
  String get change => 'બદલો';

  @override
  String get status => 'સ્થિતિ';

  @override
  String get actionRequired => 'ક્રિયા જરૂરી';

  @override
  String namasteUser(Object name) {
    return 'નમસ્તે, $name 🙏';
  }

  @override
  String profileCompletion(Object percent) {
    return 'પ્રોફાઇલ: $percent% પૂર્ણ';
  }

  @override
  String get totalDisbursed => 'કુલ ચુકવેલ રકમ';

  @override
  String get pendingDisbursement => 'બાકી ચુકવણી';

  @override
  String get activeApplications => 'સક્રિય અરજીઓ';

  @override
  String get quickActions => 'ઝડપી ક્રિયાઓ';

  @override
  String get applyScheme => 'યોજના માટે અરજી કરો';

  @override
  String get trackStatus => 'સ્થિતિ ટ્રેક કરો';

  @override
  String get docWallet => 'દસ્તાવેજ વૉલેટ';

  @override
  String get eligibilityCheck => 'પાત્રતા ચકાસણી';

  @override
  String get jagoAssistant => 'જાગો સહાયક';

  @override
  String get recentActivity => 'તાજેતરની પ્રવૃત્તિ';

  @override
  String get scholarshipSchemes => 'સ્કોલરશીપ યોજનાઓ';

  @override
  String get allSchemes => 'તમામ યોજનાઓ';

  @override
  String get preMatric => 'પ્રી-મેટ્રિક સ્કોલરશીપ';

  @override
  String get preMatricDesc =>
      'ધોરણ 9 અને 10 ના એસટી વિદ્યાર્થીઓ માટે નાણાકીય સહાય';

  @override
  String get postMatric => 'પોસ્ટ-મેટ્રિક સ્કોલરશીપ';

  @override
  String get postMatricDesc =>
      'મેટ્રિક પછીના અભ્યાસ માટે એસટી વિદ્યાર્થીઓ માટે શિષ્યવૃત્તિ';

  @override
  String get topClass => 'ટોપ ક્લાસ એજ્યુકેશન';

  @override
  String get topClassDesc =>
      'ટોચની રાષ્ટ્રીય સંસ્થાઓમાં એસટી વિદ્યાર્થીઓ માટે સંપૂર્ણ સહાય';

  @override
  String get nfst => 'નેશનલ ફેલોશિપ (NFST)';

  @override
  String get nfstDesc => 'એમ.ફિલ અને પી.એચડી સંશોધકો માટે ઉચ્ચ શિક્ષણ ફેલોશિપ';

  @override
  String get nos => 'નેશનલ ઓવરસીઝ સ્કોલરશીપ (NOS)';

  @override
  String get nosDesc =>
      'વિદેશમાં ઉચ્ચ અભ્યાસ માટે એસટી વિદ્યાર્થીઓને નાણાકીય સહાય';

  @override
  String get applyNow => 'હમણાં અરજી કરો';

  @override
  String get schemeDetails => 'યોજનાની વિગતો';

  @override
  String get benefits => 'લાભો';

  @override
  String get eligibilityCriteria => 'પાત્રતા માપદંડ';

  @override
  String get requiredDocuments => 'જરૂરી દસ્તાવેજો';

  @override
  String get applicationDeadline => 'અરજીની છેલ્લી તારીખ';

  @override
  String get applicationFormTitle => 'સ્કોલરશીપ અરજી';

  @override
  String get stepPersonal => 'વ્યક્તિગત';

  @override
  String get stepAddress => 'સરનામું';

  @override
  String get stepAcademic => 'શૈક્ષણિક';

  @override
  String get stepBankDocs => 'બેંક અને દસ્તાવેજ';

  @override
  String get stepReview => 'સમીક્ષા';

  @override
  String get personalInfo => 'વ્યક્તિગત માહિતી';

  @override
  String get personalInfoSubtitle => 'આધાર અને ડિજીલૉકર દ્વારા ચકાસાયેલ વિગતો.';

  @override
  String get fullName => 'પૂરું નામ';

  @override
  String get fatherName => 'પિતાનું નામ';

  @override
  String get motherName => 'માતાનું નામ';

  @override
  String get dateOfBirth => 'જન્મ તારીખ';

  @override
  String get gender => 'જાતિ';

  @override
  String get male => 'પુરુષ';

  @override
  String get female => 'મહિલા';

  @override
  String get other => 'અન્ય';

  @override
  String get category => 'કેટેગરી';

  @override
  String get tribeName => 'જનજાતિનું નામ';

  @override
  String get pvtgStatus => 'ખાસ સંવેદનશીલ આદિજાતિ જૂથ (PVTG)';

  @override
  String get yes => 'હા';

  @override
  String get no => 'ના';

  @override
  String get addressInfo => 'સરનામું અને રહેઠાણ';

  @override
  String get addressInfoSubtitle => 'કાયમી અને પત્રવ્યવહારનું સરનામું.';

  @override
  String get state => 'રાજ્ય';

  @override
  String get district => 'જિલ્લો';

  @override
  String get selectState => 'રાજ્ય પસંદ કરો';

  @override
  String get selectDistrict => 'જિલ્લો પસંદ કરો';

  @override
  String get stateRequired => 'રાજ્ય પસંદ કરવું જરૂરી છે';

  @override
  String get districtRequired => 'જિલ્લો પસંદ કરવો જરૂરી છે';

  @override
  String get pincode => 'પિનકોડ';

  @override
  String get addressLine => 'સરનામું';

  @override
  String get academicInfo => 'શૈક્ષણિક વિગતો';

  @override
  String get academicInfoSubtitle => 'વર્તમાન સંસ્થા અને અભ્યાસક્રમની વિગતો.';

  @override
  String get institutionName => 'સંસ્થાનું નામ';

  @override
  String get courseName => 'અભ્યાસક્રમ / ડિગ્રી';

  @override
  String get currentYear => 'વર્તમાન વર્ષ / વર્ગ';

  @override
  String get rollNumber => 'રોલ / રજીસ્ટ્રેશન નંબર';

  @override
  String get bankAndDocsInfo => 'બેંક ખાતું અને દસ્તાવેજો';

  @override
  String get bankAndDocsSubtitle => 'ડાયરેક્ટ બેનિફિટ ટ્રાન્સફર (DBT) વિગતો.';

  @override
  String get bankName => 'બેંકનું નામ';

  @override
  String get accountNumber => 'ખાતા નંબર';

  @override
  String get ifscCode => 'IFSC કોડ';

  @override
  String get branchName => 'શાખાનું નામ';

  @override
  String get linkDigiLockerTitle => 'ડિજીલૉકરથી દસ્તાવેજ લિંક કરો';

  @override
  String get linkDigiLockerSubtitle =>
      'તમારા ડિજીલૉકરમાંથી સરકારી દસ્તાવેજો જોડો — ડેમો';

  @override
  String get linkDigiLockerBtn => 'ડિજીલૉકરથી લિંક કરો (ડેમો)';

  @override
  String get digiLockerLinkedBanner => 'ડિજીલૉકર લિંક થયું — ડેમો';

  @override
  String get digiLockerLinkedSubtitle =>
      'ડિજીલૉકરના દસ્તાવેજો તમારા વૉલેટમાં ઉમેરાયા છે';

  @override
  String get declarationTitle => 'પ્રમાણિકતાની ઘોષણા';

  @override
  String get declarationSubtitle =>
      'હું જાહેર કરું છું કે ઉપર આપેલી તમામ માહિતી મારી જાણ મુજબ સાચી છે.';

  @override
  String get applicationSubmittedTitle => 'અરજી સબમિટ થઈ ગઈ!';

  @override
  String get applicationSubmittedMsg =>
      'તમારી શિષ્યવૃત્તિ અરજી આદિજાતિ બાબતોના મંત્રાલયને સફળતાપૂર્વક મોકલવામાં આવી છે.';

  @override
  String get keepApplicationNumber =>
      'ટ્રેકિંગ અને વેરિફિકેશન માટે આ નંબર સાચવી રાખો.';

  @override
  String get goToDashboard => 'ડેશબોર્ડ';

  @override
  String get trackApplication => 'અરજી ટ્રેક કરો';

  @override
  String get submittedDocsCount => 'સબમિટ કરેલા દસ્તાવેજો (3)';

  @override
  String get verificationStatus => 'ચકાસણી સ્થિતિ';

  @override
  String get digiLockerDemoTitle => 'ડિજીલૉકર — ડેમો';

  @override
  String get digiLockerDemoBanner => 'ડિજીલૉકર એકીકરણ — ડેમો';

  @override
  String get demoDataDisclaimer =>
      'ડેમો ડેટા: ગોપનીયતા માટે સંવેદનશીલ માહિતી છુપાવવામાં આવી છે.';

  @override
  String get connectToDigiLocker => 'ડિજીલૉકર સાથે કનેક્ટ કરો';

  @override
  String get connecting => 'કનેક્ટ થઈ રહ્યું છે...';

  @override
  String get authenticating => 'ઓથેન્ટિકેશન ચાલુ છે...';

  @override
  String get fetchingDemoDocs =>
      'ડિજીલૉકરમાંથી ડેમો દસ્તાવેજો મેળવી રહ્યા છીએ…';

  @override
  String get documentsAvailable => 'દસ્તાવેજો ઉપલબ્ધ છે';

  @override
  String get noDocumentsAvailable => 'કોઈ ડેમો દસ્તાવેજ ઉપલબ્ધ નથી';

  @override
  String get connectionFailed => 'કનેક્શન નિષ્ફળ ગયું';

  @override
  String get tryAgain => 'ફરી પ્રયાસ કરો';

  @override
  String get useSelectedDocs => 'પસંદ કરેલ દસ્તાવેજો વાપરો';

  @override
  String importDocsBtn(Object count) {
    return '$count દસ્તાવેજો આયાત કરો';
  }

  @override
  String get importComplete => 'આયાત પૂર્ણ થઈ!';

  @override
  String get continueWithLinkedDocs => 'લિંક કરેલ દસ્તાવેજો સાથે આગળ વધો';

  @override
  String get blurredForPrivacy => 'ગોપનીયતા માટે અસ્પષ્ટ કરેલ';

  @override
  String get aadhaarCard => 'આધાર કાર્ડ';

  @override
  String get casteCertificate => 'જાતિ પ્રમાણપત્ર (SEBC / ST)';

  @override
  String get marksheet12 => 'ધોરણ 12 ની માર્કશીટ';

  @override
  String get incomeCertificate => 'આવક પ્રમાણપત્ર';

  @override
  String get bonafideCertificate => 'બોનાફાઇડ સર્ટિફિકેટ';

  @override
  String get govtVerified => 'સરકારી પ્રમાણિત (ડેમો)';

  @override
  String get jagoAssistantName => 'જાગો';

  @override
  String get jagoAssistantSubtitle => 'સ્કોલરશીપ સહાયક';

  @override
  String get jagoGreeting =>
      'નમસ્તે! 🙏 હું જાગો છું, તમારો સ્કોલરશીપ સહાયક. આજે હું તમને કેવી રીતે મદદ કરી શકું?';

  @override
  String get jagoInputHint => 'સ્કોલરશીપ, સ્થિતિ અથવા દસ્તાવેજો વિશે પૂછો...';

  @override
  String get jagoQuickAppStatus => '📋 અરજીની સ્થિતિ';

  @override
  String get jagoQuickPayment => '💰 ચુકવણીની સ્થિતિ';

  @override
  String get jagoQuickDocs => '📄 દસ્તાવેજ મદદ';

  @override
  String get jagoQuickEligibility => '❓ શું હું પાત્ર છું?';

  @override
  String get notificationsTitle => 'સૂચનાઓ';

  @override
  String get noNotifications => 'હજુ સુધી કોઈ સૂચના નથી';

  @override
  String get markAllRead => 'બધી વંચાયેલ તરીકે ચિહ્નિત કરો';

  @override
  String get myProfileTitle => 'મારી પ્રોફાઇલ';

  @override
  String get editProfile => 'પ્રોફાઇલ સંપાદિત કરો';

  @override
  String get personalDetails => 'વ્યક્તિગત વિગતો';

  @override
  String get tribalDetails => 'એસટી/આદિજાતિ વિગતો';

  @override
  String get educationDetails => 'શિક્ષણ';

  @override
  String get bankDetails => 'બેંક વિગતો (DBT માટે)';

  @override
  String get settingsTitle => 'સેટિંગ્સ';

  @override
  String get preferences => 'પસંદગીઓ';

  @override
  String get language => 'ભાષા';

  @override
  String get languageSubtitle => 'ગુજરાતી (Gujarati)';

  @override
  String get security => 'સુરક્ષા';

  @override
  String get support => 'સહાય';

  @override
  String get helpAndFaq => 'મદદ અને પ્રશ્નોત્તરી';

  @override
  String get contactSupport => 'સહાયક કેન્દ્ર સંપર્ક';

  @override
  String get about => 'એપ વિશે';

  @override
  String get appVersion => 'એપ વર્ઝન';

  @override
  String get motaWebsite => 'MoTA વેબસાઇટ';

  @override
  String get statusDraft => 'ડ્રાફ્ટ';

  @override
  String get statusSubmitted => 'સબમિટ કરેલ';

  @override
  String get statusUnderReview => 'સમીક્ષા હેઠળ';

  @override
  String get statusVerified => 'ચકાસાયેલ';

  @override
  String get statusApproved => 'મંજૂર થયેલ';

  @override
  String get statusSanctioned => 'મંજૂર (સંમતિ પ્રાપ્ત)';

  @override
  String get statusDisbursed => 'ચુકવેલ';

  @override
  String get statusRejected => 'અસ્વીકૃત';

  @override
  String get statusPending => 'બાકી';

  @override
  String get selectLanguageTitle => 'ભાષા પસંદ કરો';

  @override
  String get selectLanguageSubtitle => 'અરજી માટે તમારી મનપસંદ ભાષા પસંદ કરો';

  @override
  String get myApplications => 'મારી અરજીઓ';
}
