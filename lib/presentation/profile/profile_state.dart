import 'package:my_bomb_wishes/domain/entities/user_profile.dart';

class AuthPageState {
  final bool isLoading;
  final String? error;
  final bool isAuthorized;
  final UserProfile? profile;

  const AuthPageState({
    this.isLoading = false,
    this.error,
    this.isAuthorized = false,
    this.profile,
  });
}