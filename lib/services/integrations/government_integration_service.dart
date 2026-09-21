import 'digilocker/digilocker_service.dart';

/// Result of an external government verification lookup.
class ExternalVerificationResult {
  final bool isVerified;
  final String verifiedBy;
  final String? certificateNumber;
  final String? applicantName;
  final DateTime? issueDate;
  final String? remarks;
  final IntegrationStatus integrationStatus;

  const ExternalVerificationResult({
    required this.isVerified,
    required this.verifiedBy,
    this.certificateNumber,
    this.applicantName,
    this.issueDate,
    this.remarks,
    this.integrationStatus = IntegrationStatus.mockDemo,
  });
}

/// Service interface for NSP (National Scholarship Portal) integration.
abstract class NSPService {
  IntegrationStatus get status;
  Future<bool> syncApplicationStatus(String nspApplicationId);
  Future<String?> checkDuplicateBeneficiary(String aadhaarHash, String academicYear);
}

/// Service interface for SFMP (Special Fellowship Management Portal) for NFST scholars.
abstract class SFMPService {
  IntegrationStatus get status;
  Future<Map<String, dynamic>?> getFellowshipTenureDetails(String fellowshipId);
  Future<bool> submitQuarterlyProgressReport(String fellowshipId, Map<String, dynamic> report);
}

/// Service interface for NOS (National Overseas Scholarship) Portal.
abstract class NOSService {
  IntegrationStatus get status;
  Future<Map<String, dynamic>?> checkVisaAndEmbassyClearance(String nosCandidateId);
}

/// Service interface for UIDAI Aadhaar e-KYC & Demographics verification.
abstract class UIDAIService {
  IntegrationStatus get status;
  Future<ExternalVerificationResult> verifyAadhaarOtp(String aadhaarNumber, String otp);
}

/// Service interface for State e-District (Caste & Income certificate verification).
abstract class StateEDistrictService {
  IntegrationStatus get status;
  Future<ExternalVerificationResult> verifyStCertificate({
    required String state,
    required String certificateNumber,
    required String applicantName,
  });

  Future<ExternalVerificationResult> verifyIncomeCertificate({
    required String state,
    required String certificateNumber,
    required String financialYear,
  });
}

/// Mock implementations of government integration interfaces for development & demo.
/// All responses are explicitly marked with `IntegrationStatus.readyForCredentials`
/// or `IntegrationStatus.mockDemo` to prevent confusing mock data with live government records.
class MockGovernmentIntegrationService
    implements NSPService, SFMPService, NOSService, UIDAIService, StateEDistrictService {
  @override
  IntegrationStatus get status => IntegrationStatus.readyForCredentials;

  // NSP
  @override
  Future<bool> syncApplicationStatus(String nspApplicationId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return true; // Mock synced
  }

  @override
  Future<String?> checkDuplicateBeneficiary(String aadhaarHash, String academicYear) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return null; // No duplicate detected in mock
  }

  // SFMP
  @override
  Future<Map<String, dynamic>?> getFellowshipTenureDetails(String fellowshipId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return {
      'fellowship_id': fellowshipId,
      'tenure_months': 36,
      'stipend_amount': 37000.0,
      'hra_applicable': true,
      'status': 'Active (Mock)',
    };
  }

  @override
  Future<bool> submitQuarterlyProgressReport(String fellowshipId, Map<String, dynamic> report) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return true;
  }

  // NOS
  @override
  Future<Map<String, dynamic>?> checkVisaAndEmbassyClearance(String nosCandidateId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return {
      'candidate_id': nosCandidateId,
      'embassy_clearance': 'Approved (Mock)',
      'allowance_currency': 'GBP',
      'annual_stipend': 9900,
    };
  }

  // UIDAI
  @override
  Future<ExternalVerificationResult> verifyAadhaarOtp(String aadhaarNumber, String otp) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return const ExternalVerificationResult(
      isVerified: true,
      verifiedBy: 'UIDAI CIDR Service (Simulated Sandbox)',
      remarks: 'Aadhaar e-KYC demo response: Name and DOB match applicant.',
      integrationStatus: IntegrationStatus.readyForCredentials,
    );
  }

  // State e-District
  @override
  Future<ExternalVerificationResult> verifyStCertificate({
    required String state,
    required String certificateNumber,
    required String applicantName,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));
    return ExternalVerificationResult(
      isVerified: true,
      verifiedBy: 'State e-District Portal ($state) [Mock]',
      certificateNumber: certificateNumber,
      applicantName: applicantName,
      issueDate: DateTime(2023, 8, 14),
      remarks: 'Simulated verification: ST community certificate is authentic.',
      integrationStatus: IntegrationStatus.readyForCredentials,
    );
  }

  @override
  Future<ExternalVerificationResult> verifyIncomeCertificate({
    required String state,
    required String certificateNumber,
    required String financialYear,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));
    return ExternalVerificationResult(
      isVerified: true,
      verifiedBy: 'State Revenue Portal ($state) [Mock]',
      certificateNumber: certificateNumber,
      remarks: 'Simulated verification: Annual family income verified as <= Rs. 2,50,000.',
      integrationStatus: IntegrationStatus.readyForCredentials,
    );
  }
}
