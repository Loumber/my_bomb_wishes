import 'dart:async';
import 'package:my_bomb_wishes/domain/entities/user_profile.dart';
import 'package:my_bomb_wishes/domain/repositories/subscription_repository.dart';
import 'package:rxdart/rxdart.dart'; // Если используете rxdart для debounce

class FriendsSearchViewModel {
  final SubscriptionRepository _repository;

  final _searchQueryController = BehaviorSubject<String>.seeded("");
  
  late final Stream<List<UserProfile>> searchResultsStream;

  FriendsSearchViewModel(this._repository) {
    searchResultsStream = _searchQueryController
        .debounceTime(const Duration(milliseconds: 500))
        .distinct()
        .switchMap((query) {
          if (query.isEmpty) return Stream.value([]);
          return Stream.fromFuture(_repository.searchUsers(query));
        });
  }

  void onSearchChanged(String query) {
    _searchQueryController.add(query);
  }

  void dispose() {
    _searchQueryController.close();
  }
}