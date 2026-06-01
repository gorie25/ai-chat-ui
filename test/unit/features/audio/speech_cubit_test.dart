import 'package:ai_chat_ui/core/widgets/bloc_status.dart';
import 'package:ai_chat_ui/features/audio/controllers/speech_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SpeechCubit', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('startListening resets text and starts collecting sound levels',
        (tester) async {
      final cubit = SpeechCubit(
        mockTickDuration: const Duration(milliseconds: 1),
        vibrate: (_) {},
      );

      await cubit.startListening();

      expect(cubit.state.status, BlocStatus.loading);
      expect(cubit.state.text, isEmpty);
      expect(cubit.state.soundLevels, isEmpty);

      await tester.pump(const Duration(milliseconds: 3));

      expect(cubit.state.soundLevels, isNotEmpty);
      expect(
        cubit.state.soundLevels,
        everyElement(allOf(greaterThanOrEqualTo(0), lessThanOrEqualTo(1))),
      );

      await cubit.close();
    });

    testWidgets('mock transcript progresses while listening', (tester) async {
      final cubit = SpeechCubit(
        mockTickDuration: const Duration(milliseconds: 1),
        vibrate: (_) {},
      );

      await cubit.startListening();

      await tester.pump(const Duration(milliseconds: 11));
      expect(cubit.state.text, 'Xin chào');

      await tester.pump(const Duration(milliseconds: 10));
      expect(cubit.state.text, 'Xin chào Yody');

      await tester.pump(const Duration(milliseconds: 10));
      expect(cubit.state.text, 'Xin chào Yody AI');

      await cubit.close();
    });

    testWidgets('stopListening returns to initial and stops mock updates',
        (tester) async {
      final cubit = SpeechCubit(
        mockTickDuration: const Duration(milliseconds: 1),
        vibrate: (_) {},
      );

      await cubit.startListening();
      await tester.pump(const Duration(milliseconds: 3));
      final levelsAfterStart = cubit.state.soundLevels.length;

      await cubit.stopListening();
      expect(cubit.state.status, BlocStatus.initial);

      await tester.pump(const Duration(milliseconds: 5));
      expect(cubit.state.soundLevels.length, levelsAfterStart);

      await cubit.close();
    });
  });
}
