import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../../config/ai_chat_config.dart';
import '../../../core/theme/custom_colors.dart';
import '../../../core/widgets/custom_text.dart';
import '../../../core/widgets/dialogs_and_bottom_sheets.dart';
import '../../../core/services/speech_helpers.dart';
import '../../../services/enums/message_type.dart';
import '../../../services/models/message.dart';
import 'ai_typing_indicator.dart';
import 'streaming_markdown.dart';

class MessageItemView extends StatelessWidget {
  const MessageItemView({
    super.key,
    required this.message,
    this.isStreaming = false,
  });

  final Message message;
  final bool isStreaming;

  @override
  Widget build(BuildContext context) {
    final isMe = message.isMe;
    final isShowImage = AIChatConfig.showImageSection && message.imagePaths?.isNotEmpty == true;
    final isShowText = message.text?.isNotEmpty == true;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          if (isShowImage)
            Padding(
              padding: EdgeInsets.only(bottom: isShowText ? 12 : 0),
              child: Align(
                alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: message.imagePaths!.map((path) {
                      return Image.file(
                        File(path),
                        width: message.imagePaths!.length > 1 ? 130 : 280,
                        height: 180,
                        cacheHeight: 180,
                        filterQuality: FilterQuality.low,
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          if (isShowText)
            isMe
                ? UserMessageItem(message: message)
                : AssistantMessageItem(message: message, isStreaming: isStreaming),
        ],
      ),
    );
  }
}

class UserMessageItem extends StatelessWidget {
  final Message message;
  const UserMessageItem({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 280,
          minWidth: 44,
          minHeight: 40,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: const BoxDecoration(
            color: CustomColors.color28247C,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
          ),
          child: CustomText.base(
            message.text ?? '',
            fontWeight: FontWeight.w500,
            color: CustomColors.white,
          ),
        ),
      ),
    );
  }
}

class AssistantMessageItem extends StatelessWidget {
  final Message message;
  final bool isStreaming;

  const AssistantMessageItem({
    super.key,
    required this.message,
    this.isStreaming = false,
  });

  @override
  Widget build(BuildContext context) {
    final isTypingMessage = message.type == MessageType.typing;

    if (isTypingMessage) {
      return const Align(
        alignment: Alignment.centerLeft,
        child: AITypingIndicator(),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.sizeOf(context).width * 0.9,
            ),
            child: isStreaming
                ? StreamingMarkdown(
                    message: message,
                    styleSheet: _buildMarkdownStyle(context, false),
                  )
                : MarkdownBody(
                    data: message.text ?? '',
                    styleSheet: _buildMarkdownStyle(context, false),
                  ),
          ),
          AIActionButtons(messageText: message.text ?? ''),
        ],
      ),
    );
  }
}

void copyToClipboard(String text) {
  Clipboard.setData(ClipboardData(text: text));
}

void handleShareText(String text, {Rect? sharePositionOrigin}) {
  ShareHelper.instance.shareText(text: text, sharePositionOrigin: sharePositionOrigin);
}

class AIActionButtons extends StatefulWidget {
  final String messageText;
  const AIActionButtons({super.key, required this.messageText});

  @override
  State<AIActionButtons> createState() => _AIActionButtonsState();
}

class _AIActionButtonsState extends State<AIActionButtons> {
  bool _isCopied = false;
  final TextToSpeechHelper _ttsHelper = TextToSpeechHelper.instance;

  void _handleCopy() {
    Clipboard.setData(ClipboardData(text: widget.messageText));
    setState(() {
      _isCopied = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isCopied = false;
        });
      }
    });
  }

  Future<void> _handleSpeak() async {
    try {
      await _ttsHelper.speak(widget.messageText);
    } on SilentModeException catch (e) {
      CustomDialogProvider.instance.showMessageDialog(
        context,
        message: e.message,
      );
    }
  }

  void _handleShare(BuildContext context) {
    final box = context.findRenderObject() as RenderBox?;
    final rect = box != null ? box.localToGlobal(Offset.zero) & box.size : null;
    handleShareText(widget.messageText, sharePositionOrigin: rect);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0).copyWith(top: 8),
      child: Row(
        children: [
          _actionButton(
            icon: _isCopied ? Icons.check_rounded : Icons.content_copy,
            onTap: (_) => _handleCopy(),
          ),
          const SizedBox(width: 16),
          _actionButton(
            icon: Icons.ios_share_rounded,
            onTap: _handleShare,
          ),
          const SizedBox(width: 16),
          _actionButton(
            icon: Icons.volume_up_rounded,
            onTap: (_) => _handleSpeak(),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required void Function(BuildContext) onTap,
    Color? color,
  }) {
    return Builder(
      builder: (btnContext) {
        return GestureDetector(
          onTap: () => onTap(btnContext),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              icon,
              key: ValueKey<IconData>(icon),
              size: 18,
              color: color ?? CustomColors.color718096,
            ),
          ),
        );
      },
    );
  }
}

MarkdownStyleSheet _buildMarkdownStyle(BuildContext context, bool isMe) {
  const Color textColor = CustomColors.color1A202C;

  return MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
    p: const TextStyle(
      color: textColor,
      fontSize: 15,
      height: 1.5,
    ),
    code: const TextStyle(
      color: CustomColors.color002D5A,
      fontFamily: 'monospace',
      fontSize: 14,
      backgroundColor: CustomColors.colorE8EEF6,
    ),
    h1: const TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 22),
    h2: const TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 20),
    h3: const TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 18),
    h4: const TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16),
    h5: const TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 14),
    h6: const TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 12),
    strong: const TextStyle(color: textColor, fontWeight: FontWeight.bold),
    em: const TextStyle(color: textColor, fontStyle: FontStyle.italic),
    listBullet: const TextStyle(color: textColor, fontSize: 15),
    codeblockDecoration: BoxDecoration(
      color: CustomColors.colorE8EEF6,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: CustomColors.colorCBD5E0.withOpacity(0.5)),
    ),
    codeblockPadding: const EdgeInsets.all(12),
    a: const TextStyle(
      color: CustomColors.color002D5A,
      decoration: TextDecoration.underline,
    ),
    blockSpacing: 10,
  );
}
