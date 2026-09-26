// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Oriya (`or`).
class AppLocalizationsOr extends AppLocalizations {
  AppLocalizationsOr([String locale = 'or']) : super(locale);

  @override
  String get appTitle => 'Adhira';

  @override
  String get motaTitle => 'ଜନଜାତି ବ୍ୟାପାର ମନ୍ତ୍ରଣାଳୟ';

  @override
  String get motaGov => 'ଭାରତ ସରକାର';

  @override
  String get navHome => 'ମୁଖ୍ୟପୃଷ୍ଠା';

  @override
  String get navSchemes => 'ଯୋଜନା';

  @override
  String get navDocuments => 'ନଥିପତ୍ର';

  @override
  String get navJago => 'ଜାଗୋ (JAGO)';

  @override
  String get navProfile => 'ପ୍ରୋଫାଇଲ୍';

  @override
  String get welcomeBack => 'ସ୍ୱାଗତ';

  @override
  String get createAccount => 'ଖାତା ଖୋଲନ୍ତୁ';

  @override
  String get signInSubtitle =>
      'ଆପଣଙ୍କ ବୃତ୍ତି ଡ୍ୟାସବୋର୍ଡକୁ ଯିବା ପାଇଁ ସାଇନ୍ ଇନ୍ କରନ୍ତୁ';

  @override
  String get registerSubtitle =>
      'MoTA ବୃତ୍ତି ଖୋଜିବା ଏବଂ ଆବେଦନ କରିବା ପାଇଁ ପଞ୍ଜୀକରଣ କରନ୍ତୁ';

  @override
  String get mobileNumber => 'ମୋବାଇଲ୍ ନମ୍ବର';

  @override
  String get enterMobileNumber => '10-ଅଙ୍କ ବିଶିଷ୍ଟ ମୋବାଇଲ୍ ନମ୍ବର ଲେଖନ୍ତୁ';

  @override
  String get sendOtp => 'OTP ପଠାନ୍ତୁ';

  @override
  String get sendingOtp => 'OTP ପଠାଯାଉଛି...';

  @override
  String get otpVerification => 'OTP ଯାଞ୍ଚ';

  @override
  String get enterOtpSentTo => 'ଏହି ନମ୍ବରକୁ ପଠାଯାଇଥିବା 6-ଅଙ୍କର କୋଡ୍ ଦିଅନ୍ତୁ:';

  @override
  String get verifyAndProceed => 'ଯାଞ୍ଚ କରନ୍ତୁ ଏବଂ ଆଗକୁ ବଢ଼ନ୍ତୁ';

  @override
  String get verifying => 'ଯାଞ୍ଚ ଚାଲିଛି...';

  @override
  String get resendOtp => 'OTP ପୁଣି ପଠାନ୍ତୁ';

  @override
  String resendOtpIn(Object seconds) {
    return '$seconds ସେକେଣ୍ଡରେ OTP ପୁଣି ପଠାନ୍ତୁ';
  }

  @override
  String get didNotReceiveOtp => 'କୋଡ୍ ମିଳିଲା ନାହିଁ କି?';

  @override
  String get logout => 'ଲଗ୍ ଆଉଟ୍';

  @override
  String get signOut => 'ସାଇନ୍ ଆଉଟ୍';

  @override
  String get signOutConfirmTitle => 'ସାଇନ୍ ଆଉଟ୍';

  @override
  String get signOutConfirmMsg =>
      'ଆପଣ ନିଜ ଖାତାରୁ ସାଇନ୍ ଆଉଟ୍ କରିବାକୁ ନିଶ୍ଚିତ କି?';

  @override
  String get cancel => 'ବାତିଲ୍';

  @override
  String get confirm => 'ନିଶ୍ଚିତ କରନ୍ତୁ';

  @override
  String get retry => 'ପୁନଃଚେଷ୍ଟା କରନ୍ତୁ';

  @override
  String get close => 'ବନ୍ଦ କରନ୍ତୁ';

  @override
  String get back => 'ପଛକୁ';

  @override
  String get next => 'ପରବର୍ତ୍ତୀ';

