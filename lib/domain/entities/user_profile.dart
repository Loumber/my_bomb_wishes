class UserProfile {
  final String id;
  final String firstName;
  final String? username;
  final String photoUrl;

  UserProfile({
    required this.id,
    required this.firstName,
    this.username,
    required this.photoUrl,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] as String,
      firstName: map['first_name'] ?? map['display_name'] ?? 'Аноним', 
      username: map['username'] as String?,
      photoUrl: map['photo_url'] ?? map['avatar_url'] ?? '', 
    );
  }
}