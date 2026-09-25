import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/enums/app_enums.dart';
import '../../../../core/localization/app_localizations_extension.dart';
import '../../../../core/localization/localized_helpers.dart';
import '../../../../services/integrations/digilocker/digilocker_service.dart';
import '../../../../services/scholarship/scholarship_data_service.dart';

/// DigiLocker State Machine representation.
enum DigiLockerState {
  notConnected,
  connecting,
  authenticating,
  fetchingDocuments,
  documentsAvailable,
  noDocuments,
  connectionFailed,
  importing,
  done,
}

/// DigiLocker Demo Consent & Document Picker page.
///
/// Demonstrates the DigiLocker OAuth & document fetch flow
/// using MOCK DATA ONLY with safe, privacy-preserving masked metadata.
class DigiLockerConsentPage extends StatefulWidget {
  /// If true, imported documents are automatically persisted to the wallet.
  final bool autoImportToWallet;

  const DigiLockerConsentPage({super.key, this.autoImportToWallet = false});

  @override
  State<DigiLockerConsentPage> createState() => _DigiLockerConsentPageState();
}

class _DigiLockerConsentPageState extends State<DigiLockerConsentPage>
    with SingleTickerProviderStateMixin {
  final DigiLockerService _service = MockDigiLockerService();
  DigiLockerState _state = DigiLockerState.notConnected;
  List<DigiLockerDocument> _docs = [];
  final Set<String> _selected = {};
  String _statusMsg = '';

  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  // ── Flow Progression ─────────────────────────────────────────────

  Future<void> _startConnectFlow() async {
    // Phase 1: Connecting
    setState(() {
      _state = DigiLockerState.connecting;
      _statusMsg = 'Connecting to DigiLocker gateway…';
    });

    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;

    // Phase 2: Authenticating
    setState(() {
      _state = DigiLockerState.authenticating;
      _statusMsg = 'Authenticating demo citizen identity (UIDAI)…';
    });

    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    // Phase 3: Fetching Documents
    setState(() {
      _state = DigiLockerState.fetchingDocuments;
      _statusMsg = 'Fetching demo documents from DigiLocker…';
    });

    try {
      final docs = await _service.getAvailableDocuments();
      if (!mounted) return;

      if (docs.isEmpty) {
        setState(() {
          _docs = [];
          _state = DigiLockerState.noDocuments;
        });
      } else {
        setState(() {
          _docs = docs;
          _state = DigiLockerState.documentsAvailable;
          // Pre-select required documents
          _selected.clear();
          _selected.addAll(
            docs.where((d) => d.requiredForScholarship).map((d) => d.uri),
          );
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _state = DigiLockerState.connectionFailed;
      });
    }
  }

  // ── Import / Attachment Action ───────────────────────────────────

  Future<void> _handleConfirmSelection() async {
    if (_selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one document to proceed.'),
        ),
      );
      return;
    }

    if (widget.autoImportToWallet) {
      setState(() {
        _state = DigiLockerState.importing;
        _statusMsg = 'Importing ${_selected.length} document(s) into wallet…';
      });

      final service = context.read<ScholarshipDataService>();
      int count = 0;

      for (final uri in _selected) {
        final doc = _docs.firstWhere((d) => d.uri == uri);
        setState(() => _statusMsg = 'Importing: ${doc.name}');
        final data = await _service.importDocument(uri, service.currentUserId);
        if (data != null) {
          await service.uploadDocument(
            name: doc.name,
            category: _mapDocTypeToCategory(doc.docType),
            documentType: doc.docType,
            fileName: '${doc.docType.toLowerCase()}.pdf',
            bytes: data.bytes,
          );
          count++;
        }
      }

      if (!mounted) return;
      setState(() {
        _state = DigiLockerState.done;
        _statusMsg = '$count document(s) added to your Document Wallet.';
      });
    } else {
      // Direct scholarship link: return success with selected docs
      Navigator.pop(context, true);
    }
  }

  // ── Document Preview Modal ───────────────────────────────────────

  void _showDocumentPreview(DigiLockerDocument doc) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.88,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Header pill
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 6),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Title bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0B57D0).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.verified_user_rounded,
                        color: Color(0xFF0B57D0),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            doc.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const Text(
                            'DigiLocker Integration — Demo',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Body content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Demo Data disclaimer
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.warningLight.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.warning.withValues(alpha: 0.3),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.shield_outlined,
                              color: AppColors.warning, size: 18),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Demo Data: Sensitive information is masked for privacy.',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Safe metadata cards
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildPreviewMetaRow('Document', doc.name),
                          const SizedBox(height: 6),
                          _buildPreviewMetaRow('Category', _getCategoryLabel(doc.docType)),
                          const SizedBox(height: 6),
                          _buildPreviewMetaRow('Issuer', doc.issuer),
                          if (doc.maskedNumber != null) ...[
                            const SizedBox(height: 6),
                            _buildPreviewMetaRow(
                              'Masked ID',
                              doc.maskedNumber!,
                              isCode: true,
                            ),
                          ],
                          if (doc.issuedDate != null) ...[
                            const SizedBox(height: 6),
                            _buildPreviewMetaRow(
                              'Issue Date',
                              '${doc.issuedDate!.day}/${doc.issuedDate!.month}/${doc.issuedDate!.year}',
                            ),
                          ],
                          const SizedBox(height: 6),
                          _buildPreviewMetaRow(
                            'Status',
                            doc.isVerified
                                ? 'Govt. Verified (Demo)'
                                : 'Uploaded (Demo)',
                            textColor: doc.isVerified
                                ? AppColors.success
                                : AppColors.textSecondary,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    const Text(
                      'Document Preview',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Visual document rendering
                    if (doc.assetImagePath != null)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Stack(
                            children: [
                              InteractiveViewer(
                                panEnabled: true,
                                minScale: 0.8,
                                maxScale: 1.5,
                                child: ImageFiltered(
                                  imageFilter: ImageFilter.blur(sigmaX: 3.5, sigmaY: 3.5),
                                  child: Image.asset(
                                    doc.assetImagePath!,
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) => _buildPlaceholderDoc(doc),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 10,
                                right: 10,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.65),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.blur_on_rounded, color: Colors.white, size: 14),
                                      SizedBox(width: 4),
                                      Text(
                                        'Blurred for Privacy',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      _buildPlaceholderDoc(doc),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewMetaRow(
    String label,
    String value, {
    bool isCode = false,
    Color? textColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor ?? AppColors.textPrimary,
              fontFamily: isCode ? 'monospace' : null,
              letterSpacing: isCode ? 0.8 : 0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholderDoc(DigiLockerDocument doc) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(
            _docIcon(doc.docType),
            size: 54,
            color: _docColor(doc.docType),
          ),
          const SizedBox(height: 12),
          Text(
            doc.name,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            doc.issuer,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.successLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified, size: 14, color: AppColors.success),
                SizedBox(width: 4),
                Text(
                  'Verified DigiLocker Demo Document',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.successDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Helper Mappers ───────────────────────────────────────────────

  DocumentCategory _mapDocTypeToCategory(String docType) {
    if (docType.contains('ADHAR') || docType.contains('ID')) {
      return DocumentCategory.identity;
    }
    if (docType.contains('CASTE') || docType.contains('ST')) {
      return DocumentCategory.caste;
    }
    if (docType.contains('INCOME')) return DocumentCategory.income;
    if (docType.contains('ACADEMIC') || docType.contains('12')) {
      return DocumentCategory.academic;
    }
    if (docType.contains('BONAFIDE')) return DocumentCategory.academic;
    if (docType.contains('BANK')) return DocumentCategory.bank;
    return DocumentCategory.other;
  }

  String _getCategoryLabel(String docType) {
    return _mapDocTypeToCategory(docType).label;
  }

  IconData _docIcon(String docType) {
    if (docType.contains('ADHAR')) return Icons.fingerprint;
    if (docType.contains('CASTE') || docType.contains('ST')) {
      return Icons.badge_outlined;
    }
    if (docType.contains('INCOME')) return Icons.receipt_long_outlined;
    if (docType.contains('ACADEMIC') || docType.contains('12')) {
      return Icons.school_outlined;
    }
    if (docType.contains('BONAFIDE')) return Icons.account_balance_outlined;
    return Icons.description_outlined;
  }

  Color _docColor(String docType) {
    if (docType.contains('ADHAR')) return const Color(0xFF0B57D0);
    if (docType.contains('CASTE') || docType.contains('ST')) {
      return AppColors.success;
    }
    if (docType.contains('INCOME')) return AppColors.warning;
    if (docType.contains('ACADEMIC') || docType.contains('12')) {
      return const Color(0xFF8430CE);
    }
    if (docType.contains('BONAFIDE')) return const Color(0xFF00796B);
    return AppColors.primary;
  }

  // ── Main Build ───────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(context.l10n.digiLockerDemoTitle),
        backgroundColor: const Color(0xFF0B57D0),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'DEMO',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
      ),
      body: _buildCurrentStateView(),
      bottomNavigationBar: _state == DigiLockerState.documentsAvailable
          ? _buildBottomActionBar()
          : null,
    );
  }

  Widget _buildCurrentStateView() {
    switch (_state) {
      case DigiLockerState.notConnected:
        return _buildNotConnectedView();

      case DigiLockerState.connecting:
        return _buildLoadingView(
          title: context.l10n.connecting,
          status: _statusMsg,
        );

      case DigiLockerState.authenticating:
        return _buildLoadingView(
          title: context.l10n.authenticating,
          status: _statusMsg,
        );

      case DigiLockerState.fetchingDocuments:
        return _buildLoadingView(
          title: context.l10n.fetchingDemoDocs,
          status: _statusMsg,
        );

      case DigiLockerState.documentsAvailable:
        return _buildDocumentsAvailableView();

      case DigiLockerState.noDocuments:
        return _buildNoDocumentsView();

      case DigiLockerState.connectionFailed:
        return _buildConnectionFailedView();

      case DigiLockerState.importing:
        return _buildImportingView();

      case DigiLockerState.done:
        return _buildDoneView();
    }
  }

  // ── Not Connected (Consent) View ─────────────────────────────────

  Widget _buildNotConnectedView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: const Color(0xFF0B57D0),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0B57D0).withValues(alpha: 0.3),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.verified_user_rounded,
              color: Colors.white,
              size: 44,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            context.l10n.connectToDigiLocker,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            context.l10n.digiLockerDemoBanner,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),

          // Demo notice banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.warningLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.warning.withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline, color: AppColors.warning, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    context.l10n.demoDataDisclaimer,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textPrimary,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Citizen info (demo)
          _buildInfoCard(
            icon: Icons.person_outlined,
            title: 'Demo Citizen Profile',
            rows: const [
              ['Name', 'Rajesh Singh'],
              ['Aadhaar', 'XXXX XXXX 4401'],
              ['DigiLocker ID', 'DEMO-DL-202500001'],
            ],
          ),
          const SizedBox(height: 16),

          // Permissions requested
          _buildInfoCard(
            icon: Icons.lock_open_outlined,
            title: 'Permissions Requested',
            rows: const [
              ['Access', 'Issued Documents (Read-only)'],
              ['Scope', 'aadhaar, caste, income, academic'],
              ['Duration', 'Session-only (Demo)'],
            ],
          ),
          const SizedBox(height: 28),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _startConnectFlow,
              icon: const Icon(Icons.link_rounded, size: 20),
              label: Text(
                context.l10n.linkDigiLockerBtn,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0B57D0),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.cancel),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required List<List<String>> rows,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const Divider(height: 16),
          ...rows.map(
            (row) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  SizedBox(
                    width: 100,
                    child: Text(
                      row[0],
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      row[1],
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Unified Loading View (Connecting, Authenticating, Fetching) ──

  Widget _buildLoadingView({required String title, required String status}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale: _pulseAnim,
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: const Color(0xFF0B57D0).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.verified_user_rounded,
                  color: Color(0xFF0B57D0),
                  size: 48,
                ),
              ),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(color: Color(0xFF0B57D0)),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              status,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Documents shown are demo data',
              style: TextStyle(fontSize: 11, color: AppColors.textTertiary),
            ),
          ],
        ),
      ),
    );
  }

  // ── Documents Available View ─────────────────────────────────────

  Widget _buildDocumentsAvailableView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Status bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: const Color(0xFF0B57D0).withValues(alpha: 0.08),
          child: Row(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF0B57D0),
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Connected — ${_docs.length} demo documents available',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF0B57D0),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF0B57D0).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Demo Data',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0B57D0),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Subheader with Select All / Deselect All
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.documentsAvailable,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Tap card to preview • Checkbox to select',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    if (_selected.length == _docs.length) {
                      _selected.clear();
                    } else {
                      _selected.addAll(_docs.map((d) => d.uri));
                    }
                  });
                },
                child: Text(
                  _selected.length == _docs.length
                      ? 'Deselect All'
                      : 'Select All',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Scrollable List of Documents
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            itemCount: _docs.length,
            itemBuilder: (context, i) {
              final doc = _docs[i];
              final isSelected = _selected.contains(doc.uri);
              final color = _docColor(doc.docType);

              return GestureDetector(
                onTap: () => _showDocumentPreview(doc),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? color.withValues(alpha: 0.05)
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? color.withValues(alpha: 0.6)
                          : AppColors.border,
                      width: isSelected ? 1.5 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Selection Checkbox
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                _selected.remove(doc.uri);
                              } else {
                                _selected.add(doc.uri);
                              }
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 24,
                            height: 24,
                            margin: const EdgeInsets.only(top: 2, right: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? color : Colors.transparent,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: isSelected ? color : AppColors.border,
                                width: 2,
                              ),
                            ),
                            child: isSelected
                                ? const Icon(
                                    Icons.check_rounded,
                                    color: Colors.white,
                                    size: 16,
                                  )
                                : null,
                          ),
                        ),

                        // Document Icon
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            _docIcon(doc.docType),
                            color: color,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Metadata details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title & Required badge
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      doc.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                  if (doc.requiredForScholarship)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary
                                            .withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        'Required',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 3),

                              // Category chip & Masked Number
                              Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Text(
                                    _getCategoryLabel(doc.docType),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  if (doc.maskedNumber != null) ...[
                                    const Text('•',
                                        style: TextStyle(
                                            color: AppColors.textTertiary)),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 5,
                                        vertical: 1,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.surfaceVariant,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        doc.maskedNumber!,
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontFamily: 'monospace',
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 4),

                              // Issuer and Verification tag
                              Row(
                                children: [
                                  if (doc.isVerified)
                                    const Row(
                                      children: [
                                        Icon(
                                          Icons.verified_rounded,
                                          size: 13,
                                          color: AppColors.success,
                                        ),
                                        SizedBox(width: 3),
                                        Text(
                                          'Govt. Verified',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: AppColors.success,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        SizedBox(width: 6),
                                      ],
                                    ),
                                  Expanded(
                                    child: Text(
                                      'via ${doc.issuerShort}',
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: AppColors.textTertiary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Preview button
                        IconButton(
                          icon: const Icon(Icons.remove_red_eye_outlined, size: 20),
                          color: AppColors.primaryLight,
                          tooltip: 'Preview Document',
                          onPressed: () => _showDocumentPreview(doc),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── Bottom Action Bar (Pinned) ───────────────────────────────────

  Widget _buildBottomActionBar() {
    final selectedCount = _selected.length;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$selectedCount of ${_docs.length} selected',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Text(
                    'DigiLocker Demo integration',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: selectedCount == 0 ? null : _handleConfirmSelection,
              icon: const Icon(Icons.check_circle_outline, size: 18),
              label: Text(
                widget.autoImportToWallet
                    ? 'Import $selectedCount Doc${selectedCount == 1 ? '' : 's'}'
                    : 'Use Selected Documents',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0B57D0),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── No Documents Empty State ─────────────────────────────────────

  Widget _buildNoDocumentsView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF0B57D0).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.folder_open_outlined,
                color: Color(0xFF0B57D0),
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No demo documents available',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'No issued certificates found in your demo DigiLocker account.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Go Back'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _startConnectFlow,
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Try Again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0B57D0),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Connection Failed Error State ────────────────────────────────

  Widget _buildConnectionFailedView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: AppColors.errorLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: AppColors.error,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Unable to load demo documents',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'The simulated DigiLocker connection could not complete.\n'
              'Please try again.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _startConnectFlow,
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Try Again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0B57D0),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Importing View ───────────────────────────────────────────────

  Widget _buildImportingView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: Color(0xFF0B57D0)),
            const SizedBox(height: 28),
            Text(
              _statusMsg,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Done View ────────────────────────────────────────────────────

  Widget _buildDoneView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppColors.successLight,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.success.withValues(alpha: 0.25),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: AppColors.success,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Import Complete!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            Text(
              _statusMsg,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Documents shown are demo data',
              style: TextStyle(fontSize: 11, color: AppColors.textTertiary),
            ),
            const SizedBox(height: 36),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context, true),
                icon: const Icon(Icons.check_circle_outline, size: 18),
                label: const Text(
                  'Continue with Linked Documents',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