  @override
  String get nextStep => 'ପରବର୍ତ୍ତୀ ପଦକ୍ଷେପ';

  @override
  String get submit => 'ଦାଖଲ କରନ୍ତୁ';

  @override
  String get saveDraft => 'ଡ୍ରାଫ୍ଟ ସାଇତନ୍ତୁ';

  @override
  String get reviewAndSubmit => 'ଯାଞ୍ଚ ଏବଂ ଦାଖଲ';

  @override
  String get view => 'ଦେଖନ୍ତୁ';

  @override
  String get change => 'ବଦଳାନ୍ତୁ';

  @override
  String get status => 'ସ୍ଥିତି';

  @override
  String get actionRequired => 'କାର୍ଯ୍ୟାନୁଷ୍ଠାନ ଆବଶ୍ୟକ';

  @override
  String namasteUser(Object name) {
    return 'ନମସ୍କାର, $name 🙏';
  }

  @override
  String profileCompletion(Object percent) {
    return 'ପ୍ରୋଫାଇଲ୍: $percent% ସମ୍ପୂର୍ଣ୍ଣ';
  }

  @override
  String get totalDisbursed => 'ମୋଟ ପ୍ରଦତ୍ତ ରାଶି';

  @override
  String get pendingDisbursement => 'ବାକି ଥିବା ପ୍ରଦାନ';

  @override
  String get activeApplications => 'ସକ୍ରିୟ ଆବେଦନ';

  @override
  String get quickActions => 'ତ୍ୱରିତ କାର୍ଯ୍ୟ';

  @override
  String get applyScheme => 'ଯୋଜନା ପାଇଁ ଆବେଦନ';

  @override
  String get trackStatus => 'ସ୍ଥିତି ଯାଞ୍ଚ କରନ୍ତୁ';

  @override
  String get docWallet => 'ନଥିପତ୍ର ୱାଲେଟ୍';

  @override
  String get eligibilityCheck => 'ଯୋଗ୍ୟତା ଯାଞ୍ଚ';

  @override
  String get jagoAssistant => 'ଜାଗୋ ସହାୟକ';

  @override
  String get recentActivity => 'ସାମ୍ପ୍ରତିକ କାର୍ଯ୍ୟକଳାପ';

  @override
  String get scholarshipSchemes => 'ଛାତ୍ରବୃତ୍ତି ଯୋଜନା';

  @override
  String get allSchemes => 'ସମସ୍ତ ଯୋଜନା';

  @override
  String get preMatric => 'ପ୍ରାକ୍-ମାଟ୍ରିକ୍ ବୃତ୍ତି';

  @override
  String get preMatricDesc =>
      '୯ମ ଏବଂ ୧୦ମ ଶ୍ରେଣୀର ଏସଟି ଛାତ୍ରଛାତ୍ରୀଙ୍କ ପାଇଁ ଆର୍ଥିକ ସହାୟତା';

  @override
  String get postMatric => 'ପୋଷ୍ଟ-ମାଟ୍ରିକ୍ ବୃତ୍ତି';

  @override
  String get postMatricDesc =>
      'ଉଚ୍ଚଶିକ୍ଷା ପାଇଁ ଏସଟି ଛାତ୍ରଛାତ୍ରୀଙ୍କ ନିମନ୍ତେ ଛାତ୍ରବୃତ୍ତି';

  @override
  String get topClass => 'ଟପ୍ କ୍ଲାସ୍ ଶିକ୍ଷା';

  @override
  String get topClassDesc =>
      'ଶ୍ରେଷ୍ଠ ଜାତୀୟ ଅନୁଷ୍ଠାନରେ ଏସଟି ଛାତ୍ରଛାତ୍ରୀଙ୍କୁ ସମ୍ପୂର୍ଣ୍ଣ ସହାୟତା';

  @override
  String get nfst => 'ଜାତୀୟ ଫେଲୋସିପ୍ (NFST)';

  @override
  String get nfstDesc => 'ଏମ୍.ଫିଲ୍ ଏବଂ ପିଏଚ୍.ଡି ଗବେଷକଙ୍କ ପାଇଁ ଫେଲୋସିପ୍';

