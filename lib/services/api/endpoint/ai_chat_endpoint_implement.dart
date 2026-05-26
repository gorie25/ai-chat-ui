part of 'ai_chat_endpoint.dart';

class AIChatEndpointImplement extends AIChatEndpoint {
  final String prePath = 'api/mobile/chat';

  @override
  EndpointType sendMessage({String? message}) {
    final path = "$prePath/send";

    final Map<String, dynamic> params = {
      if (message != null) 'message': message,
    };

    return EndpointType(
      path: path,
      httpMethod: DioHttpMethod.post,
      parameters: params,
      header: DefaultHeader.instance.defaultHeader,
    );
  }

  @override
  EndpointType getHistory(
    int? page,
    int? limit,
  ) {
    final path = "$prePath/history";

    return EndpointType(
      path: path,
      parameters: {
        'page': page,
        'limit': limit,
      },
      httpMethod: DioHttpMethod.get,
      header: DefaultHeader.instance.defaultHeader,
    );
  }
}
