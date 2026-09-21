import '../../core/enums/app_enums.dart';

/// Represents a document in the student's document wallet.
class Document {
  final String id;
  final String name;
  final DocumentCategory category;
  final DocumentStatus status;
  final String? fileUrl;
  final String? fileName;
  final String? fileType; // pdf, jpg, png
  final int? fileSizeBytes;
  final DateTime? uploadedAt;
  final DateTime? verifiedAt;
  final DateTime? expiresAt;
  final bool isFromDigiLocker;
  final String? rejectionReason;

  const Document({
    required this.id,
    required this.name,
    required this.category,
    required this.status,
    this.fileUrl,
    this.fileName,
    this.fileType,
    this.fileSizeBytes,
    this.uploadedAt,
    this.verifiedAt,
    this.expiresAt,
    this.isFromDigiLocker = false,
    this.rejectionReason,
  });
}
