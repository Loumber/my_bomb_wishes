import 'dart:typed_data';
import 'package:my_bomb_wishes/domain/repositories/wish_repository.dart';

class AddWishUseCase {
  final WishRepository _repository;

  AddWishUseCase(this._repository);

  Future<void> call({
    required String title,
    String? description,
    String? link,
    double? price,
    Uint8List? imageBytes,
    String? imageName,
  }) async {
    if (title.trim().isEmpty) throw Exception('Title cannot be empty');
    
    return await _repository.addWish(
      title: title,
      description: description,
      link: link,
      price: price,
      imageBytes: imageBytes,
      imageName: imageName,
    );
  }
}