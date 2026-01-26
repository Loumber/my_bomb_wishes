import 'package:my_bomb_wishes/domain/entities/user_profile.dart';
import 'package:my_bomb_wishes/domain/usecases/get_followers_use_case.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:async';

enum FriendsTab { following, followers }

class FriendsViewModel {
  final GetFollowersUseCase _getFollowersUseCase;
  final GetFollowingUseCase _getFollowingUseCase;
  final String myId;
  final String userId;

  final _tabSubject = BehaviorSubject<FriendsTab>.seeded(FriendsTab.following);

  FriendsViewModel({
    required GetFollowersUseCase getFollowersUseCase,
    required GetFollowingUseCase getFollowingUseCase,
    required this.userId,
    required this.myId,
  })  : _getFollowersUseCase = getFollowersUseCase,
        _getFollowingUseCase = getFollowingUseCase;

  Stream<List<UserProfile>> get usersStream => _tabSubject.switchMap((tab) {
        if (tab == FriendsTab.following) {
          return _getFollowingUseCase(userId);
        } else {
          return _getFollowersUseCase(userId);
        }
      });

  Stream<FriendsTab> get currentTabStream => _tabSubject.stream;

  void setTab(FriendsTab tab) {
    if (_tabSubject.value == tab) return;
    _tabSubject.add(tab);
  }

  bool get isMyProfile => userId == myId;

  void dispose() {
    _tabSubject.close();
  }
}