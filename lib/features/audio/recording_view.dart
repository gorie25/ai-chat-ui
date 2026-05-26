import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/widgets/bloc_status.dart';
import '../../core/widgets/dialogs_and_bottom_sheets.dart';
import 'controllers/speech_cubit.dart';
import 'widgets/recording_bar.dart';
import 'enum/error_speech_type.dart';

class RecordingView extends StatefulWidget {
  final VoidCallback onStop;
  final Function(String? text) onSend;

  const RecordingView({
    super.key,
    required this.onStop,
    required this.onSend,
  });

  @override
  State<RecordingView> createState() => _RecordingViewState();
}

class _RecordingViewState extends State<RecordingView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<SpeechCubit>().startListening();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SpeechCubit, SpeechState>(
      listenWhen: (previous, current) {
        return current.status == BlocStatus.error &&
            current.errorType != null &&
            (previous.status != current.status ||
                previous.errorType != current.errorType);
      },
      listener: (context, state) {
        switch (state.errorType!) {
          case SpeechErrorType.retry:
          case SpeechErrorType.noMatch:
            CustomFlushProvider.instance.showErrorMessage(
              context,
              title: state.errorType!.errorMessage,
            );
            return;
          case SpeechErrorType.timeout:
            widget.onStop();
            return;

          default:
            final message = state.errorType!.errorMessage;
            final rootNavigator = Navigator.of(context, rootNavigator: true);
            widget.onStop();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final overlayContext = rootNavigator.overlay?.context ?? rootNavigator.context;
              CustomFlushProvider.instance.showErrorMessage(
                overlayContext,
                title: message,
              );
            });
            return;
        }
      },
      builder: (context, state) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RecordingBar(
              onStopTap: widget.onStop,
              onSendTap: widget.onSend,
              soundLevels: state.soundLevels,
            ),
          ],
        );
      },
    );
  }
}
