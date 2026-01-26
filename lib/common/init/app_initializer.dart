import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:my_bomb_wishes/common/di/di.dart';
import 'package:my_bomb_wishes/common/logger/logger.dart';
import 'package:my_bomb_wishes/domain/telegram/telegram_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppInitializer {
  static Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();

    await dotenv.load(fileName: ".env");

    try {
      await Supabase.initialize(url: dotenv.env['SUPABASE_URL']!, anonKey: dotenv.env['SUPABASE_ANON_KEY']!);
    } on Object {
      AppLogger.error('Supabase initialization failed');
    }

    setupDependencyInjection();

    _initTelegram();
  }

  static void _initTelegram() {
    final telegramService = getIt<TelegramService>();
    try {
      telegramService.ready();
      Future.delayed(const Duration(seconds: 1), telegramService.expand);
    } catch (e) {
      AppLogger.error('Telegram init error: $e');
    }
  }
}
