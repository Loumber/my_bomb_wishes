import 'package:my_bomb_wishes/common/logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rxdart/rxdart.dart';
import 'package:my_bomb_wishes/domain/repositories/auth_repository.dart';

class SupabaseAuthRepository implements AuthRepository {
  final SupabaseClient _client;
  final _authStatusController = BehaviorSubject<bool>.seeded(false);
  final _tokenExpiredController = PublishSubject<void>();

  SupabaseAuthRepository(this._client) {
    _authStatusController.add(_client.auth.currentSession != null);

    _client.auth.onAuthStateChange.listen((data) {
      final bool isLogged = data.session != null;
      if (_authStatusController.value != isLogged) {
        _authStatusController.add(isLogged);
      }
    });
  }

  @override
  Stream<bool> get authStateChanges => _authStatusController.stream;

  @override
  Stream<void> get onTokenExpired => _tokenExpiredController.stream;

  @override
  Future<Map<String, dynamic>> login(String initData) async {
    try {
      final response = await _client.functions.invoke('telegram-auth', body: {'initData': initData});

      final data = response.data as Map<String, dynamic>;

      // Извлекаем токены из ответа Edge Function
      final String? accessToken = data['access_token'];
      final String? refreshToken = data['refresh_token'];

      if (accessToken == null || refreshToken == null) {
        throw Exception("Tokens are missing in server response");
      }

      // Устанавливаем сессию в клиенте Supabase
      await _client.auth.setSession(refreshToken);

      AppLogger.info("Вход выполнен успешно!");

      // Возвращаем данные (включая объект 'user' для ProfileRepository)
      return data;
    } catch (e) {
      AppLogger.error("Ошибка логина: $e");
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    await _client.auth.signOut();
  }

  Future<T> secureRequest<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST301' || e.code == '401' || e.message.contains('JWT')) {
        _tokenExpiredController.add(null);
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  void dispose() {
    _authStatusController.close();
    _tokenExpiredController.close();
  }
  
  @override
  String? get currentUserId => _client.auth.currentUser?.id;
}