  @override
  String get nos => 'ଜାତୀୟ ବିଦେଶୀ ବୃତ୍ତି (NOS)';

  @override
  String get nosDesc =>
      'ବିଦେଶରେ ଉଚ୍ଚଶିକ୍ଷା ନିମନ୍ତେ ଏସଟି ଛାତ୍ରଛାତ୍ରୀଙ୍କୁ ସହାୟତା';

  @override
  String get applyNow => 'ଏବେ ଆବେଦନ କରନ୍ତୁ';

  @override
  String get schemeDetails => 'ଯୋଜନା ବିବରଣୀ';

  @override
  String get benefits => 'ଲାଭ';

  @override
  String get eligibilityCriteria => 'ଯୋଗ୍ୟତା ମାନଦଣ୍ଡ';

  @override
  String get requiredDocuments => 'ଆବଶ୍ୟକ ନଥିପତ୍ର';

  @override
  String get applicationDeadline => 'ଆବେଦନର ଶେଷ ତାରିଖ';

  @override
  String get applicationFormTitle => 'ଛାତ୍ରବୃତ୍ତି ଆବେଦନ';

  @override
  String get stepPersonal => 'ବ୍ୟକ୍ତିଗତ';

  @override
  String get stepAddress => 'ଠିକଣା';

  @override
  String get stepAcademic => 'ଶିକ୍ଷାଗତ';

  @override
  String get stepBankDocs => 'ବ୍ୟାଙ୍କ ଏବଂ ନଥିପତ୍ର';

  @override
  String get stepReview => 'ସମୀକ୍ଷା';

  @override
  String get personalInfo => 'ବ୍ୟକ୍ତିଗତ ସୂଚନା';

  @override
  String get personalInfoSubtitle => 'ଆଧାର ଓ ଡିଜିଲକରରୁ ଯାଞ୍ଚ ହୋଇଥିବା ତଥ୍ୟ।';

  @override
  String get fullName => 'ପୂରା ନାମ';

  @override
  String get fatherName => 'ପିତାଙ୍କ ନାମ';

  @override
  String get motherName => 'ମାତାଙ୍କ ନାମ';

  @override
  String get dateOfBirth => 'ଜନ୍ମ ତାରିଖ';

  @override
  String get gender => 'ଲିଙ୍ଗ';

  @override
  String get male => 'ପୁରୁଷ';

  @override
  String get female => 'ମହିଳା';

  @override
  String get other => 'ଅନ୍ୟାନ୍ୟ';

  @override
  String get category => 'ବର୍ଗ';

  @override
  String get tribeName => 'ଜନଜାତିର ନାମ';

  @override
  String get pvtgStatus => 'ବିଶେଷ ଦୁର୍ବଳ ଜନଜାତି ଗୋଷ୍ଠୀ (PVTG)';

  @override
  String get yes => 'ହଁ';

  @override
  String get no => 'ନାହିଁ';

  @override
  String get addressInfo => 'ଠିକଣା ଏବଂ ବାସସ୍ଥାନ';

  @override
  String get addressInfoSubtitle => 'ସ୍ଥାୟୀ ଏବଂ ଯୋଗାଯୋଗ ଠିକଣା।';

  @override
  String get state => 'ରାଜ୍ୟ';

  @override
  String get district => 'ଜିଲ୍ଲା';

  @override
  String get selectState => 'ରାଜ୍ୟ ବାଛନ୍ତୁ';

  @override
  String get selectDistrict => 'ଜିଲ୍ଲା ବାଛନ୍ତୁ';

  @override
  String get stateRequired => 'ରାଜ୍ୟ ବାଛିବା ଆବଶ୍ୟକ';

  @override
  String get districtRequired => 'ଜିଲ୍ଲା ବାଛିବା ଆବଶ୍ୟକ';

  @override
  String get pincode => 'ପିନକୋଡ୍';

  @override
  String get addressLine => 'ଠିକଣା ଧାଡ଼ି';

  @override
  String get academicInfo => 'ଶିକ୍ଷାଗତ ତଥ୍ୟ';

