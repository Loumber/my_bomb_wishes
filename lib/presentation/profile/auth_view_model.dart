import 'dart:async';
import 'package:my_bomb_wishes/common/logger/logger.dart';
import 'package:my_bomb_wishes/presentation/profile/profile_state.dart';
import 'package:rxdart/rxdart.dart';
import 'package:my_bomb_wishes/domain/repositories/auth_repository.dart';
import 'package:my_bomb_wishes/domain/repositories/profile_repository.dart';
import 'package:my_bomb_wishes/domain/entities/user_profile.dart';
import 'package:my_bomb_wishes/domain/telegram/telegram_service.dart';

class AuthViewModel {
  final AuthRepository _authRepository;
  final TelegramService _telegramService;
  final ProfileRepository _profileRepository;

  final _isLoading = BehaviorSubject<bool>.seeded(false);
  final _errorSubject = BehaviorSubject<String?>.seeded(null);
  final _compositeSubscription = CompositeSubscription();

  AuthViewModel(this._authRepository, this._telegramService, this._profileRepository) {
    _authRepository.onTokenExpired.listen((_) => signIn()).addTo(_compositeSubscription);
  }

  Stream<AuthPageState> get pageState => Rx.combineLatest4<bool, String?, bool, UserProfile?, AuthPageState>(
    _isLoading.stream,
    _errorSubject.stream,
    _authRepository.authStateChanges,
    _profileRepository.profileStream,
    (loading, error, authorized, profile) =>
        AuthPageState(isLoading: loading, error: error, isAuthorized: authorized, profile: profile),
  );

  Future<void> signIn() async {
    if (_isLoading.value) return;

    try {
      _isLoading.add(true);
      _errorSubject.add(null);

      final initData = _telegramService.state.initData;

      if (initData != null) {
        // 1. Авторизация в Supabase через Edge Function
        final authData = await _authRepository.login(initData);

        // 2. Первичная инициализация профиля (из метаданных ответа)
        _profileRepository.updateFromAuth(authData);

        // 3. Синхронизация с БД для получения актуального фото из Storage
        await _profileRepository.syncProfile();

        AppLogger.info("Авторизация и синхронизация профиля успешны");
      } else {
        _errorSubject.add("Telegram initData is missing");
      }
    } catch (e) {
      _errorSubject.add(e.toString());
      AppLogger.error("Ошибка при входе: $e");
    } finally {
      _isLoading.add(false);
    }
  }

  /// Очистка ресурсов
  void dispose() {
    _compositeSubscription.dispose();
    _isLoading.close();
    _errorSubject.close();
  }
}
