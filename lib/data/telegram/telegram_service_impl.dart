import 'package:flutter/material.dart';
import 'package:my_bomb_wishes/domain/telegram/models/telegram_state.dart';
import 'package:my_bomb_wishes/domain/telegram/telegram_service.dart';
import 'package:rxdart/rxdart.dart';
import 'package:telegram_web_app/telegram_web_app.dart';

class TelegramServiceImpl implements TelegramService {
  final TelegramWebApp _telegram;
  final BehaviorSubject<TelegramState> _stateSubject;

  TelegramServiceImpl(this._telegram)
    : _stateSubject = BehaviorSubject<TelegramState>.seeded(_createInitialState(_telegram)) {
    _setupListeners();
  }

  static TelegramState _createInitialState(TelegramWebApp telegram) {
    return TelegramState(
      isSupported: telegram.isSupported,
      initData: telegram.initData.raw,
      initDataUnsafe: telegram.initDataUnsafe,
      isVerticalSwipesEnabled: telegram.isVerticalSwipesEnabled,
      version: telegram.version,
      platform: telegram.platform,
      colorScheme: telegram.colorScheme,
      themeParams: telegram.themeParams,
      isActive: telegram.isActive,
      isExpanded: telegram.isExpanded,
      viewportHeight: telegram.viewportHeight ?? 0.0,
      viewportStableHeight: telegram.viewportStableHeight ?? 0.0,
      safeAreaInset: telegram.safeAreaInset,
      contentSafeAreaInset: telegram.contentSafeAreaInset,
      headerColor: telegram.headerColor ?? Colors.transparent,
      backgroundColor: telegram.backgroundColor ?? Colors.transparent,
      bottomBarColor: telegram.bottomBarColor ?? Colors.transparent,
    );
  }

  void _setupListeners() {
    // Слушаем изменения темы через периодическую проверку
    // TelegramWebApp не предоставляет прямых стримов для изменений
    // Можно использовать Timer для периодического обновления или
    // слушать события через JavaScript bridge если доступно
  }

  void _updateState() => _stateSubject.add(_createInitialState(_telegram));
  @override
  TelegramState get state => _stateSubject.value;

  @override
  Stream<TelegramState> get stateStream => _stateSubject.stream;

  @override
  Stream<void> get onThemeChanged => const Stream.empty();

  @override
  void ready() {
    _telegram.ready();
    _telegram.disableVerticalSwipes();
    _updateState();
  }

  @override
  void expand() {
    _telegram.expand();
    _updateState();
  }

  @override
  void enableVerticalSwipes() {
    _telegram.enableVerticalSwipes();
    _updateState();
  }

  @override
  void disableVerticalSwipes() {
    _telegram.disableVerticalSwipes();
    _updateState();
  }

  void dispose() {
    _stateSubject.close();
  }
}
