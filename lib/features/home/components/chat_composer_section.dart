import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart' as per;
import '../../audio/controllers/speech_cubit.dart';
import '../../audio/recording_view.dart';
import 'attachment_preview.dart';
import 'image_picker_section.dart';
import '../../../config/ai_chat_config.dart';
import '../../../core/theme/custom_colors.dart';
import '../../../core/widgets/custom_textfield.dart';
import '../../../core/widgets/dialogs_and_bottom_sheets.dart';
import '../../../core/widgets/bloc_status.dart';
import '../../../core/services/speech_helpers.dart';

class ChatComposerSection extends StatefulWidget {
  final bool? isGenerating;
  final void Function({String? message, List<String>? imagePaths})? onSend;
  const ChatComposerSection({super.key, this.isGenerating, this.onSend});

  @override
  State<ChatComposerSection> createState() => _ChatComposerSectionState();
}

class _ChatComposerSectionState extends State<ChatComposerSection> {
  List<String> _imagePaths = [];
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  void _handleSend({String? message, List<String>? imagePaths}) {
    if ((message?.isEmpty ?? true) && (imagePaths?.isEmpty ?? true)) return;

    widget.onSend?.call(
      message: message,
      imagePaths: [...?imagePaths],
    );
    _controller.clear();
    setState(() {
      _imagePaths.clear();
    });
  }

  Future<void> _openRecorder(BuildContext context) async {
    // TEMPORARY MOCK: Bypass permission request for UI screenshot/testing
    const isGranted = true;

    if (!isGranted) {
      final permissionDialogResult =
          await CustomDialogProvider.instance.showPermissionDialog(
        context,
        message:
            'Vui lòng cấp quyền Microphone và nhận diện giọng nói để sử dụng tính năng này!',
      );
      if (permissionDialogResult == true) {
        per.openAppSettings();
      }
      return;
    }
    _focusNode.unfocus();

    final cubit = BlocProvider.of<SpeechCubit>(context);
    await CustomBottomSheetHelper.instance
        .showView(
      BlocProvider.value(
        value: cubit,
        child: RecordingView(
          onStop: () {
            if (context.mounted) context.pop();
          },
          onSend: (text) {
            if (context.mounted) {
              context.pop();
              if (text?.isNotEmpty == true) {
                _handleSend(message: text);
              }
            }
          },
        ),
      ),
      context: context,
    )
        .whenComplete(() {
      if (cubit.state.status == BlocStatus.loading) {
        cubit.stopListening();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    TextToSpeechHelper.instance.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 8,
        bottom: 8 + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: BoxDecoration(
        color: CustomColors.white,
        boxShadow: [
          BoxShadow(
            color: CustomColors.black.withOpacity(0.04),
            blurRadius: 28,
            offset: const Offset(0, -8),
          ),
        ],
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(34),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AttachmentPreview(
            imagePaths: _imagePaths,
            onChanged: (imagePaths) {
              _imagePaths = imagePaths;
            },
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (AIChatConfig.showImageSection)
                GestureDetector(
                  onTap: () async {
                    await CustomBottomSheetHelper.instance.showView(
                      ImagePickerSection(
                        onFilesSelected: (paths) {
                          setState(() {
                            _imagePaths.addAll(paths);
                          });
                        },
                      ),
                      context: context,
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.image_outlined,
                      color: CustomColors.color28247C,
                    ),
                  ),
                ),
              Expanded(
                child: CustomTextField(
                  controller: _controller,
                  currentNode: _focusNode,
                  tfMaxLength: 500,
                  maxLines: 5,
                  minLines: 1,
                  keyboardType: TextInputType.multiline,
                  action: TextInputAction.newline,
                  hintText: 'Nhập tin nhắn...',
                  borderRadius: 23,
                  hasBorder: true,
                  focusBorderColor: CustomColors.colorCBD5E0.withOpacity(0.65),
                  textColor: CustomColors.color1A202C,
                  hintTextColor: CustomColors.color9CA3AF,
                  suffixIcon: Padding(
                    padding: const EdgeInsets.only(right: 5),
                    child: GestureDetector(
                      key: const Key('audio-mic-button'),
                      onTap: () {
                        if (widget.isGenerating == true) return;
                        _openRecorder(context);
                      },
                      child: Container(
                        width: 36,
                        height: 36,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: CustomColors.color28247C.withOpacity(
                              widget.isGenerating == true ? 0.06 : 0.08),
                        ),
                        child: Icon(
                          Icons.mic_none_rounded,
                          color: widget.isGenerating == true
                              ? CustomColors.color9CA3AF
                              : CustomColors.color6B7280,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                  suffixIconConstraints: const BoxConstraints(
                    maxWidth: 41,
                    maxHeight: 36,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 15,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () {
                  if (widget.isGenerating == false) {
                    _handleSend(
                      message: _controller.text,
                      imagePaths: _imagePaths,
                    );
                    _focusNode.unfocus();
                  }
                },
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: widget.isGenerating == true
                        ? CustomColors.colorCBD5E0
                        : CustomColors.color28247C,
                    shape: BoxShape.circle,
                    boxShadow: widget.isGenerating == true
                        ? null
                        : [
                            BoxShadow(
                              color: CustomColors.color28247C.withOpacity(0.18),
                              blurRadius: 0,
                              spreadRadius: 6,
                            ),
                          ],
                  ),
                  child: Icon(
                    widget.isGenerating == true
                        ? Icons.stop
                        : Icons.arrow_upward,
                    color: CustomColors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
