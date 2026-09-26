import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/enums/app_enums.dart';
import '../../../../shared/models/chat_message.dart';
import '../../../../shared/widgets/app_bottom_nav.dart';
import '../../../../shared/widgets/chat_bubble.dart';
import '../../../../shared/widgets/jago_typing_indicator.dart';
import '../../../../core/localization/app_localizations_extension.dart';
import '../../../../shared/widgets/language_selector_sheet.dart';
import '../../../../services/scholarship/scholarship_data_service.dart';
import '../../../../services/authentication/auth_provider.dart';
import '../../../../services/jago/jago_assistant_engine.dart';
import '../../../../services/jago/jago_session_service.dart';

/// JAGO AI Chat Assistant page with persistent in-session history,
/// animated three-dot thinking indicator, and conversational context support.
class JagoChatPage extends StatefulWidget {
  const JagoChatPage({super.key});

  @override
  State<JagoChatPage> createState() => _JagoChatPageState();
}

class _JagoChatPageState extends State<JagoChatPage> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isGenerating = false;
  String? _activeUserId;

  static const List<String> _quickSuggestions = [
    'Check my eligibility',
    'Track my application',
    'What documents do I need?',
    'What documents are pending?',
    'Check my payment status',
    'Which scholarship am I applying for?',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;
    final userId = user?.id ?? user?.mobileNumber ?? 'session_user';
    _activeUserId = userId;

    final sessionService = JagoSessionService();
    if (!sessionService.hasMessages(userId)) {
      final l10n = context.l10n;
      sessionService.seedGreetingIfEmpty(userId, l10n.jagoGreeting);
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage([String? presetText]) async {
    if (_isGenerating) return; // Prevent duplicate submissions

    final text = (presetText ?? _messageController.text).trim();
    if (text.isEmpty) return;

    if (presetText == null) {
      _messageController.clear();
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final student = authProvider.currentUser;
    final userId = student?.id ?? student?.mobileNumber ?? _activeUserId ?? 'session_user';
    final sessionService = JagoSessionService();

    // Prepare conversation history BEFORE appending current message
    final currentMessages = sessionService.getMessages(userId);
    final history = currentMessages
        .where((m) => !m.isError)
        .map((m) => {
              'sender': m.sender == ChatSender.user ? 'user' : 'bot',
              'text': m.content,
            })
        .toList();

    // Immediately display the user's message
    final userMessage = ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      sender: ChatSender.user,
      content: text,
      timestamp: DateTime.now(),
    );
    sessionService.addMessage(userId, userMessage);
    sessionService.setLastFailedMessage(userId, null);

    setState(() {
      _isGenerating = true;
    });
    _scrollToBottom();

    final scholarshipService = Provider.of<ScholarshipDataService>(context, listen: false);
    final locale = Localizations.localeOf(context).languageCode;
    final activeApp = scholarshipService.activeApplications.isNotEmpty
        ? scholarshipService.activeApplications.first
        : null;

    try {
      final responseText = await JagoAssistantEngine.queryBackend(
        message: text,
        conversationHistory: history,
        userId: student?.id,
        applicationId: activeApp?.id,
        locale: locale,
        scholarshipService: scholarshipService,
        student: student,
      );

      if (!mounted) return;

      final botMessage = ChatMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        sender: ChatSender.bot,
        content: responseText,
        timestamp: DateTime.now(),
      );
      sessionService.addMessage(userId, botMessage);

      setState(() {
        _isGenerating = false;
      });
      _scrollToBottom();
    } catch (_) {
      if (!mounted) return;

      sessionService.setLastFailedMessage(userId, text);
      final errorMessage = ChatMessage(
        id: 'err_${DateTime.now().millisecondsSinceEpoch}',
        sender: ChatSender.bot,
        content: JagoAssistantEngine.serviceUnavailableMessage,
        timestamp: DateTime.now(),
        isError: true,
      );
      sessionService.addMessage(userId, errorMessage);

      setState(() {
        _isGenerating = false;
      });
      _scrollToBottom();
    }
  }

  void _retryLastFailedMessage() {
    final userId = _activeUserId;
    final lastFailed = JagoSessionService().getLastFailedMessage(userId);
    if (lastFailed != null && lastFailed.isNotEmpty) {
      _sendMessage(lastFailed);
    }
  }

  void _showQuickActionsSheet(BuildContext context) {
    final l10n = context.l10n;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.flash_on_rounded, color: AppColors.primary, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        l10n.quickActions,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.preMatric.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.checklist, color: AppColors.preMatric),
                  ),
                  title: Text(
                    l10n.eligibilityCheck,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text('Verify criteria against your profile & official schemes'),
                  onTap: () {
                    Navigator.pop(ctx);
                    context.push(RouteNames.eligibilityChecker);
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.nfst.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.track_changes, color: AppColors.nfst),
                  ),
                  title: Text(
                    l10n.trackStatus,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text('Track ongoing applications & scrutiny stages'),
                  onTap: () {
                    Navigator.pop(ctx);
                    context.push(RouteNames.applicationTracking);
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.topClass.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.folder_shared, color: AppColors.topClass),
                  ),
                  title: const Text(
                    'Document Wallet',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text('View and manage DigiLocker verified documents'),
                  onTap: () {
                    Navigator.pop(ctx);
                    context.push(RouteNames.documentWallet);
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.nos.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.payment, color: AppColors.nos),
                  ),
                  title: Text(
                    l10n.jagoQuickPayment,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text('Check DBT installment and PFMS status'),
                  onTap: () {
                    Navigator.pop(ctx);
                    context.push(RouteNames.payments);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final sessionService = JagoSessionService();
    final messages = sessionService.getMessages(_activeUserId);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(2),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/jago_logo.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.jagoAssistantName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                Text(l10n.jagoAssistantSubtitle, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w400)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => _showQuickActionsSheet(context),
            icon: const Icon(Icons.flash_on_rounded),
            tooltip: l10n.quickActions,
          ),
          IconButton(
            onPressed: () => showLanguageSelectorSheet(context),
            icon: const Icon(Icons.language),
            tooltip: l10n.selectLanguageTitle,
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat messages list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: messages.length + (_isGenerating ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < messages.length) {
                  final msg = messages[index];
                  return ChatBubble(
                    message: msg.content,
                    sender: msg.sender,
                    isError: msg.isError,
                    onRetry: msg.isError ? _retryLastFailedMessage : null,
                  );
                } else {
                  // Interactive three-dot thinking indicator
                  return const JagoTypingIndicator();
                }
              },
            ),
          ),
          // Quick suggestions / recommendations within allowed domain
          SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _quickSuggestions.length,
              itemBuilder: (context, index) {
                final suggestion = _quickSuggestions[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ActionChip(
                    label: Text(
                      suggestion,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _isGenerating ? AppColors.textTertiary : AppColors.primary,
                      ),
                    ),
                    backgroundColor: AppColors.surface,
                    side: BorderSide(
                      color: _isGenerating
                          ? AppColors.border
                          : AppColors.primary.withValues(alpha: 0.35),
                      width: 1.2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    elevation: 0.5,
                    pressElevation: 1.5,
                    onPressed: _isGenerating
                        ? null
                        : () {
                            if (suggestion == 'Check my eligibility') {
                              context.push(RouteNames.eligibilityChecker);
                            } else {
                              _sendMessage(suggestion);
                            }
                          },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          // Input row
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: l10n.jagoInputHint,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      onSubmitted: _isGenerating ? null : (_) => _sendMessage(),
                    ),
                  ),
                  IconButton(
                    onPressed: _isGenerating ? null : () => _sendMessage(),
                    icon: const Icon(Icons.send_rounded),
                    color: _isGenerating ? AppColors.textTertiary : AppColors.primary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 3),
    );
  }
}
