import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';
import 'app_localizations_gu.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_mr.dart';
import 'app_localizations_or.dart';
import 'app_localizations_ta.dart';
import 'app_localizations_te.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('bn'),
    Locale('en'),
    Locale('gu'),
    Locale('hi'),
    Locale('mr'),
    Locale('or'),
    Locale('ta'),
    Locale('te')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Adhira'**
  String get appTitle;

  /// No description provided for @motaTitle.
  ///
  /// In en, this message translates to:
  /// **'Ministry of Tribal Affairs'**
  String get motaTitle;

  /// No description provided for @motaGov.
  ///
  /// In en, this message translates to:
  /// **'Government of India'**
  String get motaGov;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navSchemes.
  ///
  /// In en, this message translates to:
  /// **'Schemes'**
  String get navSchemes;

  /// No description provided for @navDocuments.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get navDocuments;

  /// No description provided for @navJago.
  ///
  /// In en, this message translates to:
  /// **'JAGO'**
  String get navJago;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @signInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue to your scholarship dashboard'**
  String get signInSubtitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Register to discover and apply for MoTA scholarships'**
  String get registerSubtitle;

  /// No description provided for @mobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Mobile Number'**
  String get mobileNumber;

  /// No description provided for @enterMobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter 10-digit mobile number'**
  String get enterMobileNumber;

  /// No description provided for @sendOtp.
  ///
  /// In en, this message translates to:
  /// **'Send OTP'**
  String get sendOtp;

  /// No description provided for @sendingOtp.
  ///
  /// In en, this message translates to:
  /// **'Sending OTP...'**
  String get sendingOtp;

  /// No description provided for @otpVerification.
  ///
  /// In en, this message translates to:
  /// **'OTP Verification'**
  String get otpVerification;

  /// No description provided for @enterOtpSentTo.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit verification code sent to'**
  String get enterOtpSentTo;

  /// No description provided for @verifyAndProceed.
  ///
  /// In en, this message translates to:
  /// **'Verify & Proceed'**
  String get verifyAndProceed;

  /// No description provided for @verifying.
  ///
  /// In en, this message translates to:
  /// **'Verifying...'**
  String get verifying;

  /// No description provided for @resendOtp.
  ///
  /// In en, this message translates to:
  /// **'Resend OTP'**
  String get resendOtp;

  /// No description provided for @resendOtpIn.
  ///
  /// In en, this message translates to:
  /// **'Resend OTP in {seconds}s'**
  String resendOtpIn(Object seconds);

  /// No description provided for @didNotReceiveOtp.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive the code?'**
  String get didNotReceiveOtp;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @signOutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOutConfirmTitle;

  /// No description provided for @signOutConfirmMsg.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out of your account? You will need to verify your mobile number again to log in.'**
  String get signOutConfirmMsg;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @nextStep.
  ///
  /// In en, this message translates to:
  /// **'Next Step'**
  String get nextStep;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @saveDraft.
  ///
  /// In en, this message translates to:
  /// **'Save Draft'**
  String get saveDraft;

  /// No description provided for @reviewAndSubmit.
  ///
  /// In en, this message translates to:
  /// **'Review & Submit'**
  String get reviewAndSubmit;

  /// No description provided for @view.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @actionRequired.
  ///
  /// In en, this message translates to:
  /// **'Action Required'**
  String get actionRequired;

  /// No description provided for @namasteUser.
  ///
  /// In en, this message translates to:
  /// **'Namaste, {name} 🙏'**
  String namasteUser(Object name);

  /// No description provided for @profileCompletion.
  ///
  /// In en, this message translates to:
  /// **'Profile: {percent}% Complete'**
  String profileCompletion(Object percent);

  /// No description provided for @totalDisbursed.
  ///
  /// In en, this message translates to:
  /// **'Total Disbursed'**
  String get totalDisbursed;

  /// No description provided for @pendingDisbursement.
  ///
  /// In en, this message translates to:
  /// **'Pending Disbursement'**
  String get pendingDisbursement;

  /// No description provided for @activeApplications.
  ///
  /// In en, this message translates to:
  /// **'Active Applications'**
  String get activeApplications;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @applyScheme.
  ///
  /// In en, this message translates to:
  /// **'Apply for Scheme'**
  String get applyScheme;

  /// No description provided for @trackStatus.
  ///
  /// In en, this message translates to:
  /// **'Track Status'**
  String get trackStatus;

  /// No description provided for @docWallet.
  ///
  /// In en, this message translates to:
  /// **'Document Wallet'**
  String get docWallet;

  /// No description provided for @eligibilityCheck.
  ///
  /// In en, this message translates to:
  /// **'Eligibility Check'**
  String get eligibilityCheck;

  /// No description provided for @jagoAssistant.
  ///
  /// In en, this message translates to:
  /// **'JAGO Assistant'**
  String get jagoAssistant;

  /// No description provided for @recentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get recentActivity;

  /// No description provided for @scholarshipSchemes.
  ///
  /// In en, this message translates to:
  /// **'Scholarship Schemes'**
  String get scholarshipSchemes;

  /// No description provided for @allSchemes.
  ///
  /// In en, this message translates to:
  /// **'All Schemes'**
  String get allSchemes;

  /// No description provided for @preMatric.
  ///
  /// In en, this message translates to:
  /// **'Pre-Matric Scholarship'**
  String get preMatric;

  /// No description provided for @preMatricDesc.
  ///
  /// In en, this message translates to:
  /// **'Financial support for ST students in classes 9 and 10'**
  String get preMatricDesc;

  /// No description provided for @postMatric.
  ///
  /// In en, this message translates to:
  /// **'Post-Matric Scholarship'**
  String get postMatric;

  /// No description provided for @postMatricDesc.
  ///
  /// In en, this message translates to:
  /// **'Scholarships for ST students pursuing post-secondary studies'**
  String get postMatricDesc;

  /// No description provided for @topClass.
  ///
  /// In en, this message translates to:
  /// **'Top Class Education'**
  String get topClass;

  /// No description provided for @topClassDesc.
  ///
  /// In en, this message translates to:
  /// **'Full financial aid for ST students in premier national institutions'**
  String get topClassDesc;

  /// No description provided for @nfst.
  ///
  /// In en, this message translates to:
  /// **'National Fellowship for ST'**
  String get nfst;

  /// No description provided for @nfstDesc.
  ///
  /// In en, this message translates to:
  /// **'Higher education fellowship for M.Phil and Ph.D researchers'**
  String get nfstDesc;

  /// No description provided for @nos.
  ///
  /// In en, this message translates to:
  /// **'National Overseas Scholarship'**
  String get nos;

  /// No description provided for @nosDesc.
  ///
  /// In en, this message translates to:
  /// **'Financial assistance for ST students studying abroad'**
  String get nosDesc;

  /// No description provided for @applyNow.
  ///
  /// In en, this message translates to:
  /// **'Apply Now'**
  String get applyNow;

  /// No description provided for @schemeDetails.
  ///
  /// In en, this message translates to:
  /// **'Scheme Details'**
  String get schemeDetails;

  /// No description provided for @benefits.
  ///
  /// In en, this message translates to:
  /// **'Benefits'**
  String get benefits;

  /// No description provided for @eligibilityCriteria.
  ///
  /// In en, this message translates to:
  /// **'Eligibility Criteria'**
  String get eligibilityCriteria;

  /// No description provided for @requiredDocuments.
  ///
  /// In en, this message translates to:
  /// **'Required Documents'**
  String get requiredDocuments;

  /// No description provided for @applicationDeadline.
  ///
  /// In en, this message translates to:
  /// **'Application Deadline'**
  String get applicationDeadline;

  /// No description provided for @applicationFormTitle.
  ///
  /// In en, this message translates to:
  /// **'Scholarship Application'**
  String get applicationFormTitle;

  /// No description provided for @stepPersonal.
  ///
  /// In en, this message translates to:
  /// **'Personal'**
  String get stepPersonal;

  /// No description provided for @stepAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get stepAddress;

  /// No description provided for @stepAcademic.
  ///
  /// In en, this message translates to:
  /// **'Academic'**
  String get stepAcademic;

  /// No description provided for @stepBankDocs.
  ///
  /// In en, this message translates to:
  /// **'Bank & Docs'**
  String get stepBankDocs;

  /// No description provided for @stepReview.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get stepReview;

  /// No description provided for @personalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInfo;

  /// No description provided for @personalInfoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Details verified from Aadhaar & DigiLocker.'**
  String get personalInfoSubtitle;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @fatherName.
  ///
  /// In en, this message translates to:
  /// **'Father\'s Name'**
  String get fatherName;

  /// No description provided for @motherName.
  ///
  /// In en, this message translates to:
  /// **'Mother\'s Name'**
  String get motherName;

  /// No description provided for @dateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get dateOfBirth;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @tribeName.
  ///
  /// In en, this message translates to:
  /// **'Tribe Name'**
  String get tribeName;

  /// No description provided for @pvtgStatus.
  ///
  /// In en, this message translates to:
  /// **'Particularly Vulnerable Tribal Group (PVTG)'**
  String get pvtgStatus;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @addressInfo.
  ///
  /// In en, this message translates to:
  /// **'Address & Domicile'**
  String get addressInfo;

  /// No description provided for @addressInfoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Permanent and correspondence address.'**
  String get addressInfoSubtitle;

  /// No description provided for @state.
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get state;

  /// No description provided for @district.
  ///
  /// In en, this message translates to:
  /// **'District'**
  String get district;

  /// No description provided for @selectState.
  ///
  /// In en, this message translates to:
  /// **'Select State'**
  String get selectState;

  /// No description provided for @selectDistrict.
  ///
  /// In en, this message translates to:
  /// **'Select District'**
  String get selectDistrict;

  /// No description provided for @stateRequired.
  ///
  /// In en, this message translates to:
  /// **'State is required'**
  String get stateRequired;

  /// No description provided for @districtRequired.
  ///
  /// In en, this message translates to:
  /// **'District is required'**
  String get districtRequired;

  /// No description provided for @pincode.
  ///
  /// In en, this message translates to:
  /// **'Pincode'**
  String get pincode;

  /// No description provided for @addressLine.
  ///
  /// In en, this message translates to:
  /// **'Address Line'**
  String get addressLine;

  /// No description provided for @academicInfo.
  ///
  /// In en, this message translates to:
  /// **'Academic Details'**
  String get academicInfo;

  /// No description provided for @academicInfoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Current institution and course information.'**
  String get academicInfoSubtitle;

  /// No description provided for @institutionName.
  ///
  /// In en, this message translates to:
  /// **'Institution Name'**
  String get institutionName;

  /// No description provided for @courseName.
  ///
  /// In en, this message translates to:
  /// **'Course / Degree'**
  String get courseName;

  /// No description provided for @currentYear.
  ///
  /// In en, this message translates to:
  /// **'Current Year / Class'**
  String get currentYear;

  /// No description provided for @rollNumber.
  ///
  /// In en, this message translates to:
  /// **'Roll / Registration Number'**
  String get rollNumber;

  /// No description provided for @bankAndDocsInfo.
  ///
  /// In en, this message translates to:
  /// **'Bank Account & Documents'**
  String get bankAndDocsInfo;

  /// No description provided for @bankAndDocsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Direct Benefit Transfer (DBT) details.'**
  String get bankAndDocsSubtitle;

  /// No description provided for @bankName.
  ///
  /// In en, this message translates to:
  /// **'Bank Name'**
  String get bankName;

  /// No description provided for @accountNumber.
  ///
  /// In en, this message translates to:
  /// **'Account Number'**
  String get accountNumber;

  /// No description provided for @ifscCode.
  ///
  /// In en, this message translates to:
  /// **'IFSC Code'**
  String get ifscCode;

  /// No description provided for @branchName.
  ///
  /// In en, this message translates to:
  /// **'Branch Name'**
  String get branchName;

  /// No description provided for @linkDigiLockerTitle.
  ///
  /// In en, this message translates to:
  /// **'Link Documents via DigiLocker'**
  String get linkDigiLockerTitle;

  /// No description provided for @linkDigiLockerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Attach government-issued documents from your DigiLocker — Demo'**
  String get linkDigiLockerSubtitle;

  /// No description provided for @linkDigiLockerBtn.
  ///
  /// In en, this message translates to:
  /// **'Link from DigiLocker (Demo)'**
  String get linkDigiLockerBtn;

  /// No description provided for @digiLockerLinkedBanner.
  ///
  /// In en, this message translates to:
  /// **'DigiLocker Linked — Demo'**
  String get digiLockerLinkedBanner;

  /// No description provided for @digiLockerLinkedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Documents from DigiLocker added to your wallet'**
  String get digiLockerLinkedSubtitle;

  /// No description provided for @declarationTitle.
  ///
  /// In en, this message translates to:
  /// **'Declaration of Authenticity'**
  String get declarationTitle;

  /// No description provided for @declarationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'I hereby declare that all the information provided above is true and correct to the best of my knowledge.'**
  String get declarationSubtitle;

  /// No description provided for @applicationSubmittedTitle.
  ///
  /// In en, this message translates to:
  /// **'Application Submitted!'**
  String get applicationSubmittedTitle;

  /// No description provided for @applicationSubmittedMsg.
  ///
  /// In en, this message translates to:
  /// **'Your application has been submitted to the Ministry of Tribal Affairs.'**
  String get applicationSubmittedMsg;

  /// No description provided for @keepApplicationNumber.
  ///
  /// In en, this message translates to:
  /// **'Keep this number for tracking and verification purposes.'**
  String get keepApplicationNumber;

  /// No description provided for @goToDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get goToDashboard;

  /// No description provided for @trackApplication.
  ///
  /// In en, this message translates to:
  /// **'Track Application'**
  String get trackApplication;

  /// No description provided for @submittedDocsCount.
  ///
  /// In en, this message translates to:
  /// **'Submitted Documents (3)'**
  String get submittedDocsCount;

  /// No description provided for @verificationStatus.
  ///
  /// In en, this message translates to:
  /// **'Verification Status'**
  String get verificationStatus;

  /// No description provided for @digiLockerDemoTitle.
  ///
  /// In en, this message translates to:
  /// **'DigiLocker — Demo'**
  String get digiLockerDemoTitle;

  /// No description provided for @digiLockerDemoBanner.
  ///
  /// In en, this message translates to:
  /// **'DigiLocker Integration — Demo'**
  String get digiLockerDemoBanner;

  /// No description provided for @demoDataDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Demo Data: Sensitive information is masked for privacy.'**
  String get demoDataDisclaimer;

  /// No description provided for @connectToDigiLocker.
  ///
  /// In en, this message translates to:
  /// **'Connect to DigiLocker'**
  String get connectToDigiLocker;

  /// No description provided for @connecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting...'**
  String get connecting;

  /// No description provided for @authenticating.
  ///
  /// In en, this message translates to:
  /// **'Authenticating...'**
  String get authenticating;

  /// No description provided for @fetchingDemoDocs.
  ///
  /// In en, this message translates to:
  /// **'Fetching demo documents from DigiLocker…'**
  String get fetchingDemoDocs;

  /// No description provided for @documentsAvailable.
  ///
  /// In en, this message translates to:
  /// **'Documents Available'**
  String get documentsAvailable;

  /// No description provided for @noDocumentsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No demo documents available'**
  String get noDocumentsAvailable;

  /// No description provided for @connectionFailed.
  ///
  /// In en, this message translates to:
  /// **'Connection Failed'**
  String get connectionFailed;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @useSelectedDocs.
  ///
  /// In en, this message translates to:
  /// **'Use Selected Documents'**
  String get useSelectedDocs;

  /// No description provided for @importDocsBtn.
  ///
  /// In en, this message translates to:
  /// **'Import {count} Document(s)'**
  String importDocsBtn(Object count);

  /// No description provided for @importComplete.
  ///
  /// In en, this message translates to:
  /// **'Import Complete!'**
  String get importComplete;

  /// No description provided for @continueWithLinkedDocs.
  ///
  /// In en, this message translates to:
  /// **'Continue with Linked Documents'**
  String get continueWithLinkedDocs;

  /// No description provided for @blurredForPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Blurred for Privacy'**
  String get blurredForPrivacy;

  /// No description provided for @aadhaarCard.
  ///
  /// In en, this message translates to:
  /// **'Aadhaar Card'**
  String get aadhaarCard;

  /// No description provided for @casteCertificate.
  ///
  /// In en, this message translates to:
  /// **'Caste Certificate (SEBC / ST)'**
  String get casteCertificate;

  /// No description provided for @marksheet12.
  ///
  /// In en, this message translates to:
  /// **'Class 12 Marksheet'**
  String get marksheet12;

  /// No description provided for @incomeCertificate.
  ///
  /// In en, this message translates to:
  /// **'Income Certificate'**
  String get incomeCertificate;

  /// No description provided for @bonafideCertificate.
  ///
  /// In en, this message translates to:
  /// **'Bonafide Certificate'**
  String get bonafideCertificate;

  /// No description provided for @govtVerified.
  ///
  /// In en, this message translates to:
  /// **'Govt. Verified (Demo)'**
  String get govtVerified;

  /// No description provided for @jagoAssistantName.
  ///
  /// In en, this message translates to:
  /// **'JAGO'**
  String get jagoAssistantName;

  /// No description provided for @jagoAssistantSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Scholarship Assistant'**
  String get jagoAssistantSubtitle;

  /// No description provided for @jagoGreeting.
  ///
  /// In en, this message translates to:
  /// **'Namaste! 🙏 I\'m JAGO, your scholarship assistant. How can I help you today?'**
  String get jagoGreeting;

  /// No description provided for @jagoInputHint.
  ///
  /// In en, this message translates to:
  /// **'Ask about scholarships, status, documents...'**
  String get jagoInputHint;

  /// No description provided for @jagoQuickAppStatus.
  ///
  /// In en, this message translates to:
  /// **'📋 Application Status'**
  String get jagoQuickAppStatus;

  /// No description provided for @jagoQuickPayment.
  ///
  /// In en, this message translates to:
  /// **'💰 Payment Status'**
  String get jagoQuickPayment;

  /// No description provided for @jagoQuickDocs.
  ///
  /// In en, this message translates to:
  /// **'📄 Document Help'**
  String get jagoQuickDocs;

  /// No description provided for @jagoQuickEligibility.
  ///
  /// In en, this message translates to:
  /// **'❓ Am I Eligible?'**
  String get jagoQuickEligibility;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get noNotifications;

  /// No description provided for @markAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get markAllRead;

  /// No description provided for @myProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfileTitle;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @personalDetails.
  ///
  /// In en, this message translates to:
  /// **'Personal Details'**
  String get personalDetails;

  /// No description provided for @tribalDetails.
  ///
  /// In en, this message translates to:
  /// **'ST/Tribal Details'**
  String get tribalDetails;

  /// No description provided for @educationDetails.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get educationDetails;

  /// No description provided for @bankDetails.
  ///
  /// In en, this message translates to:
  /// **'Bank Details (for DBT)'**
  String get bankDetails;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'English (English)'**
  String get languageSubtitle;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @helpAndFaq.
  ///
  /// In en, this message translates to:
  /// **'Help & FAQ'**
  String get helpAndFaq;

  /// No description provided for @contactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get contactSupport;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get appVersion;

  /// No description provided for @motaWebsite.
  ///
  /// In en, this message translates to:
  /// **'MoTA Website'**
  String get motaWebsite;

  /// No description provided for @statusDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get statusDraft;

  /// No description provided for @statusSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Submitted'**
  String get statusSubmitted;

  /// No description provided for @statusUnderReview.
  ///
  /// In en, this message translates to:
  /// **'Under Review'**
  String get statusUnderReview;

  /// No description provided for @statusVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get statusVerified;

  /// No description provided for @statusApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get statusApproved;

  /// No description provided for @statusSanctioned.
  ///
  /// In en, this message translates to:
  /// **'Sanctioned'**
  String get statusSanctioned;

  /// No description provided for @statusDisbursed.
  ///
  /// In en, this message translates to:
  /// **'Disbursed'**
  String get statusDisbursed;

  /// No description provided for @statusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get statusRejected;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// No description provided for @selectLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguageTitle;

  /// No description provided for @selectLanguageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred language for the application'**
  String get selectLanguageSubtitle;

  /// No description provided for @myApplications.
  ///
  /// In en, this message translates to:
  /// **'My Applications'**
  String get myApplications;

  /// No description provided for @jagoLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'JAGO Language'**
  String get jagoLanguageTitle;

  /// No description provided for @jagoUseAppLanguage.
  ///
  /// In en, this message translates to:
  /// **'Use App Language'**
  String get jagoUseAppLanguage;

  /// No description provided for @jagoLanguageOverrideHint.
  ///
  /// In en, this message translates to:
  /// **'JAGO is using a custom language. Tap \"Use App Language\" to follow the app.'**
  String get jagoLanguageOverrideHint;

  /// No description provided for @jagoLanguageDefaultHint.
  ///
  /// In en, this message translates to:
  /// **'JAGO follows the app language. Choose a different language for JAGO only.'**
  String get jagoLanguageDefaultHint;

  /// No description provided for @jagoContextApplicationTracking.
  ///
  /// In en, this message translates to:
  /// **'I can help you with this application. Ask me about its status, pending actions, required documents, or the application timeline.'**
  String get jagoContextApplicationTracking;

  /// No description provided for @jagoContextEligibility.
  ///
  /// In en, this message translates to:
  /// **'I can help you check your eligibility for scholarship schemes. Ask me about specific criteria or what you might be missing.'**
  String get jagoContextEligibility;

  /// No description provided for @jagoContextDocuments.
  ///
  /// In en, this message translates to:
  /// **'I can help you with your documents. Ask about required documents, verification status, or DigiLocker integration.'**
  String get jagoContextDocuments;

  /// No description provided for @jagoContextPayments.
  ///
  /// In en, this message translates to:
  /// **'I can help you with your payment and DBT status. Ask about disbursements, pending installments, or payment timeline.'**
  String get jagoContextPayments;

  /// No description provided for @jagoSuggestionEligibility.
  ///
  /// In en, this message translates to:
  /// **'Check my eligibility'**
  String get jagoSuggestionEligibility;

  /// No description provided for @jagoSuggestionTrack.
  ///
  /// In en, this message translates to:
  /// **'Track my application'**
  String get jagoSuggestionTrack;

  /// No description provided for @jagoSuggestionDocs.
  ///
  /// In en, this message translates to:
  /// **'What documents do I need?'**
  String get jagoSuggestionDocs;

  /// No description provided for @jagoSuggestionPending.
  ///
  /// In en, this message translates to:
  /// **'What documents are pending?'**
  String get jagoSuggestionPending;

  /// No description provided for @jagoSuggestionPayment.
  ///
  /// In en, this message translates to:
  /// **'Check my payment status'**
  String get jagoSuggestionPayment;

  /// No description provided for @jagoSuggestionWhichScholarship.
  ///
  /// In en, this message translates to:
  /// **'Which scholarship am I applying for?'**
  String get jagoSuggestionWhichScholarship;

  /// No description provided for @jagoNavPromptApplications.
  ///
  /// In en, this message translates to:
  /// **'Would you like me to open Application Tracking?'**
  String get jagoNavPromptApplications;

  /// No description provided for @jagoNavPromptDocuments.
  ///
  /// In en, this message translates to:
  /// **'Would you like me to open the Document Wallet?'**
  String get jagoNavPromptDocuments;

  /// No description provided for @jagoNavPromptPayments.
  ///
  /// In en, this message translates to:
  /// **'Would you like me to open the Payments section?'**
  String get jagoNavPromptPayments;

  /// No description provided for @jagoNavPromptEligibility.
  ///
  /// In en, this message translates to:
  /// **'Would you like me to open the Eligibility Checker?'**
  String get jagoNavPromptEligibility;

  /// No description provided for @jagoAskJago.
  ///
  /// In en, this message translates to:
  /// **'Ask JAGO'**
  String get jagoAskJago;

  /// No description provided for @jagoNeedHelp.
  ///
  /// In en, this message translates to:
  /// **'Need help with this application?'**
  String get jagoNeedHelp;

  /// No description provided for @jagoNeedHelpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Ask JAGO AI or contact your district tribal officer.'**
  String get jagoNeedHelpSubtitle;

  /// No description provided for @jagoOpenedFrom.
  ///
  /// In en, this message translates to:
  /// **'Opened from: {screen}'**
  String jagoOpenedFrom(Object screen);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'bn',
        'en',
        'gu',
        'hi',
        'mr',
        'or',
        'ta',
        'te'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
    case 'gu':
      return AppLocalizationsGu();
    case 'hi':
      return AppLocalizationsHi();
    case 'mr':
      return AppLocalizationsMr();
    case 'or':
      return AppLocalizationsOr();
    case 'ta':
      return AppLocalizationsTa();
    case 'te':
      return AppLocalizationsTe();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
