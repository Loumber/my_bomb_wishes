import 'package:my_bomb_wishes/domain/telegram/models/telegram_state.dart';

abstract interface class TelegramService {
  /// Текущее состояние Telegram
  TelegramState get state;
  
  /// Поток изменений состояния
  Stream<TelegramState> get stateStream;
  
  /// Поток изменений темы
  Stream<void> get onThemeChanged;

  /// Инициализация Telegram Web App
  void ready();
  
  /// Развернуть приложение на весь экран
  void expand();
  
  /// Включить вертикальные свайпы
  void enableVerticalSwipes();
  
  /// Отключить вертикальные свайпы
  void disableVerticalSwipes();

}
