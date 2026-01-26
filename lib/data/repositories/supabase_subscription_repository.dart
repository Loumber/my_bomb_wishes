import 'package:my_bomb_wishes/common/logger/logger.dart';
import 'package:my_bomb_wishes/domain/entities/user_profile.dart';
import 'package:my_bomb_wishes/domain/repositories/subscription_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseSubscriptionRepository implements SubscriptionRepository {
  final SupabaseClient _client;
  SupabaseSubscriptionRepository(this._client);

  @override
  Stream<List<UserProfile>> getFollowing(String userId) {
    return _client
        .from('subscriptions')
        .stream(primaryKey: ['follower_id', 'following_id'])
        .eq('follower_id', userId)
        .asyncMap((data) async {
          final ids = data.map((e) => e['following_id'] as String).toList();
          return await _fetchProfiles(ids);
        });
  }

  // 1. Реализация получения подписчиков
  @override
  Stream<List<UserProfile>> getFollowers(String userId) {
    return _client
        .from('subscriptions')
        .stream(primaryKey: ['follower_id', 'following_id'])
        .eq('following_id', userId)
        .asyncMap((data) async {
          final ids = data.map((e) => e['follower_id'] as String).toList();
          return await _fetchProfiles(ids);
        });
  }

  // 2. Реализация проверки статуса подписки
  @override
  Future<bool> isFollowing(String targetUserId) async {
    final myId = _client.auth.currentUser?.id;
    if (myId == null) return false;

    final response =
        await _client.from('subscriptions').select().match({
          'follower_id': myId,
          'following_id': targetUserId,
        }).maybeSingle();

    return response != null;
  }

  @override
  Future<void> follow(String targetUserId) async {
    final myId = _client.auth.currentUser!.id;
    await _client.from('subscriptions').insert({'follower_id': myId, 'following_id': targetUserId});
  }

  @override
  Future<void> unfollow(String targetUserId) async {
    final myId = _client.auth.currentUser!.id;
    await _client.from('subscriptions').delete().match({'follower_id': myId, 'following_id': targetUserId});
  }

  Future<List<UserProfile>> _fetchProfiles(List<String> ids) async {
    if (ids.isEmpty) return [];

    try {
      final response = await _client.from('profiles').select().inFilter('id', ids);
      return (response as List).map((json) => UserProfile.fromMap(json)).toList();
    } catch (e) {
      AppLogger.error('Error fetching profiles: $e');
      return [];
    }
  }

  @override
  Future<List<UserProfile>> searchUsers(String query) async {
    if (query.trim().isEmpty) return [];

    try {
      final response = await _client
          .from('profiles')
          .select()
          .or('username.ilike.%$query%,first_name.ilike.%$query%')
          .limit(20);

      final List data = response as List;
      return data.map((json) => UserProfile.fromMap(json)).toList();
    } catch (e) {
      AppLogger.error('Error searching users: $e');
      return [];
    }
  }

  @override
  Stream<bool> watchIsFollowing({required String followerId, required String followingId}) {
    return _client
        .from('subscriptions')
        .stream(primaryKey: ['follower_id', 'following_id'])
        .map((data) {
          return data.any((row) => row['follower_id'] == followerId && row['following_id'] == followingId);
        });
  }

  @override
  Stream<int> watchFriendsCount(String userId) {
    return _client
        .from('subscriptions')
        .stream(primaryKey: ['follower_id', 'following_id'])
        .eq('following_id', userId)
        .asyncMap((_) async {
          final response = await _client
              .from('subscriptions')
              .select('follower_id')
              .eq('following_id', userId)
              .count(CountOption.exact);
          return response.count;
        });
  }
}
