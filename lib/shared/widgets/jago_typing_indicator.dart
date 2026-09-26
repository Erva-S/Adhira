import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

/// Animated three-dot typing / thinking indicator for JAGO AI Assistant.
///
/// Displays a natural, pulsing `● ● ●` animation inside a bot chat bubble
/// while JAGO is actively processing and querying Gemini.
class JagoTypingIndicator extends StatefulWidget {
  const JagoTypingIndicator({super.key});

  @override
  State<JagoTypingIndicator> createState() => _JagoTypingIndicatorState();
}

class _JagoTypingIndicatorState extends State<JagoTypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildDot(int index) {
    final startInterval = (index * 0.2);
    final endInterval = (startInterval + 0.5).clamp(0.0, 1.0);

    final animation = CurvedAnimation(
      parent: _controller,
      curve: Interval(startInterval, endInterval, curve: Curves.easeInOut),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        // Value oscillates using a sine wave progression based on the interval animation
        final progress = (animation.value <= 0.5)
            ? animation.value * 2
            : (1.0 - animation.value) * 2;

        final scale = 0.75 + (0.35 * progress);
        final opacity = 0.35 + (0.65 * progress);
        final translateY = -4.0 * progress;

        return Transform.translate(
          offset: Offset(0, translateY),
          child: Transform.scale(
            scale: scale,
            child: Opacity(
              opacity: opacity,
              child: Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(16),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildDot(0),
            _buildDot(1),
            _buildDot(2),
          ],
        ),
      ),
    );
  }
}
