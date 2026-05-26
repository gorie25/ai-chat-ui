import '../../../core/services/network_service.dart';

part 'ai_chat_endpoint_implement.dart';

abstract class AIChatEndpoint {
  EndpointType sendMessage({
    String? message,
  });

  EndpointType getHistory(
    int? page,
    int? limit,
  );
}
