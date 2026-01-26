import 'package:my_bomb_wishes/domain/entities/user_profile.dart';

abstract class SubscriptionRepository {
  // Получить список тех, на кого я подписан
  Stream<List<UserProfile>> getFollowing(String userId);
  
  // Получить список моих подписчиков
  Stream<List<UserProfile>> getFollowers(String userId);

  // Подписаться / Отписаться
  Future<void> follow(String targetUserId);
  Future<void> unfollow(String targetUserId);

  // Проверить статус (подписан ли я?)
  Future<bool> isFollowing(String targetUserId);

  Future<List<UserProfile>> searchUsers(String query);

  Stream<bool> watchIsFollowing({required String followerId, required String followingId});
  Stream<int> watchFriendsCount(String userId);
}