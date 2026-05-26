extension IntExtension on int {
  String formatTimer() {
    final minute = this ~/ 60;
    final second = this % 60;
    final minuteString = '${minute < 10 ? '0' : ''}$minute';
    final secondString = '${second < 10 ? '0' : ''}$second';
    return '$minuteString:$secondString';
  }
}
