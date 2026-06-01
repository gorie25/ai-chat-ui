import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../controllers/speech_cubit.dart';
import 'recording_timer.dart';
import 'waveform_view.dart';
import '../../../core/theme/custom_colors.dart';
import '../../../core/widgets/custom_text.dart';
import '../../../core/widgets/bloc_status.dart';

class RecordingBar extends StatelessWidget {
  final VoidCallback onStopTap;
  final Function(String? text) onSendTap;
  final List<double> soundLevels;

  const RecordingBar({
    super.key,
    required this.onStopTap,
    required this.onSendTap,
    required this.soundLevels,
  });

  void _handleSend(BuildContext context) {
    final text = context.read<SpeechCubit>().state.text;
    if (text.trim().isEmpty) return;
    onSendTap(text);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<SpeechCubit>().state;
    final isListening = state.status == BlocStatus.loading;
    final hasText = state.text.trim().isNotEmpty;
    final transcriptText = hasText
        ? state.text
        : isListening
            ? 'Đang lắng nghe...'
            : 'Đã dừng';

    return RecordingTimerWidget(
      isListening: isListening,
      builder: (context, duration, formattedTime) {
        return Container(
          key: const Key('audio-recording-bar'),
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(
            24,
            12,
            24,
            20 + MediaQuery.paddingOf(context).bottom,
          ),
          decoration: BoxDecoration(
            color: CustomColors.white,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(36),
            ),
            boxShadow: [
              BoxShadow(
                color: CustomColors.color1A202C.withOpacity(0.10),
                blurRadius: 28,
                offset: const Offset(0, -8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                key: const Key('audio-stop-button'),
                onTap: onStopTap,
                child: Container(
                  width: 46,
                  height: 5,
                  decoration: BoxDecoration(
                    color: CustomColors.colorCBD5E0.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              CustomText.base(
                formattedTime,
                fontSize: 30,
                fontWeight: FontWeight.w600,
                color: CustomColors.color28247C,
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 60,
                width: double.infinity,
                child: WaveformView(
                  key: const Key('audio-waveform'),
                  soundLevels: soundLevels,
                  duration: duration,
                  isListening: isListening,
                ),
              ),
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(minHeight: 96),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: CustomText.base(
                    transcriptText,
                    key: const Key('audio-transcript-text'),
                    fontSize: 20,
                    color: CustomColors.color1A202C,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              if (!isListening && hasText) ...[
                GestureDetector(
                  key: const Key('audio-send-button'),
                  onTap: () => _handleSend(context),
                  child: const Icon(
                    Icons.telegram,
                    color: CustomColors.color28247C,
                    size: 72,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