  @override
  String get academicInfoSubtitle => 'ବର୍ତ୍ତମାନର ଅନୁଷ୍ଠାନ ଏବଂ ପାଠ୍ୟକ୍ରମ ସୂଚନା।';

  @override
  String get institutionName => 'ଅନୁଷ୍ଠାନର ନାମ';

  @override
  String get courseName => 'ପାଠ୍ୟକ୍ରମ / ଡିଗ୍ରୀ';

  @override
  String get currentYear => 'ଚଳିତ ବର୍ଷ / ଶ୍ରେଣୀ';

  @override
  String get rollNumber => 'ରୋଲ୍ / ପଞ୍ଜୀକରଣ ନମ୍ବର';

  @override
  String get bankAndDocsInfo => 'ବ୍ୟାଙ୍କ ଖାତା ଏବଂ ନଥିପତ୍ର';

  @override
  String get bankAndDocsSubtitle => 'ପ୍ରତ୍ୟକ୍ଷ ଲାଭ ହସ୍ତାନ୍ତର (DBT) ବିବରଣୀ।';

  @override
  String get bankName => 'ବ୍ୟାଙ୍କର ନାମ';

  @override
  String get accountNumber => 'ଖାତା ନମ୍ବର';

  @override
  String get ifscCode => 'IFSC କୋଡ୍';

  @override
  String get branchName => 'ଶାଖାର ନାମ';

  @override
  String get linkDigiLockerTitle => 'ଡିଜିଲକରରୁ ନଥିପତ୍ର ସଂଯୋଗ କରନ୍ତୁ';

  @override
  String get linkDigiLockerSubtitle =>
      'ଡିଜିଲକରରୁ ସରକାରୀ ପ୍ରମାଣପତ୍ର ଯୋଡନ୍ତୁ — ଡେମୋ';

  @override
  String get linkDigiLockerBtn => 'ଡିଜିଲକରରୁ ଯୋଡ଼ନ୍ତୁ (ଡେମୋ)';

  @override
  String get digiLockerLinkedBanner => 'ଡିଜିଲକର ଯୋଡ଼ାଗଲା — ଡେମୋ';

  @override
  String get digiLockerLinkedSubtitle =>
      'ଡିଜିଲକର ନଥିପତ୍ର ଆପଣଙ୍କ ୱାଲେଟରେ ଯୋଡ଼ାଯାଇଛି';

  @override
  String get declarationTitle => 'ସତ୍ୟତାର ଘୋଷଣା';

  @override
  String get declarationSubtitle =>
      'ମୁଁ ଘୋଷଣା କରୁଛି ଯେ ଉପରୋକ୍ତ ସମସ୍ତ ସୂଚନା ମୋ ଜାଣିବାରେ ସତ୍ୟ ଅଟେ।';

  @override
  String get applicationSubmittedTitle => 'ଆବେଦନ ଦାଖଲ ହେଲା!';

  @override
  String get applicationSubmittedMsg =>
      'ଆପଣଙ୍କ ଛାତ୍ରବୃତ୍ତି ଆବେଦନ ଜନଜାତି ବ୍ୟାପାର ମନ୍ତ୍ରଣାଳୟକୁ ସଫଳତାର ସହ ପଠାଯାଇଛି।';

  @override
  String get keepApplicationNumber =>
      'ଯାଞ୍ଚ ଏବଂ ଟ୍ରାକିଂ ପାଇଁ ଏହି ନମ୍ବର ସୁରକ୍ଷିତ ରଖନ୍ତୁ।';

  @override
  String get goToDashboard => 'ଡ୍ୟାସବୋର୍ଡ';

  @override
  String get trackApplication => 'ଆବେଦନ ଟ୍ରାକ୍ କରନ୍ତୁ';

  @override
  String get submittedDocsCount => 'ଦାଖଲ ହୋଇଥିବା ନଥିପତ୍ର (3)';

  @override
  String get verificationStatus => 'ଯାଞ୍ଚ ସ୍ଥିତି';

  @override
  String get digiLockerDemoTitle => 'ଡିଜିଲକର — ଡେମୋ';

  @override
  String get digiLockerDemoBanner => 'ଡିଜିଲକର ସଂଯୋଗ — ଡେମୋ';

