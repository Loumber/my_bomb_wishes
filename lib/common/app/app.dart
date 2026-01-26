import 'package:flutter/material.dart';
import 'package:my_bomb_wishes/common/di/di.dart';
import 'package:my_bomb_wishes/domain/telegram/telegram_service.dart';
import 'package:my_bomb_wishes/presentation/common/my_custom_scroll_behavior.dart';
import 'package:my_bomb_wishes/presentation/pages/my_home_page.dart';
import 'package:telegram_web_app/telegram_web_app.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final telegramService = getIt<TelegramService>();
    final state = telegramService.state;

    return MaterialApp(
      scrollBehavior: MyCustomScrollBehavior(),
      theme:
          state.isSupported
              ? TelegramThemeUtil.getTheme(TelegramWebApp.instance)
              : ThemeData(
                useMaterial3: true,
                brightness: Brightness.light,
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
              ),
      home: const MyHomePage(),
    );
  }
}