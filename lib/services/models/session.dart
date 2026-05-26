import 'chat_entity.dart';
import 'message.dart';

class Session {
  Session({
    this.sessionId,
    this.messages,
  });

  String? sessionId;
  List<Message>? messages;

  Session.fromJson(dynamic json) {
    sessionId = json['sessionId'];
    if (json['messages'] != null) {
      messages = [];
      json['messages'].forEach((v) {
        messages?.add(Message.fromJson(v));
      });
    }
  }

  factory Session.fromChatEntity(ChatEntity entity) {
    return Session(
      sessionId: entity.sessionId,
      messages: entity.messages,
    );
  }

  Map<String, dynamic> toJson({List<String>? ignoreKeys}) {
    final map = <String, dynamic>{};
    map['sessionId'] = sessionId;
    if (messages != null) {
      map['messages'] = messages?.map((v) => v.toJson(ignoreKeys: ignoreKeys)).toList();
    }
    if (ignoreKeys?.isNotEmpty == true) {
      map.removeWhere((key, value) => ignoreKeys!.contains(key));
    }
    return map;
  }

  Session copyWith({
    String? sessionId,
    List<Message>? messages,
  }) =>
      Session(
        sessionId: sessionId ?? this.sessionId,
        messages: messages ?? this.messages,
      );
}