  @override
  String get demoDataDisclaimer =>
      'ଡେମୋ ତଥ୍ୟ: ଗୋପନୀୟତା ରକ୍ଷା ପାଇଁ ସମ୍ବେଦନଶୀଳ ସୂଚନା ଲୁଚାଯାଇଛି।';

  @override
  String get connectToDigiLocker => 'ଡିଜିଲକର ସହିତ ସଂଯୋଗ କରନ୍ତୁ';

  @override
  String get connecting => 'ସଂଯୋଗ ହେଉଛି...';

  @override
  String get authenticating => 'ପ୍ରମାଣୀକରଣ ଚାଲିଛି...';

  @override
  String get fetchingDemoDocs => 'ଡିଜିଲକରରୁ ଡେମୋ ନଥିପତ୍ର ଅଣାଯାଉଛି…';

  @override
  String get documentsAvailable => 'ନଥିପତ୍ର ଉପଲବ୍ଧ ଅଛି';

  @override
  String get noDocumentsAvailable => 'କୌଣସି ଡେମୋ ନଥିପତ୍ର ଉପଲବ୍ଧ ନାହିଁ';

  @override
  String get connectionFailed => 'ସଂଯୋଗ ବିଫଳ ହେଲା';

  @override
  String get tryAgain => 'ପୁନଃଚେଷ୍ଟା କରନ୍ତୁ';

  @override
  String get useSelectedDocs => 'ଚୟନିତ ନଥିପତ୍ର ବ୍ୟବହାର କରନ୍ତୁ';

  @override
  String importDocsBtn(Object count) {
    return '$countଟି ନଥିପତ୍ର ଆମଦାନୀ କରନ୍ତୁ';
  }

  @override
  String get importComplete => 'ଆମଦାନୀ ସମ୍ପୂର୍ଣ୍ଣ ହେଲା!';

  @override
  String get continueWithLinkedDocs => 'ସଂଯୁକ୍ତ ନଥିପତ୍ର ସହିତ ଆଗକୁ ବଢ଼ନ୍ତୁ';

  @override
  String get blurredForPrivacy => 'ଗୋପନୀୟତା ପାଇଁ ଅସ୍ପଷ୍ଟ';

  @override
  String get aadhaarCard => 'ଆଧାର କାର୍ଡ';

  @override
  String get casteCertificate => 'ଜାତି ପ୍ରମାଣପତ୍ର (SEBC / ST)';

  @override
  String get marksheet12 => 'ଦ୍ୱାଦଶ ଶ୍ରେଣୀ ମାର୍କସିଟ୍';

  @override
  String get incomeCertificate => 'ଆୟ ପ୍ରମାଣପତ୍ର';

  @override
  String get bonafideCertificate => 'ବୋନାଫାଇଡ୍ ପ୍ରମାଣପତ୍ର';

  @override
  String get govtVerified => 'ସରକାରୀ ଯାଞ୍ଚ ହୋଇଛି (ଡେମୋ)';

  @override
  String get jagoAssistantName => 'ଜାଗୋ';

  @override
  String get jagoAssistantSubtitle => 'ଛାତ୍ରବୃତ୍ତି ସହାୟକ';

  @override
  String get jagoGreeting =>
      'ନମସ୍କାର! 🙏 ମୁଁ ଜାଗୋ, ଆପଣଙ୍କ ଛାତ୍ରବୃତ୍ତି ସହାୟକ। ଆଜି ମୁଁ ଆପଣଙ୍କୁ କିପରି ସାହାଯ୍ୟ କରିପାରିବି?';

  @override
  String get jagoInputHint =>
      'ଛାତ୍ରବୃତ୍ତି, ସ୍ଥିତି କିମ୍ବା ନଥିପତ୍ର ବିଷୟରେ ପଚାରନ୍ତୁ...';

  @override
  String get jagoQuickAppStatus => '📋 ଆବେଦନ ସ୍ଥିତି';

  @override
  String get jagoQuickPayment => '💰 ପ୍ରଦାନ ସ୍ଥିତି';

