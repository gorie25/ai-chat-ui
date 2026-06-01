import 'package:ai_chat_ui/core/widgets/bloc_status.dart';
import 'package:ai_chat_ui/features/audio/controllers/speech_cubit.dart';
import 'package:ai_chat_ui/features/audio/enum/error_speech_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SpeechState', () {
    test('uses recording defaults', () {
      const state = SpeechState();

      expect(state.status, BlocStatus.initial);
      expect(state.text, isEmpty);
      expect(state.soundLevels, isEmpty);
      expect(state.errorType, isNull);
    });

    test('copyWith updates provided fields and preserves omitted fields', () {
      const state = SpeechState(
        status: BlocStatus.loading,
        text: 'Xin chao',
        soundLevels: [0.1, 0.4],
      );

      final updated = state.copyWith(
        status: BlocStatus.error,
        errorType: SpeechErrorType.network,
      );

      expect(updated.status, BlocStatus.error);
      expect(updated.text, 'Xin chao');
      expect(updated.soundLevels, [0.1, 0.4]);
      expect(updated.errorType, SpeechErrorType.network);
    });
  });
}
