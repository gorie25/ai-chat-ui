import 'package:ai_chat_ui/core/widgets/bloc_status.dart';
import 'package:ai_chat_ui/features/audio/controllers/speech_cubit.dart';
import 'package:ai_chat_ui/features/audio/enum/error_speech_type.dart';
import 'package:ai_chat_ui/features/audio/recording_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecordingViewTestCubit extends SpeechCubit {
  RecordingViewTestCubit()
      : super(
          mockTickDuration: const Duration(milliseconds: 1),
          vibrate: (_) {},
        );

  var startCount = 0;

  @override
  Future<void> startListening() async {
    startCount++;
    emit(state.copyWith(status: BlocStatus.loading));
  }

  void emitSpeechError(SpeechErrorType type) {
    emit(state.copyWith(status: BlocStatus.error, errorType: type));
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget buildSubject({
    required RecordingViewTestCubit cubit,
    required VoidCallback onStop,
    required void Function(String? text) onSend,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: BlocProvider<SpeechCubit>.value(
          value: cubit,
          child: RecordingView(
            onStop: onStop,
            onSend: onSend,
          ),
        ),
      ),
    );
  }

  testWidgets('starts listening after the first frame', (tester) async {
    final cubit = RecordingViewTestCubit();
    addTearDown(cubit.close);

    await tester.pumpWidget(
      buildSubject(
        cubit: cubit,
        onStop: () {},
        onSend: (_) {},
      ),
    );

    expect(cubit.startCount, 1);
  });

  testWidgets('timeout error stops recording', (tester) async {
    var stopCount = 0;
    final cubit = RecordingViewTestCubit();
    addTearDown(cubit.close);

    await tester.pumpWidget(
      buildSubject(
        cubit: cubit,
        onStop: () => stopCount++,
        onSend: (_) {},
      ),
    );
    await tester.pump();

    cubit.emitSpeechError(SpeechErrorType.timeout);
    await tester.pump();

    expect(stopCount, 1);
  });

  testWidgets('retryable errors show an error snackbar without stopping',
      (tester) async {
    var stopCount = 0;
    final cubit = RecordingViewTestCubit();
    addTearDown(cubit.close);

    await tester.pumpWidget(
      buildSubject(
        cubit: cubit,
        onStop: () => stopCount++,
        onSend: (_) {},
      ),
    );
    await tester.pump();

    cubit.emitSpeechError(SpeechErrorType.noMatch);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 750));

    expect(stopCount, 0);
    expect(find.text(SpeechErrorType.noMatch.errorMessage), findsOneWidget);
  });
}
