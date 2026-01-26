import 'dart:typed_data';
import 'package:my_bomb_wishes/common/logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:my_bomb_wishes/domain/entities/wish.dart';
import 'package:my_bomb_wishes/domain/repositories/wish_repository.dart';

class SupabaseWishRepository implements WishRepository {
  final SupabaseClient _client;
  SupabaseWishRepository(this._client);

  @override
  Future<void> addWish({
    required String title,
    String? description,
    String? link,
    double? price,
    Uint8List? imageBytes,
    String? imageName,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('User not authorized');

    String? uploadedImageUrl;

    if (imageBytes != null && imageName != null) {
      final fileExt = imageName.split('.').last;
      final fileName = '${user.id}/${DateTime.now().millisecondsSinceEpoch}.$fileExt';

      try {
        await _client.storage
            .from('wishes')
            .uploadBinary(fileName, imageBytes, fileOptions: FileOptions(contentType: 'image/$fileExt', upsert: true));

        uploadedImageUrl = _client.storage.from('wishes').getPublicUrl(fileName);
      } catch (e) {
        AppLogger.error('Error uploading image: $e');
        rethrow;
      }
    }
    await _client.from('wishes').insert({
      'user_id': user.id,
      'title': title,
      'description': description,
      'link': link,
      'price': price,
      'image_url': uploadedImageUrl,
      'is_fulfilled': false,
      'is_secret': false,
    });
  }

  @override
  Stream<List<Wish>> getReservedWishes(String myUserId) {
    return _client
        .from('wishes')
        .stream(primaryKey: ['id'])
        .eq('reserved_by', myUserId) // Фильтруем по нашей брони
        .order('created_at', ascending: false)
        .map((data) => data.map((json) => Wish.fromMap(json)).toList());
  }

  @override
  Future<void> copyWishToMyProfile({required Wish originalWish, required String myUserId}) async {
    try {
      await _client.from('wishes').insert({
        'user_id': myUserId,
        'title': originalWish.title,
        'description': originalWish.description,
        'image_url': originalWish.imageUrl,
        'link': originalWish.link, // Не забудьте ссылку, если она есть
        'price': originalWish.price,
        'is_fulfilled': false,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      AppLogger.error('Error copying wish: $e');
      rethrow;
    }
  }

  @override
  Stream<List<Wish>> getWishes(String userId) {
    return _client
        .from('wishes')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .map((data) => data.map((json) => Wish.fromMap(json)).toList());
  }

  @override
  Future<void> deleteWish(String wishId) async {
    await _client.from('wishes').delete().eq('id', wishId);
  }

  @override
  Future<void> toggleFulfillment(String wishId, bool isFulfilled) async {
    await _client.from('wishes').update({'is_fulfilled': isFulfilled}).eq('id', wishId);
  }

  @override
  Future<void> toggleReservation(String wishId, String? userId) async {
    await _client.from('wishes').update({'reserved_by': userId}).eq('id', wishId);
  }

  @override
  Future<void> updateWish({
    required String id,
    required String title,
    String? description,
    String? link,
    double? price,
    Uint8List? imageBytes,
    String? imageName,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('User not authorized');
    String? uploadedImageUrl;

    if (imageBytes != null && imageName != null) {
      final fileExt = imageName.split('.').last;
      final fileName = '${user.id}/${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      await _client.storage
          .from('wishes')
          .uploadBinary(fileName, imageBytes, fileOptions: FileOptions(contentType: 'image/$fileExt', upsert: true));

      uploadedImageUrl = _client.storage.from('wishes').getPublicUrl(fileName);
    }

    final Map<String, dynamic> updates = {
      'title': title,
      'description': description,
      'link': link,
      'price': price,
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (uploadedImageUrl != null) {
      updates['image_url'] = uploadedImageUrl;
    }

    await _client.from('wishes').update(updates).eq('id', id);
  }
}
