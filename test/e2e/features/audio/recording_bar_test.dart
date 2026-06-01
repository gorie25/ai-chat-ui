import 'package:ai_chat_ui/core/widgets/bloc_status.dart';
import 'package:ai_chat_ui/features/audio/controllers/speech_cubit.dart';
import 'package:ai_chat_ui/features/audio/widgets/recording_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TestSpeechCubit extends SpeechCubit {
  TestSpeechCubit(SpeechState initialState)
      : super(
          mockTickDuration: const Duration(milliseconds: 1),
          vibrate: (_) {},
        ) {
    emit(initialState);
  }

  void setSpeechState(SpeechState state) => emit(state);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget buildSubject({
    required SpeechCubit cubit,
    required VoidCallback onStopTap,
    required void Function(String? text) onSendTap,
    List<double> soundLevels = const [],
  }) {
    return MaterialApp(
      home: Scaffold(
        body: BlocProvider<SpeechCubit>.value(
          value: cubit,
          child: RecordingBar(
            onStopTap: onStopTap,
            onSendTap: onSendTap,
            soundLevels: soundLevels,
          ),
        ),
      ),
    );
  }

  testWidgets('shows listening placeholder while recording', (tester) async {
    final cubit = TestSpeechCubit(
      const SpeechState(status: BlocStatus.loading),
    );
    addTearDown(cubit.close);

    await tester.pumpWidget(
      buildSubject(
        cubit: cubit,
        onStopTap: () {},
        onSendTap: (_) {},
      ),
    );

    expect(find.byKey(const Key('audio-recording-bar')), findsOneWidget);
    expect(find.byKey(const Key('audio-transcript-text')), findsOneWidget);
    expect(find.text('Đang lắng nghe...'), findsOneWidget);
    expect(find.byKey(const Key('audio-send-button')), findsNothing);
  });

  testWidgets(
      'shows stopped placeholder without send button when text is empty',
      (tester) async {
    final cubit = TestSpeechCubit(const SpeechState());
    addTearDown(cubit.close);

    await tester.pumpWidget(
      buildSubject(
        cubit: cubit,
        onStopTap: () {},
        onSendTap: (_) {},
      ),
    );

    expect(find.text('Đã dừng'), findsOneWidget);
    expect(find.byKey(const Key('audio-send-button')), findsNothing);
  });

  testWidgets('sends the recognized transcript after recording stops',
      (tester) async {
    String? sentText;
    final cubit = TestSpeechCubit(
      const SpeechState(
        status: BlocStatus.initial,
        text: 'Xin chào Yody AI',
      ),
    );
    addTearDown(cubit.close);

    await tester.pumpWidget(
      buildSubject(
        cubit: cubit,
        onStopTap: () {},
        onSendTap: (text) => sentText = text,
      ),
    );

    expect(find.text('Xin chào Yody AI'), findsOneWidget);
    expect(find.byKey(const Key('audio-send-button')), findsOneWidget);

    await tester.tap(find.byKey(const Key('audio-send-button')));
    await tester.pump();

    expect(sentText, 'Xin chào Yody AI');
  });

  testWidgets('calls stop callback when stop control is tapped',
      (tester) async {
    var stopCount = 0;
    final cubit = TestSpeechCubit(
      const SpeechState(status: BlocStatus.loading),
    );
    addTearDown(cubit.close);

    await tester.pumpWidget(
      buildSubject(
        cubit: cubit,
        onStopTap: () => stopCount++,
        onSendTap: (_) {},
      ),
    );

    await tester.tap(find.byKey(const Key('audio-stop-button')));
    await tester.pump();

    expect(stopCount, 1);
  });
}
