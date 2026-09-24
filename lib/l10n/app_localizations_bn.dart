// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([String locale = 'bn']) : super(locale);

  @override
  String get appTitle => 'ট্রাইবাল স্কলার সাথী';

  @override
  String get motaTitle => 'জনজাতি বিষয়ক মন্ত্রক';

  @override
  String get motaGov => 'ভারত সরকার';

  @override
  String get navHome => 'হোম';

  @override
  String get navSchemes => 'প্রকল্পসমূহ';

  @override
  String get navDocuments => 'নথিপত্র';

  @override
  String get navJago => 'জাগো (JAGO)';

  @override
  String get navProfile => 'প্রোফাইল';

  @override
  String get welcomeBack => 'স্বাগতম';

  @override
  String get createAccount => 'অ্যাকাউন্ট তৈরি করুন';

  @override
  String get signInSubtitle => 'স্কলারশিপ ড্যাশবোর্ডে যেতে সাইন ইন করুন';

  @override
  String get registerSubtitle =>
      'MoTA স্কলারশিপ দেখতে এবং আবেদন করতে নিবন্ধন করুন';

  @override
  String get mobileNumber => 'মোবাইল নম্বর';

  @override
  String get enterMobileNumber => '১০-সংখ্যার মোবাইল নম্বর লিখুন';

  @override
  String get sendOtp => 'ওটিপি পাঠান';

  @override
  String get sendingOtp => 'ওটিপি পাঠানো হচ্ছে...';

  @override
  String get otpVerification => 'ওটিপি যাচাইকরণ';

  @override
  String get enterOtpSentTo => 'এই নম্বরে পাঠানো ৬-সংখ্যার কোডটি লিখুন:';

  @override
  String get verifyAndProceed => 'যাচাই করুন এবং এগিয়ে যান';

  @override
  String get verifying => 'যাচাই করা হচ্ছে...';

  @override
  String get resendOtp => 'ওটিপি পুনরায় পাঠান';

  @override
  String resendOtpIn(Object seconds) {
    return '$seconds সেকেন্ডে ওটিপি পুনরায় পাঠান';
  }

  @override
  String get didNotReceiveOtp => 'কোড পাননি?';

  @override
  String get logout => 'লগআউট';

  @override
  String get signOut => 'সাইন আউট';

  @override
  String get signOutConfirmTitle => 'সাইন আউট';

  @override
  String get signOutConfirmMsg => 'আপনি কি সত্যিই সাইন আউট করতে চান?';

  @override
  String get cancel => 'বাতিল';

  @override
  String get confirm => 'নিশ্চিত করুন';

  @override
  String get retry => 'পুনরায় চেষ্টা করুন';

  @override
  String get close => 'বন্ধ করুন';

  @override
  String get back => 'পেছনে';

  @override
  String get next => 'পরবর্তী';

  @override
  String get nextStep => 'পরবর্তী ধাপ';

  @override
  String get submit => 'জমা দিন';

  @override
  String get saveDraft => 'খসড়া সংরক্ষণ করুন';

  @override
  String get reviewAndSubmit => 'পর্যালোচনা ও জমা দিন';

  @override
  String get view => 'দেখুন';

  @override
  String get change => 'পরিবর্তন করুন';

  @override
  String get status => 'অবস্থা';

  @override
  String get actionRequired => 'পদক্ষেপ প্রয়োজন';

  @override
  String namasteUser(Object name) {
    return 'নমস্কার, $name 🙏';
  }

  @override
  String profileCompletion(Object percent) {
    return 'প্রোফাইল: $percent% সম্পূর্ণ';
  }

  @override
  String get totalDisbursed => 'মোট প্রাপ্ত অর্থ';

  @override
  String get pendingDisbursement => 'বকেয়া অর্থপ্রদান';

  @override
  String get activeApplications => 'সক্রিয় আবেদন';

  @override
  String get quickActions => 'দ্রুত পদক্ষেপ';

  @override
  String get applyScheme => 'প্রকল্পে আবেদন করুন';

  @override
  String get trackStatus => 'অবস্থা ট্র্যাক করুন';

  @override
  String get docWallet => 'নথিপত্র ওয়ালেট';

  @override
  String get eligibilityCheck => 'যোগ্যতা যাচাই';

  @override
  String get jagoAssistant => 'জাগো সহকারী';

  @override
  String get recentActivity => 'সাম্প্রতিক কার্যকলাপ';

  @override
  String get scholarshipSchemes => 'স্কলারশিপ প্রকল্প';

  @override
  String get allSchemes => 'সকল প্রকল্প';

  @override
  String get preMatric => 'প্রি-ম্যাট্রিক স্কলারশিপ';

  @override
  String get preMatricDesc =>
      'নবম ও দশম শ্রেণীর এসটি শিক্ষার্থীদের জন্য আর্থিক সাহায্য';

  @override
  String get postMatric => 'পোস্ট-ম্যাট্রিক স্কলারশিপ';

  @override
  String get postMatricDesc => 'উচ্চশিক্ষার জন্য এসটি শিক্ষার্থীদের স্কলারশিপ';

  @override
  String get topClass => 'টপ ক্লাস এডুকেশন';

  @override
  String get topClassDesc =>
      'শীর্ষ জাতীয় প্রতিষ্ঠানে এসটি শিক্ষার্থীদের সম্পূর্ণ সহায়তা';

  @override
  String get nfst => 'জাতীয় ফেলোশিপ (NFST)';

  @override
  String get nfstDesc => 'এম.ফিল এবং পিএইচ.ডি গবেষকদের জন্য ফেলোশিপ';

  @override
  String get nos => 'জাতীয় ওভারসিজ স্কলারশিপ (NOS)';

  @override
  String get nosDesc =>
      'বিদেশে উচ্চশিক্ষার জন্য এসটি শিক্ষার্থীদের আর্থিক সহায়তা';

  @override
  String get applyNow => 'এখনই আবেদন করুন';

  @override
  String get schemeDetails => 'প্রকল্পের বিবরণ';

  @override
  String get benefits => 'সুবিধাসমূহ';

  @override
  String get eligibilityCriteria => 'যোগ্যতার মাপকাঠি';

  @override
  String get requiredDocuments => 'প্রয়োজনীয় নথিপত্র';

  @override
  String get applicationDeadline => 'আবেদনের শেষ তারিখ';

  @override
  String get applicationFormTitle => 'স্কলারশিপ আবেদন';

  @override
  String get stepPersonal => 'ব্যক্তিগত';

  @override
  String get stepAddress => 'ঠিকানা';

  @override
  String get stepAcademic => 'শিক্ষাগত';

  @override
  String get stepBankDocs => 'ব্যাঙ্ক ও নথিপত্র';

  @override
  String get stepReview => 'পর্যালোচনা';

  @override
  String get personalInfo => 'ব্যক্তিগত তথ্য';

  @override
  String get personalInfoSubtitle => 'আধার এবং ডিজিলকার থেকে যাচাইকৃত তথ্য।';

  @override
  String get fullName => 'পুরো নাম';

  @override
  String get fatherName => 'পিতার নাম';

  @override
  String get motherName => 'মাতার নাম';

  @override
  String get dateOfBirth => 'জন্ম তারিখ';

  @override
  String get gender => 'লিঙ্গ';

  @override
  String get male => 'পুরুষ';

  @override
  String get female => 'মহিলা';

  @override
  String get other => 'অন্যান্য';

  @override
  String get category => 'বিভাগ';

  @override
  String get tribeName => 'উপজাতির নাম';

  @override
  String get pvtgStatus => 'বিশেষভাবে দুর্বল আদিবাসী গোষ্ঠী (PVTG)';

  @override
  String get yes => 'হ্যাঁ';

  @override
  String get no => 'না';

  @override
  String get addressInfo => 'ঠিকানা ও বাসস্থান';

  @override
  String get addressInfoSubtitle => 'স্থায়ী এবং যোগাযোগের ঠিকানা।';

  @override
  String get state => 'রাজ্য';

  @override
  String get district => 'জেলা';

  @override
  String get selectState => 'রাজ্য নির্বাচন করুন';

  @override
  String get selectDistrict => 'জেলা নির্বাচন করুন';

  @override
  String get stateRequired => 'রাজ্য নির্বাচন করা আবশ্যক';

  @override
  String get districtRequired => 'জেলা নির্বাচন করা আবশ্যক';

  @override
  String get pincode => 'পিনকোড';

  @override
  String get addressLine => 'ঠিকানার লাইন';

  @override
  String get academicInfo => 'শিক্ষাগত বিবরণ';

  @override
  String get academicInfoSubtitle => 'বর্তমান প্রতিষ্ঠান এবং কোর্সের তথ্য।';

  @override
  String get institutionName => 'প্রতিষ্ঠানের নাম';

  @override
  String get courseName => 'কোর্স / ডিগ্রি';

  @override
  String get currentYear => 'বর্তমান বর্ষ / শ্রেণী';

  @override
  String get rollNumber => 'রোল / নিবন্ধন নম্বর';

  @override
  String get bankAndDocsInfo => 'ব্যাঙ্ক অ্যাকাউন্ট ও নথিপত্র';

  @override
  String get bankAndDocsSubtitle => 'প্রত্যক্ষ সুবিধা স্থানান্তর (DBT) বিবরণ।';

  @override
  String get bankName => 'ব্যাঙ্কের নাম';

  @override
  String get accountNumber => 'অ্যাকাউন্ট নম্বর';

  @override
  String get ifscCode => 'IFSC কোড';

  @override
  String get branchName => 'শাখার নাম';

  @override
  String get linkDigiLockerTitle => 'ডিজিলকার থেকে নথি সংযুক্ত করুন';

  @override
  String get linkDigiLockerSubtitle =>
      'আপনার ডিজিলকার থেকে সরকারী নথি সংযুক্ত করুন — ডেমো';

  @override
  String get linkDigiLockerBtn => 'ডিজিলকার থেকে লিঙ্ক করুন (ডেমো)';

  @override
  String get digiLockerLinkedBanner => 'ডিজিলকার সংযুক্ত হয়েছে — ডেমো';

  @override
  String get digiLockerLinkedSubtitle =>
      'ডিজিলকারের নথিপত্র আপনার ওয়ালেটে যোগ করা হয়েছে';

  @override
  String get declarationTitle => 'সত্যতার ঘোষণা';

  @override
  String get declarationSubtitle =>
      'আমি ঘোষণা করছি যে উপরে প্রদত্ত সমস্ত তথ্য আমার জ্ঞানমতে সত্য ও নির্ভুল।';

  @override
  String get applicationSubmittedTitle => 'আবেদন জমা হয়েছে!';

  @override
  String get applicationSubmittedMsg =>
      'আপনার স্কলারশিপ আবেদনটি জনজাতি বিষয়ক মন্ত্রকে সফলভাবে জমা দেওয়া হয়েছে।';

  @override
  String get keepApplicationNumber =>
      'ট্র্যাকিং ও যাচাইয়ের জন্য এই আবেদন নম্বরটি সংরক্ষণ করুন।';

  @override
  String get goToDashboard => 'ড্যাশবোর্ড';

  @override
  String get trackApplication => 'আবেদন ট্র্যাক করুন';

  @override
  String get submittedDocsCount => 'জমা দেওয়া নথিপত্র (৩)';

  @override
  String get verificationStatus => 'যাচাইয়ের অবস্থা';

  @override
  String get digiLockerDemoTitle => 'ডিজিলকার — ডেমো';

  @override
  String get digiLockerDemoBanner => 'ডিজিলকার ইন্টিগ্রেশন — ডেমো';

  @override
  String get demoDataDisclaimer =>
      'ডেমো ডেটা: গোপনীয়তার জন্য সংবেদনশীল তথ্য গোপন রাখা হয়েছে।';

  @override
  String get connectToDigiLocker => 'ডিজিলকারের সাথে সংযুক্ত করুন';

  @override
  String get connecting => 'সংযোগ করা হচ্ছে...';

  @override
  String get authenticating => 'প্রমাণীকরণ চলছে...';

  @override
  String get fetchingDemoDocs => 'ডিজিলকার থেকে ডেমো নথি আনা হচ্ছে…';

  @override
  String get documentsAvailable => 'নথিপত্র উপলব্ধ আছে';

  @override
  String get noDocumentsAvailable => 'কোন ডেমো নথি পাওয়া যায়নি';

  @override
  String get connectionFailed => 'সংযোগ ব্যর্থ হয়েছে';

  @override
  String get tryAgain => 'পুনরায় চেষ্টা করুন';

  @override
  String get useSelectedDocs => 'নির্বাচিত নথিপত্র ব্যবহার করুন';

  @override
  String importDocsBtn(Object count) {
    return '$countটি নথি আমদানি করুন';
  }

  @override
  String get importComplete => 'আমদানি সম্পন্ন!';

  @override
  String get continueWithLinkedDocs => 'সংযুক্ত নথিপত্র নিয়ে এগিয়ে যান';

  @override
  String get blurredForPrivacy => 'গোপনীয়তার জন্য অস্পষ্ট';

  @override
  String get aadhaarCard => 'আধার কার্ড';

  @override
  String get casteCertificate => 'জাতিগত শংসাপত্র (SEBC / ST)';

  @override
  String get marksheet12 => 'দ্বাদশ শ্রেণীর মার্কশিট';

  @override
  String get incomeCertificate => 'আয় শংসাপত্র';

  @override
  String get bonafideCertificate => 'বোনাফাইড শংসাপত্র';

  @override
  String get govtVerified => 'সরকারি যাচাইকৃত (ডেমো)';

  @override
  String get jagoAssistantName => 'জাগো';

  @override
  String get jagoAssistantSubtitle => 'স্কলারশিপ সহকারী';

  @override
  String get jagoGreeting =>
      'নমস্কার! 🙏 আমি জাগো, আপনার স্কলারশিপ সহকারী। আজ আমি আপনাকে কীভাবে সাহায্য করতে পারি?';

  @override
  String get jagoInputHint =>
      'স্কলারশিপ, অবস্থা বা নথিপত্র সম্পর্কে জিজ্ঞাসা করুন...';

  @override
  String get jagoQuickAppStatus => '📋 আবেদনের অবস্থা';

  @override
  String get jagoQuickPayment => '💰 পেমেন্ট অবস্থা';

  @override
  String get jagoQuickDocs => '📄 নথিপত্র সহায়তা';

  @override
  String get jagoQuickEligibility => '❓ আমি কি যোগ্য?';

  @override
  String get notificationsTitle => 'বিজ্ঞপ্তি';

  @override
  String get noNotifications => 'কোন বিজ্ঞপ্তি নেই';

  @override
  String get markAllRead => 'সব পঠিত হিসেবে চিহ্নিত করুন';

  @override
  String get myProfileTitle => 'আমার প্রোফাইল';

  @override
  String get editProfile => 'প্রোফাইল সম্পাদনা';

  @override
  String get personalDetails => 'ব্যক্তিগত বিবরণ';

  @override
  String get tribalDetails => 'এসটি/জনজাতি বিবরণ';

  @override
  String get educationDetails => 'শিক্ষা';

  @override
  String get bankDetails => 'ব্যাঙ্ক বিবরণ (DBT এর জন্য)';

  @override
  String get settingsTitle => 'সেটিংস';

  @override
  String get preferences => 'পছন্দসমূহ';

  @override
  String get language => 'ভাষা';

  @override
  String get languageSubtitle => 'বাংলা (Bengali)';

  @override
  String get security => 'নিরাপত্তা';

  @override
  String get support => 'সহায়তা';

  @override
  String get helpAndFaq => 'সাহায্য ও সাধারণ প্রশ্নাবলী';

  @override
  String get contactSupport => 'সহায়তা কেন্দ্র যোগাযোগ';

  @override
  String get about => 'অ্যাপ সম্পর্কে';

  @override
  String get appVersion => 'অ্যাপ সংস্করণ';

  @override
  String get motaWebsite => 'MoTA ওয়েবসাইট';

  @override
  String get statusDraft => 'খসড়া';

  @override
  String get statusSubmitted => 'জমা দেওয়া হয়েছে';

  @override
  String get statusUnderReview => 'পর্যালোচনাধীন';

  @override
  String get statusVerified => 'যাচাইকৃত';

  @override
  String get statusApproved => 'অনুমোদিত';

  @override
  String get statusSanctioned => 'মঞ্জুরকৃত';

  @override
  String get statusDisbursed => 'বিতরণকৃত';

  @override
  String get statusRejected => 'প্রত্যাখ্যাত';

  @override
  String get statusPending => 'মুলতুবি';

  @override
  String get selectLanguageTitle => 'ভাষা নির্বাচন করুন';

  @override
  String get selectLanguageSubtitle =>
      'আবেদনের জন্য আপনার পছন্দের ভাষা বেছে নিন';

  @override
  String get myApplications => 'আমার আবেদনসমূহ';
}
