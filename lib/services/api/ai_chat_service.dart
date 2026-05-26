import '../models/chat_entity.dart';
import '../../core/services/network_service.dart';

abstract class AIChatService {
  AIChatService({
    required this.network,
  });
  final RestfulRequest network;

  Future<bool> sendMessage({
    required String message,
  });

  Future<BaseModel<ChatEntity>> getHistory(
    int? page,
    int? limit,
  );
}
