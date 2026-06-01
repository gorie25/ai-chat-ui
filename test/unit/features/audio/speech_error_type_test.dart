import 'package:ai_chat_ui/features/audio/enum/error_speech_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SpeechErrorType.fromCodeToType', () {
    test('maps known speech error codes to typed errors', () {
      expect(
        SpeechErrorType.fromCodeToType('error_no_match'),
        SpeechErrorType.noMatch,
      );
      expect(
        SpeechErrorType.fromCodeToType('error_audio_error'),
        SpeechErrorType.microphoneBusy,
      );
      expect(
        SpeechErrorType.fromCodeToType('error_permission'),
        SpeechErrorType.permission,
      );
    });

    test('returns unknown for null or unsupported error codes', () {
      expect(SpeechErrorType.fromCodeToType(null), SpeechErrorType.unknown);
      expect(
        SpeechErrorType.fromCodeToType('unexpected_error'),
        SpeechErrorType.unknown,
      );
    });
  });
}
