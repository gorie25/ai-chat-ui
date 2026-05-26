import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import '../../../config/ai_chat_config.dart';
import 'events/chat_ws_event.dart';

class ChatSocketService {
  ChatSocketService._();

  static final instance = ChatSocketService._();
  WebSocketChannel? _channel;

  final _eventController = StreamController<ChatWsEvent>.broadcast();
  Stream<ChatWsEvent> get eventStream => _eventController.stream;

  Future<void> connect() async {
    String? token;
    if (AIChatConfig.getTokenCallback != null) {
      token = await AIChatConfig.getTokenCallback!();
    }

    final baseUrl = AIChatConfig.wsChatUrl;
    final url = token != null ? "$baseUrl?access_token=$token" : baseUrl;
    final uri = Uri.parse(url);

    try {
      _channel = IOWebSocketChannel.connect(
        uri,
        headers: {
          'x-yobuddy-internal-token': AIChatConfig.yobuddyInternalToken,
        },
      );

      _channel!.stream.listen(
        (event) {
          final msg = jsonDecode(event);
          _handleMessage(msg);
        },
        onError: (error) {
          debugPrint("WebSocket error: $error");
        },
        onDone: () {
          _channel = null;
        },
      );
    } catch (e) {
      debugPrint("WebSocket connection failed: $e");
      rethrow;
    }
  }

  void _handleMessage(Map<String, dynamic> msg) {
    switch (msg["type"]) {
      case "connected":
        break;
      case "ai.typing":
        if (msg["status"] == "start") {
          _eventController.add(TypingEvent());
        }
        break;
      case "chat.delta":
        _eventController.add(DeltaEvent(msg["text"] ?? ''));
        break;
      case "chat.response":
        _eventController.add(FinalResponseEvent(msg["text"] ?? ''));
        break;
      case "error":
        _eventController.add(ErrorEvent(msg["code"] ?? ''));
        break;
    }
  }

  void sendMessage(String message) {
    if (message.trim().isEmpty) return;

    final data = {
      "type": "chat.send",
      "text": message,
    };

    try {
      if (_channel != null) {
        _channel!.sink.add(jsonEncode(data));
      } else {
        debugPrint("WebSocket is not connected!");
      }
    } catch (e) {
      debugPrint("Send message failed: $e");
    }
  }

  void disconnect() {
    debugPrint("Disconnecting WebSocket...");
    _channel?.sink.close();
    _channel = null;
  }
}
