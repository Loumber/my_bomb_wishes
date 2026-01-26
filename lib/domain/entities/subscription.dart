class Subscription {
  final String followerId;
  final String followingId;
  final DateTime createdAt;

  Subscription({
    required this.followerId,
    required this.followingId,
    required this.createdAt,
  });
}