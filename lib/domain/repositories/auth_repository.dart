abstract interface class AuthRepository {
  String? get currentUserId;

  Stream<bool> get authStateChanges;
  
  Future<Map<String, dynamic>> login(String initData);
  
  Stream<void> get onTokenExpired;
  
  Future<void> logout();
}