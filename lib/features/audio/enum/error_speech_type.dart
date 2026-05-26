enum SpeechErrorType {
  timeout('error_speech_timeout', 'Không nghe thấy âm thanh.'),
  noMatch('error_no_match', 'Chưa nghe rõ, vui lòng nói lại...'),
  retry('error_retry', 'Chưa nghe rõ, vui lòng nói lại...'),
  microphoneBusy(
      'error_audio_error', 'Mic đang bị chiếm dụng bởi ứng dụng khác!'),
  network('error_network', 'Lỗi kết nối mạng. Vui lòng kiểm tra lại.'),
  permission('error_permission', 'Chưa có quyền sử dụng Microphone.'),
  notAvailable('error_not_available', 'Chuyển đổi giọng nói chưa sẵn sàng'),
  unknown('unknown', 'Đã xảy ra lỗi không xác định khi ghi âm.');

  final String code;
  final String errorMessage;

  const SpeechErrorType(this.code, this.errorMessage);

  static SpeechErrorType fromCodeToType(String? errorCode) {
    if (errorCode == null) return SpeechErrorType.unknown;

    return SpeechErrorType.values.firstWhere(
      (e) => e.code == errorCode,
      orElse: () => SpeechErrorType.unknown,
    );
  }
}
