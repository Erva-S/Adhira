import 'package:flutter_test/flutter_test.dart';
import 'package:tribal_scholar_saathi/core/enums/app_enums.dart';
import 'package:tribal_scholar_saathi/services/pdf/application_pdf_service.dart';
import 'package:tribal_scholar_saathi/shared/models/application_status_history.dart';
import 'package:tribal_scholar_saathi/shared/models/payment.dart';
import 'package:tribal_scholar_saathi/shared/models/scholarship_application.dart';
import 'package:tribal_scholar_saathi/shared/models/student.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ApplicationPdfService Tests', () {
    test('generateApplicationPdf produces valid non-empty PDF bytes', () async {
      final app = ScholarshipApplication(
        id: 'app-test-001',
        scholarshipId: 'sch-post-matric',
        studentId: 'usr-001',
        scholarshipName: 'Post-Matric Scholarship for ST Students',
        scholarshipType: ScholarshipType.postMatric,
        status: ApplicationStatus.submitted,
        appliedDate: DateTime(2026, 9, 22),
        applicationNumber: 'PMS-ST-2026-55576',
        academicYear: '2025-26',
        requestedAmount: 70000,
      );

      final student = Student(
        id: 'usr-001',
        fullName: 'Rajesh Soren',
        fatherName: 'Mangal Soren',
        dateOfBirth: DateTime(2003, 8, 15),
        gender: 'Male',
        category: 'ST',
        aadhaarNumber: '123456789012',
        mobileNumber: '9876543210',
        email: 'rajesh@example.com',
        tribeName: 'Santhal',
        isPVTG: false,
        stCertificateNumber: 'ST/OD/2023/88921',
        state: 'Odisha',
        district: 'Mayurbhanj',
        institutionName: 'NIT Rourkela',
        currentCourse: 'B.Tech (CSE)',
        currentYear: 'Year 2',
        bankName: 'State Bank of India',
        bankAccountNumber: '987654321012',
        ifscCode: 'SBIN0001234',
      );

      final history = [
        ApplicationStatusHistory(
          id: 'hist-1',
          applicationId: app.id,
          stage: ApplicationStage.application,
          status: VerificationStatus.verified,
          message: 'Application submitted successfully.',
          changedBy: 'Student',
          changedAt: DateTime(2026, 9, 22),
        ),
      ];

      final payments = [
        Payment(
          id: 'pay-1',
          applicationId: app.id,
          userId: student.id,
          scholarshipName: app.scholarshipName,
          status: PaymentStatus.sanctioned,
          dbtStatus: DbtStatus.sanctioned,
          amount: 70000,
          installmentLabel: 'Installment 1 of 1',
        ),
      ];

      final bytes = await ApplicationPdfService.generateApplicationPdf(
        application: app,
        student: student,
        statusHistory: history,
        payments: payments,
      );

      expect(bytes, isNotEmpty);
      // Check PDF header: %PDF
      final header = String.fromCharCodes(bytes.sublist(0, 4));
      expect(header, equals('%PDF'));
    });

    test('generateDocumentCertificatePdf produces valid non-empty PDF bytes', () async {
      final bytes = await ApplicationPdfService.generateDocumentCertificatePdf(
        title: 'Scheduled Tribe Certificate',
        type: 'Caste/Tribe',
        studentName: 'Rajesh Soren',
        certNumber: 'ST/OD/2023/88921',
        issuer: 'Tehsildar, Mayurbhanj',
        issueDate: '16 Aug 2023',
        isDigiLocker: true,
      );

      expect(bytes, isNotEmpty);
      final header = String.fromCharCodes(bytes.sublist(0, 4));
      expect(header, equals('%PDF'));
    });
  });
}
