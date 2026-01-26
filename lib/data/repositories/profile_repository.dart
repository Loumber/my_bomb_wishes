// data/repositories/profile_repository_impl.dart
import 'package:my_bomb_wishes/common/logger/logger.dart';
import 'package:rxdart/rxdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final SupabaseClient _supabase;
  
  final _profileSubject = BehaviorSubject<UserProfile?>();

  ProfileRepositoryImpl(this._supabase);

  @override
  Stream<UserProfile?> get profileStream => _profileSubject.stream;

  @override
  UserProfile? get currentProfile => _profileSubject.valueOrNull;

  @override
  void updateFromAuth(Map<String, dynamic> authData) {
    final user = authData['user'];
    if (user != null) {
      final profile = UserProfile(
        id: user['id'],
        firstName: user['user_metadata']?['first_name'] ?? 'User',
        username: user['user_metadata']?['username'],
        photoUrl: user['user_metadata']?['photo_url'] ?? '',
      );
      _profileSubject.add(profile);
    }
  }

  @override
  Future<void> syncProfile() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final data = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      final profile = UserProfile(
        id: data['id'],
        firstName: data['first_name'],
        username: data['username'],
        photoUrl: data['photo_url'] ?? '',
      );

      _profileSubject.add(profile);
    } catch (e) {
      AppLogger.error('SyncProfile Error: $e');
    }
  }

  @override
  void dispose() {
    _profileSubject.close();
  }
}