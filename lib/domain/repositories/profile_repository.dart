import 'package:my_bomb_wishes/domain/entities/user_profile.dart';

abstract interface class ProfileRepository {
  Stream<UserProfile?> get profileStream;
  
  UserProfile? get currentProfile;

  void updateFromAuth(Map<String, dynamic> authData);

  Future<void> syncProfile();

  void dispose();
}