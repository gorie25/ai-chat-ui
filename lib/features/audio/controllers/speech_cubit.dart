import 'dart:io';
import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:vibration/vibration.dart';
import '../../../core/widgets/bloc_status.dart';
import '../../../core/services/shared_storage.dart';
import '../enum/result_record_status.dart';
import '../enum/error_speech_type.dart';

part 'speech_state.dart';

class SpeechCubit extends Cubit<SpeechState> {
  SpeechCubit({
    this.mockTickDuration = const Duration(milliseconds: 150),
    void Function(int duration)? vibrate,
  })  : _vibrate =
            vibrate ?? ((duration) => Vibration.vibrate(duration: duration)),
        super(const SpeechState()) {
    _init();
  }

  final SpeechToText _speech = SpeechToText();
  final LocalStorageManager _storage = LocalStorageManager.instance;
  final Duration mockTickDuration;
  final void Function(int duration) _vibrate;

  static const String _localeKey = 'last_used_locale';
  late String localeId;
  double _lastLevel = 0;
  Timer? _mockTimer;

  final List<double> _tempSoundLevels = [];

  Future<void> _init() async {
    await _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    final savedLocale = await _storage.getData(_localeKey);

    if (savedLocale?.isNotEmpty == true) {
      localeId = savedLocale!;
    } else {
      final deviceLocale = _getDeviceLocale();
      await _storage.saveData(deviceLocale, key: _localeKey);
      localeId = deviceLocale;
    }
  }

  String _getDeviceLocale() {
    final deviceLocale = Platform.localeName;
    return deviceLocale.isNotEmpty
        ? deviceLocale.replaceAll('_', '-')
        : 'vi-VN';
  }

  Future<void> _initSpeech() async {
    if (isClosed) return;

    if (_speech.isAvailable) {
      await _speech.stop();
    }

    final isAvailable = await _speech.initialize(
      onError: _onSpeechError,
      onStatus: _onSpeechStatus,
    );

    if (isClosed) return;

    if (!isAvailable) {
      emit(state.copyWith(
        status: BlocStatus.error,
        errorType: SpeechErrorType.notAvailable,
      ));
      return;
    }

    emit(state.copyWith(
      status: BlocStatus.success,
    ));
  }

  void _onSpeechStatus(String status) {
    if (isClosed) return;
    if (status == ResultRecordStatus.done.value ||
        status == ResultRecordStatus.notListening.value) {
      emit(state.copyWith(
        status: BlocStatus.initial,
        text: state.text,
      ));
    }
  }

  void _onSpeechError(SpeechRecognitionError error) {
    if (isClosed) return;
    final errorType = SpeechErrorType.fromCodeToType(error.errorMsg);

    emit(state.copyWith(
      status: BlocStatus.error,
      errorType: errorType,
    ));
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    if (isClosed) return;
    if (result.recognizedWords.isNotEmpty) {
      if (result.finalResult) {
        emit(state.copyWith(
            text: result.recognizedWords, status: BlocStatus.success));
      } else {
        emit(state.copyWith(text: result.recognizedWords));
      }
    }
  }

  double _calculateSoundLevel(double level) {
    double value;

    if (level < 0) {
      const minDb = -60.0;
      const maxDb = 0.0;
      value = ((level - minDb) / (maxDb - minDb)).clamp(0.0, 1.0);
    } else {
      value = (level / 30).clamp(0.0, 1.0);
    }

    if (value < 0.05) value = 0;
    value = (value * 2).clamp(0.0, 1.0);
    value = _lastLevel * 0.7 + value * 0.3;
    _lastLevel = value;
    return value;
  }

  void _onSoundLevelChange(double level) {
    if (isClosed) return;
    final value = _calculateSoundLevel(level);

    _tempSoundLevels.add(value);
    if (_tempSoundLevels.length > 120) {
      _tempSoundLevels.removeAt(0);
    }

    emit(state.copyWith(
      soundLevels: List.from(_tempSoundLevels),
    ));
  }

  Future<void> startListening() async {
    if (isClosed) return;

    // Temporary simulation for screenshot/UI testing
    _vibrate(50);
    _tempSoundLevels.clear();
    _lastLevel = 0;

    emit(state.copyWith(
      status: BlocStatus.loading,
      text: '',
      soundLevels: [],
    ));

    _mockTimer?.cancel();
    int count = 0;
    _mockTimer = Timer.periodic(mockTickDuration, (timer) {
      if (isClosed) {
        timer.cancel();
        return;
      }
      count++;

      // Generate standard realistic waves
      final double mockLevel = (count % 10) / 10.0;
      _onSoundLevelChange(mockLevel * 10);

      // Simulated transcribed text over time
      if (count == 10) {
        emit(state.copyWith(text: 'Xin chào'));
      } else if (count == 20) {
        emit(state.copyWith(text: 'Xin chào Yody'));
      } else if (count == 30) {
        emit(state.copyWith(text: 'Xin chào Yody AI'));
      }
    });
  }

  Future<void> stopListening() async {
    _mockTimer?.cancel();
    if (isClosed) return;
    emit(state.copyWith(
      status: BlocStatus.initial,
    ));
  }

  @override
  Future<void> close() {
    _mockTimer?.cancel();
    return super.close();
  }
}
