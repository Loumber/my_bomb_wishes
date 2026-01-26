import 'package:flutter/material.dart';
import 'package:my_bomb_wishes/domain/telegram/models/telegram_state.dart';
import 'package:my_bomb_wishes/domain/telegram/telegram_service.dart';
import 'package:rxdart/rxdart.dart';
import 'package:telegram_web_app/telegram_web_app.dart';

class TelegramServiceFake implements TelegramService {
  final BehaviorSubject<TelegramState> _stateSubject;
  bool _isVerticalSwipesEnabled = false;
  bool _isExpanded = false;

  TelegramServiceFake() : _stateSubject = BehaviorSubject<TelegramState>.seeded(_createDefaultState());

  static TelegramState _createDefaultState() {
    final fakeThemeParams = ThemeParams(); 

    return TelegramState(
      isSupported: false,
      initData: 'fake_init_data_for_testing', 
      initDataUnsafe: null,
      isVerticalSwipesEnabled: false,
      version: 'Fake 1.0.0',
      platform: 'web',
      colorScheme: TelegramColorScheme.light,
      themeParams: fakeThemeParams,
      isActive: true,
      isExpanded: false,
      viewportHeight: 800.0,
      viewportStableHeight: 800.0,
      safeAreaInset: null,
      contentSafeAreaInset: null,
      headerColor: const Color(0xFFFFFFFF),
      backgroundColor: const Color(0xFFF0F0F0),
      bottomBarColor: const Color(0xFFFFFFFF),
    );
  }

  void _updateState() {
    final currentState = _stateSubject.value;
    _stateSubject.add(
      currentState.copyWith(isVerticalSwipesEnabled: _isVerticalSwipesEnabled, isExpanded: _isExpanded),
    );
  }

  @override
  TelegramState get state => _stateSubject.value;

  @override
  Stream<TelegramState> get stateStream => _stateSubject.stream;

  @override
  Stream<void> get onThemeChanged => const Stream.empty();

  @override
  void ready() {
    Future.delayed(const Duration(milliseconds: 100), () {
      _updateState();
    });
  }

  @override
  void expand() {
    _isExpanded = true;
    _updateState();
  }

  @override
  void enableVerticalSwipes() {
    _isVerticalSwipesEnabled = true;
    _updateState();
  }

  @override
  void disableVerticalSwipes() {
    _isVerticalSwipesEnabled = false;
    _updateState();
  }

  void dispose() {
    _stateSubject.close();
  }
}
