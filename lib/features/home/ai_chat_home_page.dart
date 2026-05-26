import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/custom_colors.dart';
import '../../core/widgets/custom_text.dart';
import '../../core/widgets/dialogs_and_bottom_sheets.dart';
import '../../core/widgets/bloc_status.dart';
import 'components/chat_composer_section.dart';
import 'components/message_bubble_section.dart';
import 'controllers/ai_chat_home_cubit.dart';
import 'shimmers/ai_chat_shimmer.dart';

class AIChatHomePage extends StatelessWidget {
  const AIChatHomePage({super.key});

  Future<void> sendMessage(BuildContext context, {String? message, List<String>? imagePaths}) =>
      context.read<AIChatHomeCubit>().sendMessages(message: message, imagePaths: imagePaths);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.colorF5F6FA,
      resizeToAvoidBottomInset: false,
      body: BlocConsumer<AIChatHomeCubit, AIChatHomeState>(
        listenWhen: (previous, current) =>
            current.errorMessage != previous.errorMessage &&
            current.errorMessage?.isNotEmpty == true,
        listener: (context, state) {
          CustomFlushProvider.instance.showErrorMessage(
            context,
            title: state.errorMessage!,
          );
        },
        builder: (context, state) {
          if (state.messages.isEmpty) {
            switch (state.status) {
              case BlocStatus.initial:
                return const SizedBox.shrink();
              case BlocStatus.loading:
                return const AiChatShimmer();
              case BlocStatus.error:
              case BlocStatus.success:
              default:
                return _AIChatEmptyHomeView(
                  onSend: ({message, imagePaths}) =>
                      sendMessage(context, message: message, imagePaths: imagePaths),
                );
            }
          }

          return Stack(
            children: [
              Column(
                children: [
                  const SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(24, 18, 24, 8),
                      child: _AIChatHeader(),
                    ),
                  ),
                  Expanded(
                    child: MessageBubbleSection(
                      messages: state.messages,
                      streamingIndex: state.streamingIndex,
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: ChatComposerSection(
                    isGenerating: state.isGenerating,
                    onSend: ({message, imagePaths}) =>
                        sendMessage(context, message: message, imagePaths: imagePaths),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AIChatEmptyHomeView extends StatelessWidget {
  const _AIChatEmptyHomeView({required this.onSend});

  final Function({String? message, List<String>? imagePaths}) onSend;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            const SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(24, 18, 24, 0),
                child: _AIChatHeader(),
              ),
            ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomText.base(
                      'Xin chào! 👋',
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: CustomColors.color1A202C,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    CustomText.regular(
                      'Tôi có thể giúp gì cho bạn hôm nay?',
                      fontSize: 16,
                      color: CustomColors.color6B7280,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: ChatComposerSection(
              isGenerating: false,
              onSend: onSend,
            ),
          ),
        ),
      ],
    );
  }
}

class _AIChatHeader extends StatelessWidget {
  const _AIChatHeader();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Center(
        child: RichText(
          text: const TextSpan(
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: CustomColors.color28247C,
            ),
            children: [
              TextSpan(text: 'Yody'),
              TextSpan(
                text: ' AI',
                style: TextStyle(color: CustomColors.color28247C),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
