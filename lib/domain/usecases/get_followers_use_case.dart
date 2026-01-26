import 'package:my_bomb_wishes/domain/entities/user_profile.dart';
import 'package:my_bomb_wishes/domain/repositories/subscription_repository.dart';

class GetFollowersUseCase {
  final SubscriptionRepository repository;
  GetFollowersUseCase(this.repository);

  Stream<List<UserProfile>> call(String userId) => repository.getFollowers(userId);
}

class GetFollowingUseCase {
  final SubscriptionRepository repository;
  GetFollowingUseCase(this.repository);

  Stream<List<UserProfile>> call(String userId) => repository.getFollowing(userId);
}