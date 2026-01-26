import 'dart:async';
import 'package:my_bomb_wishes/common/di/di.dart';
import 'package:my_bomb_wishes/common/logger/logger.dart';
import 'package:my_bomb_wishes/domain/repositories/auth_repository.dart';
import 'package:my_bomb_wishes/domain/repositories/subscription_repository.dart';
import 'package:rxdart/rxdart.dart';

class ProfileViewModel {
  final SubscriptionRepository _subRepository = getIt<SubscriptionRepository>();
  final AuthRepository _authRepository = getIt<AuthRepository>();

  final String profileId;

  // --- SUBJECTS (ПОТОКИ) ---
  // Убрали .seeded(), теперь начальное значение null — это сигнал для UI показать шиммер
  final _isFollowingSubject = BehaviorSubject<bool?>();
  final _friendsCountSubject = BehaviorSubject<int?>();
  final _isLoadingSubject = BehaviorSubject<bool>.seeded(false);

  StreamSubscription? _followSubscription;
  StreamSubscription? _friendsCountSubscription;

  ProfileViewModel(this.profileId) {
    _initFollowStatusTracker();
    _initFriendsCounter();
  }

  // --- ЛОГИКА ПРАВ ДОСТУПА ---
  bool get isMyProfile {
    final currentId = _authRepository.currentUserId;
    return currentId == profileId;
  }

  // --- ИНИЦИАЛИЗАЦИЯ (REALTIME) ---
  void _initFollowStatusTracker() {
    final myId = _authRepository.currentUserId;

    // Если мой профиль, подписка не нужна, сразу ставим false (или null)
    if (myId == null || isMyProfile) {
      _isFollowingSubject.add(false);
      return;
    }

    _followSubscription = _subRepository
        .watchIsFollowing(followerId: myId, followingId: profileId)
        .listen(
          (isFollowing) => _isFollowingSubject.add(isFollowing),
          onError: (e) {
            AppLogger.error('Follow tracker error: $e');
            _isFollowingSubject.add(false); // В случае ошибки рисуем "не подписан"
          },
        );
  }

  void _initFriendsCounter() {
    _friendsCountSubscription = _subRepository
        .watchFriendsCount(profileId)
        .listen((count) => _friendsCountSubject.add(count), onError: (e) => _friendsCountSubject.add(0));
  }

  // --- ГЕТТЕРЫ ДЛЯ UI ---
  // Теперь возвращают nullable типы, чтобы UI мог проверить if (snapshot.data == null)
  Stream<bool?> get isFollowingStream => _isFollowingSubject.stream;
  Stream<int?> get friendsCountStream => _friendsCountSubject.stream;
  Stream<bool> get isLoadingStream => _isLoadingSubject.stream;

  // --- МЕТОДЫ ДЕЙСТВИЙ ---
  Future<void> toggleFollow() async {
    final myId = _authRepository.currentUserId;
    if (myId == null || isMyProfile) return;

    // Защита от null (если нажали слишком быстро, пока статус еще грузится)
    final currentStatus = _isFollowingSubject.value;
    if (currentStatus == null) return;

    _isLoadingSubject.add(true);

    try {
      if (currentStatus) {
        await _subRepository.unfollow(profileId);
      } else {
        await _subRepository.follow(profileId);
      }
    } catch (e) {
      AppLogger.error('Toggle follow failed: $e');
      rethrow;
    } finally {
      _isLoadingSubject.add(false);
    }
  }

  // --- ЗАКРЫТИЕ ---
  void dispose() {
    _followSubscription?.cancel();
    _friendsCountSubscription?.cancel();
    _isFollowingSubject.close();
    _friendsCountSubject.close();
    _isLoadingSubject.close();
  }
}
