import 'dart:io' as io;
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/enums/app_enums.dart';
import '../../../../services/scholarship/scholarship_data_service.dart';
import '../../../../shared/models/models.dart';

/// Shows a standardized, secure document upload modal dialog.
/// Supports PDF, JPG, JPEG, PNG manual device file picking with complete validation.
Future<Document?> showUploadDocumentDialog({
  required BuildContext context,
  required ScholarshipDataService service,
  DocumentCategory defaultCategory = DocumentCategory.academic,
  String? defaultName,
  String? defaultDocumentType,
  void Function(Document doc)? onUploaded,
}) {
  return showDialog<Document>(
    context: context,
    barrierDismissible: false,
    builder: (dialogCtx) => UploadDocumentDialog(
      service: service,
      defaultCategory: defaultCategory,
      defaultName: defaultName,
      defaultDocumentType: defaultDocumentType,
      onUploaded: onUploaded,
    ),
  );
}

class UploadDocumentDialog extends StatefulWidget {
  final ScholarshipDataService service;
  final DocumentCategory defaultCategory;
  final String? defaultName;
  final String? defaultDocumentType;
  final void Function(Document doc)? onUploaded;

  const UploadDocumentDialog({
    super.key,
    required this.service,
    this.defaultCategory = DocumentCategory.academic,
    this.defaultName,
    this.defaultDocumentType,
    this.onUploaded,
  });

  @override
  State<UploadDocumentDialog> createState() => _UploadDocumentDialogState();
}

class _UploadDocumentDialogState extends State<UploadDocumentDialog> {
  late final TextEditingController _nameController;
  late DocumentCategory _selectedCategory;

  String? _selectedFileName;
  int? _selectedFileSize;
  Uint8List? _selectedFileBytes;

  bool _isUploading = false;
  String? _validationError;

  // Maximum allowed file size: 10 MB
  static const int _maxFileSizeBytes = 10 * 1024 * 1024;
  static const List<String> _allowedExtensions = ['pdf', 'jpg', 'jpeg', 'png'];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.defaultCategory;
    _nameController = TextEditingController(text: widget.defaultName ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Future<void> _pickFileFromDevice() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: _allowedExtensions,
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        // User cancelled selection
        if (mounted) {
          setState(() {
            if (_selectedFileBytes == null) {
              _validationError = 'Document upload cancelled.';
            }
          });
        }
        return;
      }

      final file = result.files.first;

      // 1. Validate file extension
      final ext = (file.extension ?? (file.name.contains('.') ? file.name.split('.').last : '')).toLowerCase();
      if (!_allowedExtensions.contains(ext)) {
        if (mounted) {
          setState(() {
            _validationError = 'Unsupported file format. Please select a PDF, JPG, or PNG.';
          });
        }
        return;
      }

      // 2. Validate file size limit (10 MB)
      if (file.size > _maxFileSizeBytes) {
        if (mounted) {
          setState(() {
            _validationError = 'File is too large. Maximum allowed size is 10 MB.';
          });
        }
        return;
      }

      // 3. Read file bytes across all platforms (Web, Windows, Android, iOS, macOS, Linux)
      Uint8List? bytes = file.bytes;
      if ((bytes == null || bytes.isEmpty) && !kIsWeb && file.path != null) {
        try {
          final ioFile = io.File(file.path!);
          if (await ioFile.exists()) {
            bytes = await ioFile.readAsBytes();
          }
        } catch (e) {
          if (mounted) {
            setState(() {
              _validationError = 'Could not read file from device: $e';
            });
          }
          return;
        }
      }

      if (bytes == null || bytes.isEmpty) {
        if (mounted) {
          setState(() {
            _validationError = 'Selected file is empty. Please select a valid document.';
          });
        }
        return;
      }

