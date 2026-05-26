import 'message.dart';

class ChatEntity {
  ChatEntity({
    this.sessionId,
    this.messages,
  });

  String? sessionId;
  List<Message>? messages;

  ChatEntity.fromJson(dynamic json) {
    sessionId = json['sessionId'];
    if (json['messages'] != null) {
      messages = [];
      json['messages'].forEach((v) {
        messages?.add(Message.fromJson(v));
      });
    }
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

  ChatEntity copyWith({
    String? sessionId,
    List<Message>? messages,
  }) =>
      ChatEntity(
        sessionId: sessionId ?? this.sessionId,
        messages: messages ?? this.messages,
      );
}
