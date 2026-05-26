import '../enums/message_type.dart';

class Message {
  Message({
    this.role,
    this.text,
    this.timestamp,
    this.imagePaths,
    this.type,
  });

  String? role;
  String? text;
  List<String>? imagePaths;
  num? timestamp;
  MessageType? type;

  bool get isMe => role == "user";
  bool get isAssistant => role == "assistant";

  Message.fromJson(dynamic json) {
    role = json['role'];
    text = json['text'];
    timestamp = json['timestamp'];
  }

  Map<String, dynamic> toJson({List<String>? ignoreKeys}) {
    final map = <String, dynamic>{};
    map['role'] = role;
    map['text'] = text;
    map['timestamp'] = timestamp;
    if (ignoreKeys?.isNotEmpty == true) {
      map.removeWhere((key, value) => ignoreKeys!.contains(key));
    }
    return map;
  }

  Message copyWith({
    String? role,
    String? text,
    num? timestamp,
    List<String>? imagePaths,
    Object? type = -1,
  }) =>
      Message(
        role: role ?? this.role,
        text: text ?? this.text,
        timestamp: timestamp ?? this.timestamp,
        imagePaths: imagePaths ?? this.imagePaths,
        type: type == -1 ? this.type : (type as MessageType?),
      );
}
