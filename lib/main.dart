import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'config/ai_chat_config.dart';
import 'core/theme/custom_colors.dart';
import 'core/widgets/custom_text.dart';
import 'core/widgets/custom_textfield.dart';
import 'router/ai_chat_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      initialLocation: '/ai_chat',
      routes: [
        GoRoute(
          path: '/',
          redirect: (context, state) => '/ai_chat',
        ),
        AIChatRouter.shareInstance.router,
      ],
    );

    return MaterialApp.router(
      title: 'Yody AI Chat Template',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        textTheme: GoogleFonts.outfitTextTheme(
          Theme.of(context).textTheme,
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: CustomColors.color28247C,
          primary: CustomColors.color28247C,
        ),
      ),
      routerConfig: router,
    );
  }
}

class TemplateLandingPage extends StatefulWidget {
  const TemplateLandingPage({super.key});

  @override
  State<TemplateLandingPage> createState() => _TemplateLandingPageState();
}

class _TemplateLandingPageState extends State<TemplateLandingPage> {
  final _wsController = TextEditingController(text: 'wss://buddy-orchestrator.yody.io/ws/mobile-chat/');
  final _apiController = TextEditingController(text: 'https://buddy-orchestrator.yody.io/');
  final _tokenController = TextEditingController();
  final _internalTokenController = TextEditingController(text: 'qESg4<GAT6blYYCtpAfrPWrKEQAgsrFmwyc0cW73Lck2OfFM4oyPVDi0moLw3bbb');
  bool _showImageSection = true;

  @override
  void dispose() {
    _wsController.dispose();
    _apiController.dispose();
    _tokenController.dispose();
    _internalTokenController.dispose();
    super.dispose();
  }

  void _launchTemplate(BuildContext context) {
    // Initialize the template configuration dynamically!
    AIChatConfig.init(
      showImage: _showImageSection,
      apiBaseUrl: _apiController.text.trim(),
      webSocketUrl: _wsController.text.trim(),
      internalToken: _internalTokenController.text.trim(),
      tokenCallback: () async {
        return _tokenController.text.trim().isNotEmpty ? _tokenController.text.trim() : null;
      },
    );

    context.push('/ai_chat');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE8EEF6),
              CustomColors.white,
              Color(0xFFF5F6FA),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Premium glassmorphic header
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: CustomColors.color28247C.withOpacity(0.08),
                          boxShadow: [
                            BoxShadow(
                              color: CustomColors.color28247C.withOpacity(0.04),
                              blurRadius: 20,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.chat_bubble_outline_rounded,
                          color: CustomColors.color28247C,
                          size: 48,
                        ),
                      ),
                      const SizedBox(height: 16),
                      RichText(
                        text: const TextSpan(
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: CustomColors.color28247C,
                          ),
                          children: [
                            TextSpan(text: 'Yody'),
                            TextSpan(
                              text: ' AI Template',
                              style: TextStyle(color: CustomColors.color1A202C),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      CustomText.regular(
                        'Một template AI Chat tự động hóa, cao cấp, sẵn sàng sử dụng.',
                        fontSize: 14,
                        color: CustomColors.color6B7280,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // Form section title
                CustomText.bold(
                  'Cấu hình Tích hợp',
                  fontSize: FontSizes.extraBig,
                  color: CustomColors.color28247C,
                ),
                const SizedBox(height: 16),

                // Card wrapping configurations
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: CustomColors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: CustomColors.color1A202C.withOpacity(0.03),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText.semiBold(
                        'WebSocket URL',
                        color: CustomColors.color1A202C,
                      ),
                      const SizedBox(height: 8),
                      CustomTextField(
                        controller: _wsController,
                        hintText: 'wss://your-websocket-url',
                        borderRadius: 12,
                        focusBorderColor: CustomColors.color28247C,
                      ),
                      const SizedBox(height: 16),

                      CustomText.semiBold(
                        'HTTP API Base URL',
                        color: CustomColors.color1A202C,
                      ),
                      const SizedBox(height: 8),
                      CustomTextField(
                        controller: _apiController,
                        hintText: 'https://your-api-url',
                        borderRadius: 12,
                        focusBorderColor: CustomColors.color28247C,
                      ),
                      const SizedBox(height: 16),

                      CustomText.semiBold(
                        'Auth Access Token (Optional)',
                        color: CustomColors.color1A202C,
                      ),
                      const SizedBox(height: 8),
                      CustomTextField(
                        controller: _tokenController,
                        hintText: 'JWT or Bearer Token String...',
                        borderRadius: 12,
                        focusBorderColor: CustomColors.color28247C,
                      ),
                      const SizedBox(height: 16),

                      CustomText.semiBold(
                        'Internal Signature Token',
                        color: CustomColors.color1A202C,
                      ),
                      const SizedBox(height: 8),
                      CustomTextField(
                        controller: _internalTokenController,
                        hintText: 'Internal header signature token...',
                        borderRadius: 12,
                        focusBorderColor: CustomColors.color28247C,
                      ),
                      const SizedBox(height: 20),

                      // Image Selection Toggle
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomText.semiBold(
                            'Cho phép đính kèm ảnh',
                            color: CustomColors.color1A202C,
                          ),
                          Switch.adaptive(
                            value: _showImageSection,
                            activeColor: CustomColors.color28247C,
                            onChanged: (val) {
                              setState(() {
                                _showImageSection = val;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Action Launch Button
                Center(
                  child: SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () => _launchTemplate(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CustomColors.color28247C,
                        foregroundColor: CustomColors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        shadowColor: CustomColors.color28247C.withOpacity(0.3),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.rocket_launch_rounded, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'KHỞI CHẠY AI CHAT',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
