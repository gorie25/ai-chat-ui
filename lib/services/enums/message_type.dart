enum MessageType {
  typing('typing'),
  streaming('streaming'),
  response('response');

  final String value;
  const MessageType(this.value);

  static MessageType fromString(String? value) {
    return MessageType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => MessageType.response,
    );
  }
}
