import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/widgets/bloc_status.dart';
import '../../../services/api/events/chat_ws_event.dart';
import '../../../services/api/ws_service.dart';
import '../../../services/api_service.dart';
import '../../../services/enums/message_type.dart';
import '../../../services/models/message.dart';
import '../../../services/models/session.dart';

part 'ai_chat_home_state.dart';

class AIChatHomeCubit extends Cubit<AIChatHomeState> {
  static const _limit = 20;
  int _page = 1;
  StreamSubscription<ChatWsEvent>? _wsSubscription;

  AIChatHomeCubit() : super(const AIChatHomeState()) {
    initial();
  }

  Future<void> initial() async {
    emit(state.copyWith(status: BlocStatus.loading));
    // Delay 5 seconds to showcase the premium shimmer loading skeletons
    await Future.delayed(const Duration(seconds: 5));
    try {
      // Mock messages to make the UI look spectacular and brand-specific for screenshots
      final mockMessages = [
        Message(
          role: 'assistant',
          text: 'Tuyệt vời! Chất liệu bã cà phê thân thiện với môi trường và chống tia UV vượt trội là những điểm cộng rất lớn. Dưới đây là gợi ý kịch bản quảng cáo Polo Cafe của bạn:\n\n**1. Mở đầu:** Hình ảnh một bạn trẻ tự tin dưới cái nắng hè gay gắt mà vẫn vô cùng thoáng mát, năng động.\n**2. Thân bài:** Nhấn mạnh đặc tính khử mùi tự nhiên của bã cà phê và công nghệ chống nắng tia cực tím UV lên tới 98%.\n**3. Kêu gọi:** Trải nghiệm ngay dòng Polo Cafe thế hệ mới độc quyền tại Yody!',
          type: MessageType.response,
        ),
        Message(
          role: 'user',
          text: 'Áo được làm bằng sợi bã cà phê thân thiện môi trường, chống tia UV tốt và rất thoáng mát nhé.',
          type: MessageType.response,
        ),
        Message(
          role: 'assistant',
          text: 'Chào bạn! Tôi là trợ lý ảo Yody AI. Tôi rất sẵn lòng hỗ trợ bạn lên kịch bản quảng cáo. Hãy cho tôi biết thêm thông tin về dòng áo Polo mới ra mắt này nhé (chất liệu gì nổi bật, các tính năng nổi trội khác là gì,...)?',
          type: MessageType.response,
        ),
        Message(
          role: 'user',
          text: 'Tôi muốn viết một kịch bản giới thiệu dòng sản phẩm áo Polo Cafe mới ra mắt của Yody.',
          type: MessageType.response,
        ),
      ];

      emit(state.copyWith(
        status: BlocStatus.success,
        messages: mockMessages,
      ));

      // Attempt WebSocket connection in the background so it doesn't block the UI mock rendering
      try {
        await ChatSocketService.instance.connect();
        _listenToWsEvents();
      } catch (_) {}
    } catch (e) {
      emit(
        state.copyWith(
          status: BlocStatus.error,
          errorMessage: 'Có lỗi khi kết nối đến ứng dụng.',
        ),
      );
    }
  }

  Future<bool> loadData() async {
    emit(state.copyWith(status: BlocStatus.loading));

    final result = await APIService.instance.chat.getHistory(_page, _limit);
    if (result.isSuccess == true && result.data != null) {
      final session = Session.fromChatEntity(result.data!);
      final fetchedMessages = session.messages?.reversed.toList() ?? [];

      if (_page == 1) {
        emit(state.copyWith(
          status: BlocStatus.success,
          messages: fetchedMessages,
        ));
      } else {
        emit(state.copyWith(
          status: BlocStatus.success,
          messages: [...state.messages, ...fetchedMessages],
        ));
      }
      return fetchedMessages.isNotEmpty && fetchedMessages.length == _limit;
    }
    emit(state.copyWith(
      status: BlocStatus.error,
      errorMessage: result.message,
    ));
    return false;
  }

  Future<bool> loadMoreMessages() async {
    _page++;
    return await loadData();
  }