      if (mounted) {
        setState(() {
          _selectedFileName = file.name;
          _selectedFileSize = file.size;
          _selectedFileBytes = bytes;
          _validationError = null;

          // Auto-fill document name if empty
          if (_nameController.text.trim().isEmpty) {
            final cleanName = file.name
                .replaceAll(RegExp(r'\.[a-zA-Z0-9]+$'), '')
                .replaceAll(RegExp(r'[_-]'), ' ')
                .trim();
            if (cleanName.isNotEmpty) {
              _nameController.text = cleanName
                  .split(' ')
                  .map((w) => w.isNotEmpty
                      ? '${w[0].toUpperCase()}${w.substring(1)}'
                      : '')
                  .join(' ');
            }
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _validationError = 'Error selecting file: $e';
        });
      }
    }
  }

  void _selectSampleDoc(String name, DocumentCategory cat, String filename) {
    setState(() {
      _nameController.text = name;
      _selectedCategory = cat;
      _selectedFileName = filename;
      _selectedFileSize = 245 * 1024;
      _selectedFileBytes = Uint8List.fromList(
        '%PDF-1.4 MoTA Sample Document for $name'.codeUnits,
      );
      _validationError = null;
    });
  }

  Future<void> _handleUpload() async {
    final docName = _nameController.text.trim();
    if (docName.isEmpty) {
      setState(() => _validationError = 'Please enter a document name.');
      return;
    }

    if (_selectedFileBytes == null) {
      setState(() => _validationError = 'Please choose a document from your device first.');
      return;
    }

    setState(() {
      _isUploading = true;
      _validationError = null;
    });

    try {
      final fileName = _selectedFileName ??
          '${docName.toLowerCase().replaceAll(RegExp(r'\s+'), "_")}.pdf';
      final docType = widget.defaultDocumentType ??
          docName.toUpperCase().replaceAll(' ', '_');

      final uploadedDoc = await widget.service.uploadDocument(
        name: docName,
        category: _selectedCategory,
        documentType: docType,
        fileName: fileName,
        bytes: _selectedFileBytes!,
      );

      widget.onUploaded?.call(uploadedDoc);

      if (!mounted) return;
      Navigator.of(context).pop(uploadedDoc);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text('$docName uploaded successfully!'),
              ),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploading = false;
          _validationError = 'Upload failed. Please try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dialog Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.upload_file, color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Upload Document',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Select a document from your device',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                if (!_isUploading)
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // File picker drop-zone / card
            InkWell(
              onTap: _isUploading ? null : _pickFileFromDevice,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _selectedFileName != null
                      ? AppColors.successLight.withValues(alpha: 0.4)
                      : AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _selectedFileName != null
                        ? AppColors.success
                        : AppColors.border,
                    width: _selectedFileName != null ? 1.5 : 1,
                  ),
                ),
                child: _selectedFileName != null
                    ? Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.successLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              _selectedFileName!.toLowerCase().endsWith('.pdf')
                                  ? Icons.picture_as_pdf
                                  : Icons.image,
                              color: AppColors.success,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _selectedFileName!,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _formatSize(_selectedFileSize ?? 0),
                                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          TextButton.icon(
                            onPressed: _isUploading ? null : _pickFileFromDevice,
                            icon: const Icon(Icons.refresh, size: 14),
                            label: const Text('Change', style: TextStyle(fontSize: 12)),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          const Icon(Icons.cloud_upload_outlined, size: 40, color: AppColors.primary),
                          const SizedBox(height: 8),
                          const Text(
                            'Choose a file from device',
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'PDF, JPG, or PNG (Max 10 MB)',
                            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton.icon(
                            onPressed: _isUploading ? null : _pickFileFromDevice,
                            icon: const Icon(Icons.folder_open, size: 16),
                            label: const Text('Browse Files'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              textStyle: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 12),

            // Quick Sample Document Chips
            const Text(
              'Or pick sample document:',
              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                ActionChip(
                  label: const Text('ST Certificate', style: TextStyle(fontSize: 11)),
                  avatar: const Icon(Icons.badge_outlined, size: 14),
                  onPressed: _isUploading
                      ? null
                      : () => _selectSampleDoc('ST Certificate', DocumentCategory.caste, 'st_certificate.pdf'),
                ),
                ActionChip(
                  label: const Text('Income Certificate', style: TextStyle(fontSize: 11)),
                  avatar: const Icon(Icons.receipt_outlined, size: 14),
                  onPressed: _isUploading
                      ? null
                      : () => _selectSampleDoc('Income Certificate', DocumentCategory.income, 'income_cert.pdf'),
                ),
                ActionChip(
                  label: const Text('Bonafide', style: TextStyle(fontSize: 11)),
                  avatar: const Icon(Icons.school_outlined, size: 14),
                  onPressed: _isUploading
                      ? null
                      : () => _selectSampleDoc('Bonafide Certificate', DocumentCategory.academic, 'bonafide.pdf'),
                ),
                ActionChip(
                  label: const Text('Class 12 Marksheet', style: TextStyle(fontSize: 11)),
                  avatar: const Icon(Icons.school, size: 14),
                  onPressed: _isUploading
                      ? null
                      : () => _selectSampleDoc('Class 12 Marksheet', DocumentCategory.academic, 'marksheet.pdf'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Document Name Field
            TextField(
              controller: _nameController,
              enabled: !_isUploading,
              decoration: const InputDecoration(
                labelText: 'Document Name *',
                hintText: 'e.g., ST Certificate, Income Certificate',
                prefixIcon: Icon(Icons.description_outlined),
              ),
              onChanged: (_) {
                if (_validationError != null) {
                  setState(() => _validationError = null);
                }
              },
            ),
            const SizedBox(height: 12),

            // Category Dropdown
            DropdownButtonFormField<DocumentCategory>(
              initialValue: _selectedCategory,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Category *',
                prefixIcon: Icon(Icons.category_outlined),
              ),
              items: DocumentCategory.values.map((cat) {
                return DropdownMenuItem(
                  value: cat,
                  child: Text(cat.label, overflow: TextOverflow.ellipsis),
                );
              }).toList(),
              onChanged: _isUploading
                  ? null
                  : (val) {
                      if (val != null) setState(() => _selectedCategory = val);
                    },
            ),

            // Validation Error Display
            if (_validationError != null) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.errorLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: AppColors.error, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _validationError!,
                        style: const TextStyle(color: AppColors.error, fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 20),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isUploading ? null : () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isUploading ? null : _handleUpload,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: _isUploading
                      ? const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            ),
                            SizedBox(width: 8),
                            Text('Uploading...', style: TextStyle(fontSize: 13)),
                          ],
                        )
                      : const Text('Upload'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
