import 'package:flutter_dotenv/flutter_dotenv.dart';

class AIChatConfig {
  AIChatConfig._();

  static bool? _showImageSection;
  static String? _chatApiUrl;
  static String? _wsChatUrl;
  static String? _yobuddyInternalToken;
  static String? _staticAuthToken;

  static bool get showImageSection =>
      _showImageSection ?? (dotenv.env['AI_CHAT_SHOW_IMAGE']?.toLowerCase() == 'true');

  static String get chatApiUrl =>
      _chatApiUrl ?? (dotenv.env['AI_CHAT_API_URL'] ?? '');

  static String get wsChatUrl =>
      _wsChatUrl ?? (dotenv.env['AI_CHAT_WS_URL'] ?? '');

  static String get yobuddyInternalToken =>
      _yobuddyInternalToken ?? (dotenv.env['AI_CHAT_INTERNAL_TOKEN'] ?? '');

  static String? get staticAuthToken =>
      _staticAuthToken ?? dotenv.env['AI_CHAT_AUTH_TOKEN'];

  // Dynamic token hooks
  static Future<String?> Function()? getTokenCallback = () async => staticAuthToken;
  static Future<bool> Function()? refreshTokenCallback;

  static void init({
    bool? showImage,
    String? apiBaseUrl,
    String? webSocketUrl,
    String? internalToken,
    String? authToken,
    Future<String?> Function()? tokenCallback,
    Future<bool> Function()? refreshToken,
  }) {
    if (showImage != null) _showImageSection = showImage;
    if (apiBaseUrl != null && apiBaseUrl.isNotEmpty) _chatApiUrl = apiBaseUrl;
    if (webSocketUrl != null && webSocketUrl.isNotEmpty) _wsChatUrl = webSocketUrl;
    if (internalToken != null && internalToken.isNotEmpty) _yobuddyInternalToken = internalToken;
    if (authToken != null && authToken.isNotEmpty) {
      _staticAuthToken = authToken;
      getTokenCallback ??= () async => staticAuthToken;
    }
    if (tokenCallback != null) getTokenCallback = tokenCallback;
    if (refreshToken != null) refreshTokenCallback = refreshToken;
  }
}
