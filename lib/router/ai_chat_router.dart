import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../features/audio/controllers/speech_cubit.dart';
import '../features/home/ai_chat_home_page.dart';
import '../features/home/controllers/ai_chat_home_cubit.dart';

class AIChatRouter {
  AIChatRouter._();

  static AIChatRouter? _instance;

  static AIChatRouter get shareInstance {
    _instance ??= AIChatRouter._();
    return _instance!;
  }

  late final router = GoRoute(
    path: '/ai_chat',
    builder: (BuildContext context, GoRouterState state) {
      return MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AIChatHomeCubit(),
          ),
          BlocProvider(
            create: (context) => SpeechCubit(),
          ),
        ],
        child: const AIChatHomePage(),
      );
    },
    routes: const <RouteBase>[],
  );
}
