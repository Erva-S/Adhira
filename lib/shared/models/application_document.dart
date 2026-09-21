/// Represents a link between a scholarship application and a document in the user's wallet.
/// Enables reusing previously verified documents across multiple scholarship schemes
/// without forcing the student to re-upload.
class ApplicationDocument {
  final String id;
  final String applicationId;
  final String documentId;
  final String documentType;
  final bool isReused;
  final DateTime attachedAt;

  const ApplicationDocument({
    required this.id,
    required this.applicationId,
    required this.documentId,
    required this.documentType,
    this.isReused = false,
    required this.attachedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'application_id': applicationId,
      'document_id': documentId,
      'document_type': documentType,
      'is_reused': isReused,
      'attached_at': attachedAt.toIso8601String(),
    };
  }

  factory ApplicationDocument.fromMap(Map<String, dynamic> map) {
    return ApplicationDocument(
      id: map['id']?.toString() ?? '',
      applicationId: map['application_id']?.toString() ?? '',
      documentId: map['document_id']?.toString() ?? '',
      documentType: map['document_type']?.toString() ?? '',
      isReused: map['is_reused'] == true,
      attachedAt: map['attached_at'] != null
          ? DateTime.tryParse(map['attached_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