  Future<void> sendMessages({
    required String? message,
    required List<String>? imagePaths,
  }) async {
    final myMsg = Message(
      text: message,
      role: 'user',
    );

    emit(state.copyWith(
      messages: [myMsg, ...state.messages],
      isGenerating: true,
    ));

    // Send it to the real server in background
    try {
      ChatSocketService.instance.sendMessage(message!);
    } catch (_) {}

    // --- START OF OFFLINE REAL-TIME SIMULATION ---
    
    // 1. Trigger "TypingEvent" (isTyping indicator bubble) after 800ms
    await Future.delayed(const Duration(milliseconds: 800));
    if (isClosed) return;

    if (state.isGenerating) {
      final List<Message> updatedMessages = List.from(state.messages);
      if (updatedMessages.firstOrNull?.type != MessageType.typing) {
        updatedMessages.insert(
          0,
          Message(
            type: MessageType.typing,
            text: '...',
            role: 'assistant',
          ),
        );
      }
      emit(state.copyWith(messages: updatedMessages));
    }

    // 2. Trigger "DeltaEvent" (streaming text preview) after 10s
    await Future.delayed(const Duration(seconds: 10));
    if (isClosed) return;

    if (state.isGenerating) {
      final List<Message> updatedMessages = List.from(state.messages);
      // Remove the typing indicator if it is still at the top
      if (updatedMessages.firstOrNull?.type == MessageType.typing) {
        updatedMessages.removeAt(0);
      }

      final streamMessage = Message(
        role: 'assistant',
        text: 'Đang xử lý yêu cầu của bạn...',
        type: MessageType.streaming,
      );
      updatedMessages.insert(0, streamMessage);
      emit(state.copyWith(
        messages: updatedMessages,
        streamingIndex: 0,
      ));
    }

    // 3. Trigger "FinalResponseEvent" (completed message bubble) after 1.5s
    await Future.delayed(const Duration(milliseconds: 1500));
    if (isClosed) return;

    if (state.isGenerating) {
      final List<Message> updatedMessages = List.from(state.messages);
      if (updatedMessages.isNotEmpty && updatedMessages[0].role == 'assistant') {
        updatedMessages[0] = updatedMessages[0].copyWith(
          text: 'Chào bạn! Tôi đã tiếp nhận yêu cầu: "$message". Trợ lý ảo Yody AI luôn sẵn lòng đồng hành cùng bạn để phân tích sản phẩm, lên kịch bản truyền thông và lên kế hoạch thời trang. Bạn có muốn đi sâu hơn vào chi tiết nào không? 👕✨',
          type: MessageType.response,
        );
      }
      emit(state.copyWith(
        messages: updatedMessages,
        streamingIndex: 0,
        isGenerating: false,
      ));
    }
  }

  void clearStreaming() {
    emit(AIChatHomeState(
      status: state.status,
      messages: state.messages,
      session: state.session,
      currrentConversationId: state.currrentConversationId,
      streamingIndex: null,
      page: state.page,
      errorMessage: state.errorMessage,
    ));
  }

  void _listenToWsEvents() {
    _wsSubscription = ChatSocketService.instance.eventStream.listen((event) {
      switch (event) {
        case TypingEvent():
          final List<Message> updatedMessages = List.from(state.messages);
          if (updatedMessages.firstOrNull?.type != MessageType.typing) {
            updatedMessages.insert(
              0,
              Message(
                type: MessageType.typing,
                text: '...',
                role: 'assistant',
              ),
            );
          }
          emit(state.copyWith(messages: updatedMessages));
          break;
        case FinalResponseEvent(:final text):
          final List<Message> updatedMessages = List.from(state.messages);
          final firstMessage = updatedMessages.firstOrNull;

          if (firstMessage != null && firstMessage.isAssistant) {
            final currentDeltaText = firstMessage.text ?? '';
            String finalText = text;

            if (text.trim().isEmpty || text.length < currentDeltaText.length) {
              finalText = currentDeltaText;
            }
            updatedMessages[0] = firstMessage.copyWith(
              text: finalText,
              type: MessageType.response,
            );
          } else {
            updatedMessages.insert(
              0,
              Message(
                text: text,
                role: 'assistant',
                type: MessageType.response,
              ),
            );
          }
          emit(state.copyWith(
            messages: updatedMessages,
            streamingIndex: 0,
            isGenerating: false,
          ));
          break;
        case DeltaEvent(:final text):
          final updatedMessages = List<Message>.from(state.messages);
          if (updatedMessages.isNotEmpty && updatedMessages[0].isAssistant) {
            final firstMessage = updatedMessages[0];
            updatedMessages[0] = firstMessage.copyWith(
              text: text,
              type: MessageType.streaming,
            );
            emit(state.copyWith(
              messages: updatedMessages,
              streamingIndex: 0,
            ));
          }
          break;
        case ErrorEvent():
          emit(state.copyWith(
            isGenerating: false,
          ));
          break;
      }
    });
  }

  @override
  Future<void> close() {
    _wsSubscription?.cancel();
    ChatSocketService.instance.disconnect();
    return super.close();
  }
}
