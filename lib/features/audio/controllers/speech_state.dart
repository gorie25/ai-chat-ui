part of 'speech_cubit.dart';

class SpeechState extends BaseState with EquatableMixin {
  const SpeechState({
    super.status = BlocStatus.initial,
    super.message,
    this.text = '',
    this.soundLevels = const [],
    this.errorType,
  });

  final String text;
  final List<double> soundLevels;
  final SpeechErrorType? errorType;

  SpeechState copyWith({
    BlocStatus? status,
    String? message,
    String? text,
    List<double>? soundLevels,
    SpeechErrorType? errorType,
  }) {
    return SpeechState(
      status: status ?? this.status,
      message: message ?? this.message,
      text: text ?? this.text,
      soundLevels: soundLevels ?? this.soundLevels,
      errorType: errorType ?? this.errorType,
    );
  }

  @override
  List<Object?> get props => [
    status,
    message,
    text,
    soundLevels,
    errorType,
  ];
}
