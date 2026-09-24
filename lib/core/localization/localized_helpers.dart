import 'package:flutter/widgets.dart';
import '../../core/enums/app_enums.dart';
import '../../l10n/app_localizations.dart';

/// Helper utilities to get localized display labels for enums and domain entities
/// without modifying internal database IDs, enum names, or backend fields.
class LocalizedHelpers {
  LocalizedHelpers._();

  static String getApplicationStatusLabel(BuildContext context, ApplicationStatus status) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return status.label;

    switch (status) {
      case ApplicationStatus.draft:
        return l10n.statusDraft;
      case ApplicationStatus.submitted:
        return l10n.statusSubmitted;
      case ApplicationStatus.underReview:
        return l10n.statusUnderReview;
      case ApplicationStatus.verified:
        return l10n.statusVerified;
      case ApplicationStatus.approved:
        return l10n.statusApproved;
      case ApplicationStatus.sanctioned:
        return l10n.statusSanctioned;
      case ApplicationStatus.disbursementInitiated:
      case ApplicationStatus.disbursed:
        return l10n.statusDisbursed;
      case ApplicationStatus.rejected:
        return l10n.statusRejected;
      case ApplicationStatus.incomplete:
      case ApplicationStatus.withdrawn:
        return status.label;
    }
  }

  static String getScholarshipTypeName(BuildContext context, ScholarshipType type) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return type.fullName;

    switch (type) {
      case ScholarshipType.preMatric:
        return l10n.preMatric;
      case ScholarshipType.postMatric:
        return l10n.postMatric;
      case ScholarshipType.topClass:
        return l10n.topClass;
      case ScholarshipType.nfst:
        return l10n.nfst;
      case ScholarshipType.nos:
        return l10n.nos;
    }
  }

  static String getScholarshipTypeDesc(BuildContext context, ScholarshipType type) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return type.tagline;

    switch (type) {
      case ScholarshipType.preMatric:
        return l10n.preMatricDesc;
      case ScholarshipType.postMatric:
        return l10n.postMatricDesc;
      case ScholarshipType.topClass:
        return l10n.topClassDesc;
      case ScholarshipType.nfst:
        return l10n.nfstDesc;
      case ScholarshipType.nos:
        return l10n.nosDesc;
    }
  }

  static String getVerificationStatusLabel(BuildContext context, VerificationStatus status) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return status.label;

    switch (status) {
      case VerificationStatus.pending:
        return l10n.statusPending;
      case VerificationStatus.inProgress:
        return l10n.statusUnderReview;
      case VerificationStatus.verified:
        return l10n.statusVerified;
      case VerificationStatus.failed:
      case VerificationStatus.mismatch:
      case VerificationStatus.notApplicable:
        return status.label;
      case VerificationStatus.manualReview:
        return l10n.statusUnderReview;
    }
  }

  static String getPaymentStatusLabel(BuildContext context, PaymentStatus status) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return status.label;

    switch (status) {
      case PaymentStatus.sanctioned:
        return l10n.statusSanctioned;
      case PaymentStatus.processing:
        return l10n.statusUnderReview;
      case PaymentStatus.disbursed:
        return l10n.statusDisbursed;
      case PaymentStatus.failed:
      case PaymentStatus.returned:
        return l10n.statusRejected;
      case PaymentStatus.pending:
        return l10n.statusPending;
    }
  }

  static String getDocumentStatusLabel(BuildContext context, DocumentStatus status) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return status.label;

    switch (status) {
      case DocumentStatus.notUploaded:
        return status.label;
      case DocumentStatus.uploaded:
        return l10n.statusSubmitted;
      case DocumentStatus.verified:
        return l10n.statusVerified;
      case DocumentStatus.rejected:
        return l10n.statusRejected;
      case DocumentStatus.expired:
        return status.label;
      case DocumentStatus.digilockerLinked:
        return 'DigiLocker';
    }
  }

  static String getDocumentName(BuildContext context, String docType) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return docType;

    final upper = docType.toUpperCase();
    if (upper.contains('AADHAAR') || upper.contains('ADHAR') || upper.contains('UIDAI')) {
      return l10n.aadhaarCard;
    }
    if (upper.contains('CASTE') || upper.contains('COMMUNITY') || upper.contains('ST_CERT')) {
      return l10n.casteCertificate;
    }
    if (upper.contains('12') || upper.contains('MARKSHEET') || upper.contains('HSC')) {
      return l10n.marksheet12;
    }
    if (upper.contains('INCOME')) {
      return l10n.incomeCertificate;
    }
    if (upper.contains('BONAFIDE')) {
      return l10n.bonafideCertificate;
    }
    return docType;
  }
}
