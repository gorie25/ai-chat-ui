sealed class ChatWsEvent {}

class TypingEvent extends ChatWsEvent {}

class DeltaEvent extends ChatWsEvent {
  final String text;
  DeltaEvent(this.text);
}

class FinalResponseEvent extends ChatWsEvent {
  final String text;
  FinalResponseEvent(this.text);
}

class ErrorEvent extends ChatWsEvent {
  final String code;
  ErrorEvent(this.code);
}