  @override
  String get jagoQuickDocs => '📄 ନଥିପତ୍ର ସହାୟତା';

  @override
  String get jagoQuickEligibility => '❓ ମୁଁ ଯୋଗ୍ୟ କି?';

  @override
  String get notificationsTitle => 'ବିଜ୍ଞପ୍ତି';

  @override
  String get noNotifications => 'କୌଣସି ନୂତନ ବିଜ୍ଞପ୍ତି ନାହିଁ';

  @override
  String get markAllRead => 'ସମସ୍ତ ପଢ଼ାଗଲା ବୋଲି ଚିହ୍ନିତ କରନ୍ତୁ';

  @override
  String get myProfileTitle => 'ମୋ ପ୍ରୋଫାଇଲ୍';

  @override
  String get editProfile => 'ପ୍ରୋଫାଇଲ୍ ସଂଶୋଧନ';

  @override
  String get personalDetails => 'ବ୍ୟକ୍ତିଗତ ବିବରଣୀ';

  @override
  String get tribalDetails => 'ଏସଟି/ଜନଜାତି ବିବରଣୀ';

  @override
  String get educationDetails => 'ଶିକ୍ଷା';

  @override
  String get bankDetails => 'ବ୍ୟାଙ୍କ ବିବରଣୀ (DBT ନିମନ୍ତେ)';

  @override
  String get settingsTitle => 'ସେଟିଙ୍ଗସ୍';

  @override
  String get preferences => 'ପସନ୍ଦ';

  @override
  String get language => 'ଭାଷା';

  @override
  String get languageSubtitle => 'ଓଡ଼ିଆ (Odia)';

  @override
  String get security => 'ସୁରକ୍ଷା';

  @override
  String get support => 'ସହାୟତା';

  @override
  String get helpAndFaq => 'ସାହାଯ୍ୟ ଏବଂ ପ୍ରଶ୍ନୋତ୍ତର';

  @override
  String get contactSupport => 'ସହାୟତା କେନ୍ଦ୍ର ଯୋଗାଯୋଗ';

  @override
  String get about => 'ଆପ୍ ବିଷୟରେ';

  @override
  String get appVersion => 'ଆପ୍ ସଂସ୍କରଣ';

  @override
  String get motaWebsite => 'MoTA ୱେବସାଇଟ୍';

  @override
  String get statusDraft => 'ଡ୍ରାଫ୍ଟ';

  @override
  String get statusSubmitted => 'ଦାଖଲ ହୋଇଛି';

  @override
  String get statusUnderReview => 'ସମୀକ୍ଷାଧୀନ';

  @override
  String get statusVerified => 'ଯାଞ୍ଚ ହୋଇଛି';

  @override
  String get statusApproved => 'ଅନୁମୋଦିତ';

  @override
  String get statusSanctioned => 'ମଞ୍ଜୁର ହୋଇଛି';

  @override
  String get statusDisbursed => 'ପ୍ରଦତ୍ତ';

  @override
  String get statusRejected => 'ପ୍ରତ୍ୟାଖ୍ୟାତ';

  @override
  String get statusPending => 'ବାକି ଅଛି';

  @override
  String get selectLanguageTitle => 'ଭାଷା ଚୟନ କରନ୍ତୁ';

  @override
  String get selectLanguageSubtitle => 'ଆବେଦନ ପାଇଁ ନିଜ ପସନ୍ଦର ଭାଷା ବାଛନ୍ତୁ';

  @override
  String get myApplications => 'ମୋର ଆବେଦନଗୁଡ଼ିକ';

  @override
  String get jagoLanguageTitle => 'ଜାଗୋ ଭାଷା';

  @override
  String get jagoUseAppLanguage => 'ଆପ୍ ଭାଷା ବ୍ୟବହାର କରନ୍ତୁ';

  @override
  String get jagoLanguageOverrideHint =>
      'ଜାଗୋ ଏକ ଭିନ୍ନ ଭାଷା ବ୍ୟବହାର କରୁଛି। ଆପ୍ ଭାଷା ଅନୁସରଣ କରିବାକୁ \"ଆପ୍ ଭାଷା ବ୍ୟବହାର କରନ୍ତୁ\" ଟ୍ୟାପ କରନ୍ତୁ।';

