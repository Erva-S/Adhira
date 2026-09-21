import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/enums/app_enums.dart';
import '../../../../shared/widgets/app_bottom_nav.dart';
import '../../../../shared/widgets/chat_bubble.dart';

/// JAGO AI Chat Assistant page.
class JagoChatPage extends StatefulWidget {
  const JagoChatPage({super.key});

  @override
  State<JagoChatPage> createState() => _JagoChatPageState();
}

class _JagoChatPageState extends State<JagoChatPage> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  final List<_ChatMsg> _messages = [
    _ChatMsg(text: 'Namaste! 🙏 I\'m JAGO, your scholarship assistant. How can I help you today?', sender: ChatSender.bot),
    _ChatMsg(text: 'What is my application status?', sender: ChatSender.user),
    _ChatMsg(text: 'Your Post-Matric Scholarship application (PMS-2025-78432) is currently "Under Review". 5 out of 7 verifications are complete. ST Certificate verification is in progress.', sender: ChatSender.bot),
    _ChatMsg(text: 'When will I receive the next payment?', sender: ChatSender.user),
    _ChatMsg(text: 'Your next disbursement of ₹25,000 (Tuition Fee — Sem 2) is expected in January 2026, after all verifications are complete and state approval is received.', sender: ChatSender.bot),
  ];

  final List<String> _quickActions = [
    '📋 Application Status',
    '💰 Payment Status',
    '📄 Document Help',
    '❓ Am I Eligible?',
  ];

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_ChatMsg(text: text, sender: ChatSender.user));
      _messageController.clear();
      // Mock bot response
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          setState(() {
            _messages.add(_ChatMsg(
              text: 'Thank you for your question! This is a demo response. In the production app, JAGO will provide real-time answers based on your scholarship data.',
              sender: ChatSender.bot,
            ));
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.smart_toy, size: 18, color: AppColors.accent),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('JAGO', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                Text('Scholarship Assistant', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w400)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.language)),
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
          // Quick actions
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _quickActions.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ActionChip(
                    label: Text(_quickActions[index], style: const TextStyle(fontSize: 12)),
                    onPressed: () {
                      _messageController.text = _quickActions[index].replaceAll(RegExp(r'[^\w\s?]'), '').trim();
                      _sendMessage();
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          // Input
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Ask JAGO anything...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  IconButton(
                    onPressed: _sendMessage,
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
