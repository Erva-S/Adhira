import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/enums/app_enums.dart';
import '../../../../shared/widgets/app_bottom_nav.dart';
import '../../../../shared/widgets/chat_bubble.dart';
import '../../../../core/localization/app_localizations_extension.dart';
import '../../../../shared/widgets/language_selector_sheet.dart';
import '../../../../services/scholarship/scholarship_data_service.dart';
import '../../../../services/authentication/auth_provider.dart';
import '../../../../services/jago/jago_assistant_engine.dart';

/// JAGO AI Chat Assistant page.
class JagoChatPage extends StatefulWidget {
  const JagoChatPage({super.key});

  @override
  State<JagoChatPage> createState() => _JagoChatPageState();
}

class _JagoChatPageState extends State<JagoChatPage> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  bool _initialized = false;

  final List<_ChatMsg> _messages = [];

  static const List<String> _quickSuggestions = [
    'Check my eligibility',
    'Track my application',
    'What documents do I need?',
    'What documents are pending?',
    'Check my payment status',
    'Which scholarship am I applying for?',
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      final l10n = context.l10n;
      _messages.add(_ChatMsg(text: l10n.jagoGreeting, sender: ChatSender.bot));
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

  void _sendMessage([String? presetText]) {
    final text = (presetText ?? _messageController.text).trim();
    if (text.isEmpty) return;

    if (presetText == null) {
      _messageController.clear();
    }

    final history = _messages.map((m) => {
      'sender': m.sender == ChatSender.user ? 'user' : 'bot',
      'text': m.text,
    }).toList();

    setState(() {
      _messages.add(_ChatMsg(text: text, sender: ChatSender.user));
    });
    _scrollToBottom();

    final scholarshipService = Provider.of<ScholarshipDataService>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final student = authProvider.currentUser;
    final locale = Localizations.localeOf(context).languageCode;
    final activeApp = scholarshipService.activeApplications.isNotEmpty
        ? scholarshipService.activeApplications.first
        : null;

    JagoAssistantEngine.queryBackend(
      message: text,
      conversationHistory: history,
      userId: student?.id,
      applicationId: activeApp?.id,
      locale: locale,
      scholarshipService: scholarshipService,
      student: student,
    ).then((responseText) {
      if (!mounted) return;
      setState(() {
        _messages.add(_ChatMsg(text: responseText, sender: ChatSender.bot));
      });
      _scrollToBottom();
    });
  }


  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.smart_toy, size: 18, color: AppColors.accent),
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
            onPressed: () => showLanguageSelectorSheet(context),
            icon: const Icon(Icons.language),
            tooltip: l10n.selectLanguageTitle,
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return ChatBubble(
                  message: msg.text,
                  sender: msg.sender,
                );
              },
            ),
          ),
          // Quick suggestions within allowed domain
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _quickSuggestions.length,
              itemBuilder: (context, index) {
                final suggestion = _quickSuggestions[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ActionChip(
                    label: Text(suggestion, style: const TextStyle(fontSize: 12)),
                    onPressed: () => _sendMessage(suggestion),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          // Input
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
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _sendMessage(),
                    icon: const Icon(Icons.send_rounded),
                    color: AppColors.primary,
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

class _ChatMsg {
  final String text;
  final ChatSender sender;
  const _ChatMsg({required this.text, required this.sender});
}