  @override
  String get jagoLanguageDefaultHint =>
      'ଜାଗୋ ଆପ୍ ଭାଷା ଅନୁସରଣ କରେ। କେବଳ ଜାଗୋ ପାଇଁ ଏକ ଭିନ୍ନ ଭାଷା ବାଛନ୍ତୁ।';

  @override
  String get jagoContextApplicationTracking =>
      'ମୁଁ ଏହି ଆବେଦନରେ ଆପଣଙ୍କୁ ସାହାଯ୍ୟ କରିପାରିବି।';

  @override
  String get jagoContextEligibility =>
      'ମୁଁ ଛାତ୍ରବୃତ୍ତି ଯୋଜନା ପାଇଁ ଆପଣଙ୍କ ଯୋଗ୍ୟତା ଯାଞ୍ଚ କରିବାରେ ସାହାଯ୍ୟ କରିପାରିବି।';

  @override
  String get jagoContextDocuments =>
      'ମୁଁ ଆପଣଙ୍କ ଦଲିଲ ବିଷୟରେ ସାହାଯ୍ୟ କରିପାରିବି।';

  @override
  String get jagoContextPayments =>
      'ମୁଁ ଆପଣଙ୍କ ଦେୟ ଏବଂ DBT ସ୍ଥିତି ବିଷୟରେ ସାହାଯ୍ୟ କରିପାରିବି।';

  @override
  String get jagoSuggestionEligibility => 'ମୋ ଯୋଗ୍ୟତା ଯାଞ୍ଚ କରନ୍ତୁ';

  @override
  String get jagoSuggestionTrack => 'ମୋ ଆବେଦନ ଟ୍ରାକ୍ କରନ୍ତୁ';

  @override
  String get jagoSuggestionDocs => 'ମୋତେ କେଉଁ ଦଲିଲ ଦରକାର?';

  @override
  String get jagoSuggestionPending => 'କେଉଁ ଦଲିଲ ବାକି ଅଛି?';

  @override
  String get jagoSuggestionPayment => 'ମୋ ଦେୟ ସ୍ଥିତି ଯାଞ୍ଚ କରନ୍ତୁ';

  @override
  String get jagoSuggestionWhichScholarship =>
      'ମୁଁ କେଉଁ ଛାତ୍ରବୃତ୍ତି ପାଇଁ ଆବେଦନ କରୁଛି?';

  @override
  String get jagoNavPromptApplications =>
      'ଆପଣ ଚାହୁଛନ୍ତି ମୁଁ ଆବେଦନ ଟ୍ରାକିଂ ଖୋଲିବି?';

  @override
  String get jagoNavPromptDocuments => 'ଆପଣ ଚାହୁଛନ୍ତି ମୁଁ ଦଲିଲ ୱାଲେଟ ଖୋଲିବି?';

  @override
  String get jagoNavPromptPayments => 'ଆପଣ ଚାହୁଛନ୍ତି ମୁଁ ଦେୟ ବିଭାଗ ଖୋଲିବି?';

  @override
  String get jagoNavPromptEligibility =>
      'ଆପଣ ଚାହୁଛନ୍ତି ମୁଁ ଯୋଗ୍ୟତା ଯାଞ୍ଚ ଖୋଲିବି?';

  @override
  String get jagoAskJago => 'ଜାଗୋକୁ ପଚାରନ୍ତୁ';

  @override
  String get jagoNeedHelp => 'ଏହି ଆବେଦନରେ ସାହାଯ୍ୟ ଦରକାର?';

  @override
  String get jagoNeedHelpSubtitle =>
      'ଜାଗୋ AI କୁ ପଚାରନ୍ତୁ ବା ଆପଣଙ୍କ ଜିଲ୍ଲା ଉପଜାତି ଅଧିକାରୀଙ୍କ ସହ ଯୋଗାଯୋଗ କରନ୍ତୁ।';

  @override
  String jagoOpenedFrom(Object screen) {
    return 'ଖୋଲାଗଲା: $screen';
  }
}
