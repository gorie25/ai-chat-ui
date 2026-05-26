part of 'ai_chat_home_cubit.dart';

enum AIChatStatus { initial, loading, success, failure }

class AIChatHomeState extends BaseState {
  const AIChatHomeState({
    super.status,
    this.messages = const [],
    this.session,
    this.currrentConversationId,
    this.streamingIndex,
    this.page = 0,
    this.errorMessage,
    this.isGenerating = false,
  });

  final List<Message> messages;
  final Session? session;
  final String? currrentConversationId;
  final int? streamingIndex;
  final int page;
  final String? errorMessage;
  final bool isGenerating;

  AIChatHomeState copyWith({
    BlocStatus? status,
    String? message,
    List<Message>? messages,
    String? currrentConversationId,
    int? streamingIndex,
    Session? session,
    int? page,
    String? errorMessage,
    bool? isGenerating,
  }) {
    return AIChatHomeState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      currrentConversationId: currrentConversationId ?? this.currrentConversationId,
      session: session ?? this.session,
      streamingIndex: streamingIndex ?? this.streamingIndex,
      page: page ?? this.page,
      errorMessage: errorMessage ?? this.errorMessage,
      isGenerating: isGenerating ?? this.isGenerating,
    );
  }
}
