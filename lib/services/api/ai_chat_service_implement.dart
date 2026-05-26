import 'ai_chat_service.dart';
import 'endpoint/ai_chat_endpoint.dart';
import '../models/chat_entity.dart';
import '../../core/services/network_service.dart';

class AIChatServiceImplement extends AIChatService {
  AIChatServiceImplement({
    required super.network,
  });

  final AIChatEndpoint endpoint = AIChatEndpointImplement();

  @override
  Future<BaseModel<ChatEntity>> getHistory(
    int? page,
    int? limit,
  ) async {
    final response = await network.requestData(
      endpoint.getHistory(page, limit),
    );

    ChatEntity chatEntity = ChatEntity();
    if (response.isSuccess) {
      chatEntity = ChatEntity.fromJson(response.data);
    }
    return BaseModel(
      status: response.status,
      message: response.message,
      isSuccess: response.isSuccess,
      pageCount: int.tryParse(response.headers?.value('X-Total-Count') ?? ''),
      data: chatEntity,
    );
  }

  @override
  Future<bool> sendMessage({required String message}) async {
    final response =
        await network.requestData(endpoint.sendMessage(message: message));
    return response.isSuccess;
  }
}
