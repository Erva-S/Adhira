import '../../core/enums/app_enums.dart';

/// Represents a document in the student's document wallet.
class Document {
  final String id;
  final String? userId; // Owner student user_id
  final String name;
  final String? documentType; // Specific scheme requirement type e.g., 'ST_CERTIFICATE'
  final DocumentCategory category;
  final DocumentStatus status;
  final String? storagePath; // Path in private storage: documents/{userId}/{docId}
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
    this.userId,
    required this.name,
    this.documentType,
    required this.category,
    required this.status,
    this.storagePath,
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

  bool get isVerified => status == DocumentStatus.verified;

  Document copyWith({
    String? id,
    String? userId,
    String? name,
    String? documentType,
    DocumentCategory? category,
    DocumentStatus? status,
    String? storagePath,
    String? fileUrl,
    String? fileName,
    String? fileType,
    int? fileSizeBytes,
    DateTime? uploadedAt,
    DateTime? verifiedAt,
    DateTime? expiresAt,
    bool? isFromDigiLocker,
    String? rejectionReason,
  }) {
    return Document(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      documentType: documentType ?? this.documentType,
      category: category ?? this.category,
      status: status ?? this.status,
      storagePath: storagePath ?? this.storagePath,
      fileUrl: fileUrl ?? this.fileUrl,
      fileName: fileName ?? this.fileName,
      fileType: fileType ?? this.fileType,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      isFromDigiLocker: isFromDigiLocker ?? this.isFromDigiLocker,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'document_type': documentType ?? name,
      'category': category.name,
      'status': status.name,
      'storage_path': storagePath,
      'file_url': fileUrl,
      'file_name': fileName,
      'file_type': fileType,
      'file_size_bytes': fileSizeBytes,
      'uploaded_at': uploadedAt?.toIso8601String(),
      'verified_at': verifiedAt?.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
      'is_digilocker': isFromDigiLocker,
      'rejection_reason': rejectionReason,
    };
  }

  factory Document.fromMap(Map<String, dynamic> map) {
    return Document(
      id: map['id']?.toString() ?? '',
      userId: map['user_id']?.toString(),
      name: map['name']?.toString() ?? '',
      documentType: map['document_type']?.toString(),
      category: DocumentCategory.values.firstWhere(
        (c) => c.name == map['category'] || c.label == map['category'],
        orElse: () => DocumentCategory.other,
      ),
      status: DocumentStatus.values.firstWhere(
        (s) => s.name == map['status'] || s.label == map['status'],
        orElse: () => DocumentStatus.uploaded,
      ),
      storagePath: map['storage_path']?.toString(),
      fileUrl: map['file_url']?.toString(),
      fileName: map['file_name']?.toString(),
      fileType: map['file_type']?.toString(),
      fileSizeBytes: (map['file_size_bytes'] as num?)?.toInt(),
      uploadedAt: map['uploaded_at'] != null ? DateTime.tryParse(map['uploaded_at'].toString()) : null,
      verifiedAt: map['verified_at'] != null ? DateTime.tryParse(map['verified_at'].toString()) : null,
      expiresAt: map['expires_at'] != null ? DateTime.tryParse(map['expires_at'].toString()) : null,
      isFromDigiLocker: map['is_digilocker'] == true || map['is_from_digilocker'] == true,
      rejectionReason: map['rejection_reason']?.toString(),
    );
  }
}
