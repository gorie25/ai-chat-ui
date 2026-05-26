import 'api/ai_chat_service.dart';
import 'api/ai_chat_service_implement.dart';
import '../config/ai_chat_config.dart';
import '../core/services/network_service.dart';

class APIService {
  static APIService? _instance;
  static APIService get instance {
    _instance ??= APIService();
    return _instance!;
  }

  final RestfulRequest _network = RestfulRequestImplement(
    url: AIChatConfig.chatApiUrl,
  );

  AIChatService? _chat;

  AIChatService get chat {
    _chat ??= AIChatServiceImplement(network: _network);
    return _chat!;
  }
}
