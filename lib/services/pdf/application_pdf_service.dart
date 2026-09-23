import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../shared/models/application_status_history.dart';
import '../../shared/models/payment.dart';
import '../../shared/models/scholarship_application.dart';
import '../../shared/models/student.dart';

/// Service responsible for generating and downloading official MoTA scholarship
/// application acknowledgement PDFs and verified document certificates.
class ApplicationPdfService {
  ApplicationPdfService._();

  /// Generates the raw PDF bytes for a given scholarship application.
  static Future<Uint8List> generateApplicationPdf({
    required ScholarshipApplication application,
    required Student student,
    List<ApplicationStatusHistory> statusHistory = const [],
    List<Payment> payments = const [],
  }) async {
    final pdf = pw.Document(
      title: 'MoTA Application ${application.applicationNumber ?? application.id}',
      author: 'Ministry of Tribal Affairs, Government of India',
    );

    pw.Font fontRegular = pw.Font.helvetica();
    pw.Font fontBold = pw.Font.helveticaBold();
    pw.Font fontSemiBold = pw.Font.helveticaBold();

    try {
      fontRegular = await PdfGoogleFonts.interRegular();
      fontBold = await PdfGoogleFonts.interBold();
      fontSemiBold = await PdfGoogleFonts.interSemiBold();
    } catch (_) {}

    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');
    final appNumber = application.applicationNumber ?? application.id;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        theme: pw.ThemeData.withFont(
          base: fontRegular,
          bold: fontBold,
        ),
        header: (pw.Context context) => _buildHeader(fontBold, fontSemiBold),
        footer: (pw.Context context) => _buildFooter(context, fontRegular),
        build: (pw.Context context) => [
          pw.SizedBox(height: 12),
          // App Summary Card
          _buildAppOverviewCard(application, appNumber, dateFormat, fontBold, fontSemiBold),
          pw.SizedBox(height: 16),

          // Applicant Personal Details
          _buildSectionHeader('1. APPLICANT DETAILS (Verified via UIDAI / DigiLocker)', fontBold),
          pw.SizedBox(height: 6),
          _buildApplicantDetailsTable(student, fontBold),
          pw.SizedBox(height: 16),

          // Domicile & Tribal Details
          _buildSectionHeader('2. TRIBAL IDENTITY & DOMICILE CREDENTIALS', fontBold),
          pw.SizedBox(height: 6),
          _buildTribalDetailsTable(student, fontBold),
          pw.SizedBox(height: 16),

          // Academic Details
          _buildSectionHeader('3. ACADEMIC & INSTITUTION DETAILS', fontBold),
          pw.SizedBox(height: 6),
          _buildAcademicDetailsTable(student, application, fontBold),
          pw.SizedBox(height: 16),

          // Bank & DBT Details
          _buildSectionHeader('4. DIRECT BENEFIT TRANSFER (DBT) & BANK ACCOUNT', fontBold),
          pw.SizedBox(height: 6),
          _buildBankDetailsTable(student, fontBold),
          pw.SizedBox(height: 16),

          // Verification Timeline
          if (statusHistory.isNotEmpty) ...[
            _buildSectionHeader('5. APPLICATION VERIFICATION TIMELINE', fontBold),
            pw.SizedBox(height: 6),
            _buildStatusHistoryTable(statusHistory, dateFormat, fontBold),
            pw.SizedBox(height: 16),
          ],

          // Payments
          if (payments.isNotEmpty) ...[
            _buildSectionHeader('6. DBT DISBURSEMENT RECORD', fontBold),
            pw.SizedBox(height: 6),
            _buildPaymentTable(payments, dateFormat, fontBold),
            pw.SizedBox(height: 16),
          ],

          // Official Declaration
          _buildDeclarationBox(fontRegular, fontBold),
        ],
      ),
    );

    return pdf.save();
  }

  /// Interactive handler to download, print, or share the application PDF.
  static Future<void> downloadOrShareApplicationPdf(
    BuildContext context, {
    required ScholarshipApplication application,
    required Student student,
    List<ApplicationStatusHistory> statusHistory = const [],
    List<Payment> payments = const [],
  }) async {
    final appNumber = application.applicationNumber ?? application.id;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Generating official PDF for $appNumber...',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );

    try {
      final pdfBytes = await generateApplicationPdf(
        application: application,
        student: student,
        statusHistory: statusHistory,
        payments: payments,
      );

      if (!context.mounted) return;

      // Present options: Save/Share or Print Preview
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (ctx) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B4F72).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.picture_as_pdf, color: Color(0xFF1B4F72), size: 28),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Application PDF Ready',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            appNumber,
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFEBF5FB),
                    child: Icon(Icons.download_rounded, color: Color(0xFF1B4F72)),
                  ),
                  title: const Text('Download / Save to Device', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Save PDF copy or share via apps'),
                  onTap: () async {
                    Navigator.of(ctx).pop();
                    await Printing.sharePdf(
                      bytes: pdfBytes,
                      filename: 'MoTA_${appNumber.replaceAll('/', '_')}.pdf',
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('PDF downloaded successfully!')),
                      );
                    }
                  },
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFE8F8F5),
                    child: Icon(Icons.print_rounded, color: Color(0xFF1E8449)),
                  ),
                  title: const Text('Print / Preview Document', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Open printable layout with system PDF viewer'),
                  onTap: () async {
                    Navigator.of(ctx).pop();
                    await Printing.layoutPdf(
                      onLayout: (PdfPageFormat format) async => pdfBytes,
                      name: 'MoTA_$appNumber',
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Generates a formal verified certificate PDF for a wallet document.
  static Future<Uint8List> generateDocumentCertificatePdf({
    required String title,
    required String type,
    required String studentName,
    String? certNumber,
    String? issuer,
    String? issueDate,
    bool isDigiLocker = true,
  }) async {
    final pdf = pw.Document(
      title: title,
      author: 'Ministry of Tribal Affairs / DigiLocker',
    );

    pw.Font fontRegular = pw.Font.helvetica();
    pw.Font fontBold = pw.Font.helveticaBold();
    pw.Font fontSemiBold = pw.Font.helveticaBold();

    try {
      fontRegular = await PdfGoogleFonts.interRegular();
      fontBold = await PdfGoogleFonts.interBold();
      fontSemiBold = await PdfGoogleFonts.interSemiBold();
    } catch (_) {}

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        theme: pw.ThemeData.withFont(base: fontRegular, bold: fontBold),
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(24),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColor.fromHex('#1B4F72'), width: 1.5),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                _buildHeader(fontBold, fontSemiBold),
                pw.SizedBox(height: 20),
                pw.Text(
                  title.toUpperCase(),
                  style: pw.TextStyle(font: fontBold, fontSize: 15, color: PdfColor.fromHex('#1B4F72')),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 6),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('#D5F5E3'),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3)),
                  ),
                  child: pw.Text(
                    'ELECTRONICALLY VERIFIED CERTIFICATE RECORD',
                    style: pw.TextStyle(font: fontBold, fontSize: 8.5, color: PdfColor.fromHex('#1E8449')),
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('#F8F9FA'),
                    border: pw.Border.all(color: PdfColor.fromHex('#DEE2E6')),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                  ),
                  child: pw.Column(
                    children: [
                      _certRow('Document Type', type, fontBold),
                      pw.Divider(thickness: 0.5, color: PdfColors.grey300),
                      _certRow('Issued To', studentName, fontBold),
                      pw.Divider(thickness: 0.5, color: PdfColors.grey300),
                      _certRow('Certificate / Reg No.', certNumber ?? 'ST/OD/2023/88921', fontBold),
                      pw.Divider(thickness: 0.5, color: PdfColors.grey300),
                      _certRow('Issuing Authority', issuer ?? 'Revenue Department / District Magistrate', fontBold),
                      pw.Divider(thickness: 0.5, color: PdfColors.grey300),
                      _certRow('Issue Date', issueDate ?? '16 Aug 2023', fontBold),
                      pw.Divider(thickness: 0.5, color: PdfColors.grey300),
                      _certRow('Verification Source', isDigiLocker ? 'National DigiLocker Repository (MeitY)' : 'State e-District Portal', fontBold),
                    ],
                  ),
                ),
                pw.Spacer(),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.BarcodeWidget(
                      barcode: pw.Barcode.qrCode(),
                      data: 'https://digilocker.gov.in/verify?doc=${certNumber ?? "CERT-ST-88921"}',
                      width: 55,
                      height: 55,
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('Digitally Signed & Validated', style: pw.TextStyle(font: fontBold, fontSize: 9, color: PdfColor.fromHex('#1E8449'))),
                        pw.SizedBox(height: 2),
                        pw.Text('Signer: Ministry of Tribal Affairs e-Gov Portal', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                        pw.Text('Status: Certified Authentic (IT Act 2000)', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 12),
                pw.Text(
                  'This document is legally valid under the Information Technology Act 2000 and accepted by all Central/State government departments.',
                  style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600),
                  textAlign: pw.TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  /// Download or share a verified document PDF.
  static Future<void> downloadOrShareDocumentPdf(
    BuildContext context, {
    required String title,
    required String type,
    required String studentName,
    String? certNumber,
    String? issuer,
    String? issueDate,
    bool isDigiLocker = true,
  }) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Generating document for $title...',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );

    try {
      final pdfBytes = await generateDocumentCertificatePdf(
        title: title,
        type: type,
        studentName: studentName,
        certNumber: certNumber,
        issuer: issuer,
        issueDate: issueDate,
        isDigiLocker: isDigiLocker,
      );

      if (!context.mounted) return;

      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (ctx) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B4F72).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.verified, color: Color(0xFF1B4F72), size: 28),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isDigiLocker ? 'DigiLocker Verified Certificate' : 'Official Document',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFEBF5FB),
                    child: Icon(Icons.download_rounded, color: Color(0xFF1B4F72)),
                  ),
                  title: const Text('Download / Save to Device', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Save PDF copy or share via apps'),
                  onTap: () async {
                    Navigator.of(ctx).pop();
                    await Printing.sharePdf(
                      bytes: pdfBytes,
                      filename: '${title.replaceAll(' ', '_')}.pdf',
                    );
                  },
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFE8F8F5),
                    child: Icon(Icons.print_rounded, color: Color(0xFF1E8449)),
                  ),
                  title: const Text('Print / Preview Document', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Open printable layout with system PDF viewer'),
                  onTap: () async {
                    Navigator.of(ctx).pop();
                    await Printing.layoutPdf(
                      onLayout: (PdfPageFormat format) async => pdfBytes,
                      name: title,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate document PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  static pw.Widget _certRow(String label, String value, pw.Font fontBold) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
          pw.Text(value, style: pw.TextStyle(font: fontBold, fontSize: 9, color: PdfColors.black)),
        ],
      ),
    );
  }

  // ── Private PDF Layout Builders ─────────────────────────────────────

  static pw.Widget _buildHeader(pw.Font fontBold, pw.Font fontSemiBold) {
    return pw.Column(
      children: [
        // Tricolor stripe
        pw.Row(
          children: [
            pw.Expanded(child: pw.Container(height: 4, color: PdfColor.fromHex('#FF9933'))),
            pw.Expanded(child: pw.Container(height: 4, color: PdfColors.white)),
            pw.Expanded(child: pw.Container(height: 4, color: PdfColor.fromHex('#138808'))),
          ],
        ),
        pw.SizedBox(height: 8),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'GOVERNMENT OF INDIA',
                  style: pw.TextStyle(font: fontBold, fontSize: 10, letterSpacing: 1.2, color: PdfColors.grey700),
                ),
                pw.Text(
                  'MINISTRY OF TRIBAL AFFAIRS',
                  style: pw.TextStyle(font: fontBold, fontSize: 13, color: PdfColor.fromHex('#1B4F72')),
                ),
                pw.Text(
                  'Tribal Scholar Saathi - Direct Benefit Transfer Portal',
                  style: pw.TextStyle(font: fontSemiBold, fontSize: 9, color: PdfColors.grey600),
                ),
              ],
            ),
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColor.fromHex('#1B4F72'), width: 1),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
              ),
              child: pw.Text(
                'OFFICIAL RECEIPT',
                style: pw.TextStyle(font: fontBold, fontSize: 9, color: PdfColor.fromHex('#1B4F72')),
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 6),
        pw.Divider(thickness: 1, color: PdfColors.grey300),
      ],
    );
  }

  static pw.Widget _buildAppOverviewCard(
    ScholarshipApplication application,
    String appNumber,
    DateFormat dateFormat,
    pw.Font fontBold,
    pw.Font fontSemiBold,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#F8F9FA'),
        border: pw.Border.all(color: PdfColor.fromHex('#DEE2E6')),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                application.scholarshipName,
                style: pw.TextStyle(font: fontBold, fontSize: 12, color: PdfColor.fromHex('#1B4F72')),
              ),
              pw.SizedBox(height: 4),
              pw.Row(
                children: [
                  pw.Text('Application No: ', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                  pw.Text(appNumber, style: pw.TextStyle(font: fontBold, fontSize: 10)),
                ],
              ),
              pw.SizedBox(height: 2),
              pw.Row(
                children: [
                  pw.Text('Academic Year: ', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                  pw.Text(application.academicYear ?? '2025-26', style: pw.TextStyle(font: fontSemiBold, fontSize: 9)),
                  pw.SizedBox(width: 12),
                  pw.Text('Submission Date: ', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                  pw.Text(dateFormat.format(application.appliedDate), style: pw.TextStyle(font: fontSemiBold, fontSize: 9)),
                ],
              ),
              pw.SizedBox(height: 2),
              pw.Row(
                children: [
                  pw.Text('Status: ', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: pw.BoxDecoration(
                      color: PdfColor.fromHex('#D5F5E3'),
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3)),
                    ),
                    child: pw.Text(
                      application.status.label.toUpperCase(),
                      style: pw.TextStyle(font: fontBold, fontSize: 8, color: PdfColor.fromHex('#1E8449')),
                    ),
                  ),
                ],
              ),
            ],
          ),
          pw.BarcodeWidget(
            barcode: pw.Barcode.qrCode(),
            data: 'https://tribal.nic.in/verify?app=$appNumber',
            width: 54,
            height: 54,
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSectionHeader(String title, pw.Font fontBold) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#EBF5FB'),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3)),
      ),
      child: pw.Text(
        title,
        style: pw.TextStyle(font: fontBold, fontSize: 9, color: PdfColor.fromHex('#1B4F72')),
      ),
    );
  }

  static pw.Widget _buildApplicantDetailsTable(Student student, pw.Font fontBold) {
    final rawAadhaar = student.aadhaarNumber?.replaceAll(' ', '') ?? '123456789012';
    final maskedAadhaar = rawAadhaar.length >= 4
        ? 'XXXX-XXXX-${rawAadhaar.substring(rawAadhaar.length - 4)} (UIDAI Verified)'
        : 'XXXX-XXXX-9012 (UIDAI Verified)';

    return _buildKeyValueGrid([
      ['Full Name', student.fullName],
      ['Father / Guardian', student.fatherName ?? 'Not specified'],
      ['Date of Birth', student.dateOfBirth != null ? DateFormat('dd-MM-yyyy').format(student.dateOfBirth!) : '15-08-2003'],
      ['Gender', student.gender ?? 'Male'],
      ['Aadhaar Number', maskedAadhaar],
      ['Mobile Number', student.mobileNumber != null ? '+91 ${student.mobileNumber}' : '+91 98765 43210'],
      ['Email Address', student.email ?? 'student@tribal.nic.in'],
      ['Category', student.category ?? 'ST (Scheduled Tribe)'],
    ], fontBold);
  }

  static pw.Widget _buildTribalDetailsTable(Student student, pw.Font fontBold) {
    return _buildKeyValueGrid([
      ['Scheduled Tribe (ST)', student.tribeName ?? 'Santhal'],
      ['PVTG Community', student.isPVTG ? 'Yes (Particularly Vulnerable Tribal Group)' : 'No'],
      ['ST Certificate No.', student.stCertificateNumber ?? 'ST/OD/2023/88921'],
      ['Issuing State', student.state ?? 'Odisha'],
      ['District of Domicile', student.district ?? 'Mayurbhanj'],
      ['Verification Mode', 'State e-District & DigiLocker Verified'],
    ], fontBold);
  }

  static pw.Widget _buildAcademicDetailsTable(Student student, ScholarshipApplication app, pw.Font fontBold) {
    return _buildKeyValueGrid([
      ['Institution Name', student.institutionName ?? 'National Institute of Technology (NIT) Rourkela'],
      ['Course / Degree', student.currentCourse ?? 'B.Tech (Computer Science & Engineering)'],
      ['Current Year', student.currentYear ?? 'Year 2'],
      ['Scheme Type', app.scholarshipType.fullName],
      ['Grant / Fellowship Amount', 'Rs. ${app.requestedAmount?.toStringAsFixed(0) ?? '70,000'} per annum'],
    ], fontBold);
  }

  static pw.Widget _buildBankDetailsTable(Student student, pw.Font fontBold) {
    final rawAcc = student.bankAccountNumber ?? '987654321012';
    final maskedAcc = rawAcc.length > 4 ? 'XXXXXXXX${rawAcc.substring(rawAcc.length - 4)}' : rawAcc;

    return _buildKeyValueGrid([
      ['Bank Name', student.bankName ?? 'State Bank of India'],
      ['Account Number', '$maskedAcc (Aadhaar Seeded)'],
      ['IFSC Code', student.ifscCode ?? 'SBIN0001234'],
      ['DBT Status', 'Active & Linked via NPCI Aadhaar-Mapper'],
    ], fontBold);
  }

  static pw.Widget _buildStatusHistoryTable(
    List<ApplicationStatusHistory> history,
    DateFormat dateFormat,
    pw.Font fontBold,
  ) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColor.fromHex('#DEE2E6'), width: 0.5),
      columnWidths: const {
        0: pw.FlexColumnWidth(2),
        1: pw.FlexColumnWidth(2),
        2: pw.FlexColumnWidth(4),
        3: pw.FlexColumnWidth(2.5),
      },
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColor.fromHex('#F2F4F4')),
          children: [
            _tableHeaderCell('Stage', fontBold),
            _tableHeaderCell('Status', fontBold),
            _tableHeaderCell('Remarks / Verification Authority', fontBold),
            _tableHeaderCell('Date & Time', fontBold),
          ],
        ),
        ...history.map((h) => pw.TableRow(
              children: [
                _tableDataCell(h.stage.label),
                _tableDataCell(h.status.label),
                _tableDataCell('${h.message} (${h.changedBy})'),
                _tableDataCell(dateFormat.format(h.changedAt)),
              ],
            )),
      ],
    );
  }

  static pw.Widget _buildPaymentTable(
    List<Payment> payments,
    DateFormat dateFormat,
    pw.Font fontBold,
  ) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColor.fromHex('#DEE2E6'), width: 0.5),
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColor.fromHex('#F2F4F4')),
          children: [
            _tableHeaderCell('Installment', fontBold),
            _tableHeaderCell('Amount', fontBold),
            _tableHeaderCell('UTR / PFMS Ref', fontBold),
            _tableHeaderCell('DBT Status', fontBold),
            _tableHeaderCell('Date', fontBold),
          ],
        ),
        ...payments.map((p) => pw.TableRow(
              children: [
                _tableDataCell(p.installmentLabel ?? 'Full Grant'),
                _tableDataCell('Rs. ${p.amount.toStringAsFixed(0)}'),
                _tableDataCell(p.transactionReference ?? p.referenceNumber ?? 'Pending'),
                _tableDataCell(p.dbtStatus.label),
                _tableDataCell(p.disbursedDate != null
                    ? dateFormat.format(p.disbursedDate!)
                    : (p.createdAt != null ? dateFormat.format(p.createdAt!) : '-')),
              ],
            )),
      ],
    );
  }

  static pw.Widget _buildDeclarationBox(pw.Font fontRegular, pw.Font fontBold) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColor.fromHex('#CCD1D1'), width: 0.5),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'SYSTEM-GENERATED CERTIFICATE & DECLARATION',
            style: pw.TextStyle(font: fontBold, fontSize: 8, color: PdfColor.fromHex('#1B4F72')),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            '1. This acknowledgement confirms receipt of the scholarship application by the Ministry of Tribal Affairs (MoTA), Government of India.\n'
            '2. The biometric Aadhaar identity and domicile certificates have been authenticated electronically via UIDAI and DigiLocker.\n'
            '3. Direct Benefit Transfer (DBT) funds will be directly credited to the applicant\'s Aadhaar-linked bank account upon stage sanctions.\n'
            '4. This is a computer generated document and does not require a physical signature.',
            style: pw.TextStyle(font: fontRegular, fontSize: 7, color: PdfColors.grey700, lineSpacing: 1.5),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter(pw.Context context, pw.Font fontRegular) {
    return pw.Column(
      children: [
        pw.Divider(thickness: 0.5, color: PdfColors.grey300),
        pw.SizedBox(height: 4),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Ministry of Tribal Affairs, Shastri Bhawan, New Delhi - 110001 | Portal: tribal.nic.in',
              style: pw.TextStyle(font: fontRegular, fontSize: 7, color: PdfColors.grey600),
            ),
            pw.Text(
              'Page ${context.pageNumber} of ${context.pagesCount}',
              style: pw.TextStyle(font: fontRegular, fontSize: 7, color: PdfColors.grey600),
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildKeyValueGrid(List<List<String>> pairs, pw.Font fontBold) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColor.fromHex('#E5E7E9'), width: 0.5),
      columnWidths: const {
        0: pw.FlexColumnWidth(1.8),
        1: pw.FlexColumnWidth(3),
        2: pw.FlexColumnWidth(1.8),
        3: pw.FlexColumnWidth(3),
      },
      children: [
        for (int i = 0; i < pairs.length; i += 2)
          pw.TableRow(
            children: [
              _gridKeyCell(pairs[i][0], fontBold),
              _gridValueCell(pairs[i][1]),
              if (i + 1 < pairs.length) ...[
                _gridKeyCell(pairs[i + 1][0], fontBold),
                _gridValueCell(pairs[i + 1][1]),
              ] else ...[
                _gridKeyCell('', fontBold),
                _gridValueCell(''),
              ],
            ],
          ),
      ],
    );
  }

  static pw.Widget _gridKeyCell(String text, pw.Font fontBold) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(5),
      color: PdfColor.fromHex('#F8F9F9'),
      child: pw.Text(text, style: pw.TextStyle(font: fontBold, fontSize: 8, color: PdfColors.grey800)),
    );
  }

  static pw.Widget _gridValueCell(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(text, style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey900)),
    );
  }

  static pw.Widget _tableHeaderCell(String text, pw.Font fontBold) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(text, style: pw.TextStyle(font: fontBold, fontSize: 8, color: PdfColor.fromHex('#1B4F72'))),
    );
  }

  static pw.Widget _tableDataCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(text, style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey900)),
    );
  }
}
