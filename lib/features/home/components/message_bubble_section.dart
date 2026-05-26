import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/widgets/custom_list.dart';
import '../controllers/ai_chat_home_cubit.dart';
import '../../../services/models/message.dart';
import 'message_item_view.dart';

class MessageBubbleSection extends StatefulWidget {
  final int? streamingIndex;
  final List<Message> messages;

  const MessageBubbleSection({
    super.key,
    required this.messages,
    this.streamingIndex,
  });

  @override
  State<MessageBubbleSection> createState() => _MessageBubbleSectionState();
}

class _MessageBubbleSectionState extends State<MessageBubbleSection> {
  final ScrollController _scrollController = ScrollController();

  final GlobalKey _latestIsMeKey = GlobalKey();

  double _latestIsMeHeight = 0;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(MessageBubbleSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _measureLatestIsMe();
    });
  }

  void _measureLatestIsMe() {
    final ctx = _latestIsMeKey.currentContext;
    if (ctx == null) return;
    final box = ctx.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    final h = box.size.height;
    if (h != _latestIsMeHeight) {
      setState(() => _latestIsMeHeight = h);
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      final currentOffset = _scrollController.offset;
      if (currentOffset < 10) return;

      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final recentIsMeIndex = widget.messages.indexWhere((m) => m.isMe);

    return BlocListener<AIChatHomeCubit, AIChatHomeState>(
      listenWhen: (previous, current) =>
          current.messages.length > previous.messages.length ||
          current.messages.firstOrNull?.text != previous.messages.firstOrNull?.text,
      listener: (context, state) {
        _scrollToBottom();
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final availableHeight = constraints.maxHeight;
          return CustomList.separated(
            scrollController: _scrollController,
            padding: const EdgeInsets.only(
              left: 12,
              right: 12,
              top: 8,
              bottom: 80,
            ),
            reverse: true,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            onLoadMore: (done, cancel) async {
              final result = await context.read<AIChatHomeCubit>().loadMoreMessages();
              if (result) {
                done();
              } else {
                cancel();
              }
            },
            children: List.generate(widget.messages.length, (index) {
              final message = widget.messages[index];
              final isLatestIsMe = index == recentIsMeIndex;

              final messageView = MessageItemView(
                key: isLatestIsMe ? _latestIsMeKey : null,
                message: message,
                isStreaming: widget.streamingIndex == index,
              );

              if (index == 0 &&
                  message.isAssistant &&
                  recentIsMeIndex == 1 &&
                  _latestIsMeHeight > 0) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  constraints: BoxConstraints(
                    minHeight: (availableHeight - _latestIsMeHeight - 88).clamp(0.0, availableHeight),
                  ),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: messageView,
                  ),
                );
              }

              return messageView;
            }),
          );
        },
      ),
    );
  }
}
