import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:my_bomb_wishes/common/di/di.dart';
import 'package:my_bomb_wishes/common/logger/logger.dart';
import 'package:my_bomb_wishes/domain/entities/wish.dart';
import 'package:my_bomb_wishes/domain/repositories/auth_repository.dart';
import 'package:my_bomb_wishes/domain/repositories/wish_repository.dart';
import 'package:my_bomb_wishes/domain/usecases/add_wish_usecase.dart';
import 'package:my_bomb_wishes/domain/usecases/delete_wish_use_case.dart';
import 'package:my_bomb_wishes/domain/usecases/update_wish_use_case.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:typed_data';

enum WishFilter { active, fulfilled, reserved }

class WishesViewModel {
  final WishRepository _wishRepository = getIt<WishRepository>();
  final AuthRepository _authRepository = getIt<AuthRepository>();
  final String userId;

  // Use Cases
  final AddWishUseCase _addWishUseCase = getIt<AddWishUseCase>();
  final DeleteWishUseCase _deleteWishUseCase = getIt<DeleteWishUseCase>();
  final UpdateWishUseCase _updateWishUseCase = getIt<UpdateWishUseCase>();

  // Subjects (Стримы)
  final _showFulfilledSubject = BehaviorSubject<bool>.seeded(false);
  final _activeCountSubject = BehaviorSubject<int>();

  final _filterSubject = BehaviorSubject<WishFilter>.seeded(WishFilter.active);
  Stream<WishFilter> get filterStream => _filterSubject.stream;

  void showReservedWishes() => _filterSubject.add(WishFilter.reserved);
  void showActiveWishes() => _filterSubject.add(WishFilter.active);
  void showFulfilledWishes() => _filterSubject.add(WishFilter.fulfilled);

  // Подписки
  StreamSubscription? _activeCounterSubscription;

  WishesViewModel(this.userId) {
    _initActiveCounter();
  }

  String? get currentUserId => _authRepository.currentUserId;

  Future<void> toggleReservation(Wish wish) async {
    final myId = _authRepository.currentUserId;
    if (myId == null) return;
    if (wish.reservedBy != null && wish.reservedBy != myId) return;
    try {
      final String? newStatus = wish.reservedBy == myId ? null : myId;
      await _wishRepository.toggleReservation(wish.id, newStatus);
    } catch (e) {
      AppLogger.error('Ошибка бронирования: $e');
    }
  }

  // Стрим желаний, которые забронировал текущий пользователь
  Stream<List<Wish>> get reservedWishesStream {
    final myId = _authRepository.currentUserId;
    if (myId == null) return Stream.value([]);

    return _wishRepository.getReservedWishes(myId);
  }

  // --- ЛОГИКА ПРАВ ДОСТУПА ---

  bool get isMyProfile {
    final currentId = _authRepository.currentUserId;
    return currentId == userId;
  }

  void _initActiveCounter() {
    _activeCounterSubscription?.cancel();
    _activeCounterSubscription = _wishRepository
        .getWishes(userId)
        .map((wishes) => wishes.where((w) => !w.isFulfilled).length)
        .listen(
          (count) => _activeCountSubject.add(count),
          onError: (e) {
            AppLogger.error('Counter error: $e. Reconnecting in 5s...');
            Future.delayed(const Duration(seconds: 5), () {
              _initActiveCounter();
            });
          },
          cancelOnError: true,
        );
  }

  Stream<bool> get isFulfilledFilterStream => _showFulfilledSubject.stream;

  ValueStream<int> get activeWishesCountStream => _activeCountSubject.stream;

  Stream<List<Wish>> get filteredWishesStream => Rx.combineLatest3(
    _wishRepository.getWishes(userId),
    _wishRepository.getReservedWishes(_authRepository.currentUserId ?? ''),
    _filterSubject.stream,
    (List<Wish> userWishes, List<Wish> myReserved, WishFilter filter) {
      switch (filter) {
        case WishFilter.active:
          return userWishes.where((w) => !w.isFulfilled).toList();
        case WishFilter.fulfilled:
          return userWishes.where((w) => w.isFulfilled).toList();
        case WishFilter.reserved:
          return myReserved;
      }
    },
  );

  Future<void> createWish({
    required String title,
    String? description,
    String? link,
    double? price,
    Uint8List? imageBytes,
    String? imageName,
  }) async {
    await _addWishUseCase(
      title: title,
      description: description,
      link: link,
      price: price,
      imageBytes: imageBytes,
      imageName: imageName,
    );
  }

  Future<void> updateWish({
    required String id,
    required String title,
    String? description,
    String? link,
    double? price,
    Uint8List? imageBytes,
    String? imageName,
  }) async {
    try {
      await _updateWishUseCase(
        id: id,
        title: title,
        description: description,
        link: link,
        price: price,
        imageBytes: imageBytes,
        imageName: imageName,
      );
    } catch (e) {
      AppLogger.error('Ошибка при обновлении желания: $e');
      rethrow;
    }
  }

  Future<void> deleteWish(String wishId) async {
    try {
      await _deleteWishUseCase(wishId);
    } catch (e) {
      AppLogger.error('Ошибка при удалении желания: $e');
    }
  }

  Future<void> toggleWishStatus(String wishId, bool isFulfilled) async {
    await _wishRepository.toggleFulfillment(wishId, isFulfilled);
  }

  Future<void> copyWish(Wish wish) async {
    final myId = _authRepository.currentUserId;
    if (myId == null) return;

    try {
      await _wishRepository.copyWishToMyProfile(originalWish: wish, myUserId: myId);
    } catch (e) {
      AppLogger.error('Failed to copy wish in ViewModel: $e');
      rethrow;
    }
  }

  void dispose() {
    _activeCounterSubscription?.cancel();
    _showFulfilledSubject.close();
    _activeCountSubject.close();
  }
}
