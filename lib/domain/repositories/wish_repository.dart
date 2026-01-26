import 'package:my_bomb_wishes/domain/entities/wish.dart';
import 'dart:typed_data';

abstract interface class WishRepository {
  Future<void> addWish({
    required String title,
    String? description,
    String? link,
    double? price,
    Uint8List? imageBytes,
    String? imageName,
  });

  Stream<List<Wish>> getWishes(String userId);
  Future<void> deleteWish(String wishId);
  Future<void> toggleFulfillment(String wishId, bool isFulfilled);
  Future<void> toggleReservation(String wishId, String? userId);
  Future<void> copyWishToMyProfile({required Wish originalWish, required String myUserId});
  Stream<List<Wish>> getReservedWishes(String myUserId);

  Future<void> updateWish({
    required String id,
    required String title,
    String? description,
    String? link,
    double? price,
    Uint8List? imageBytes,
    String? imageName,
  });
}
