import 'dart:typed_data';
import '../repositories/wish_repository.dart';

class UpdateWishUseCase {
  final WishRepository _repository;

  UpdateWishUseCase(this._repository);

  Future<void> call({
    required String id,
    required String title,
    String? description,
    String? link,
    double? price,
    Uint8List? imageBytes,
    String? imageName,
  }) async {
    return await _repository.updateWish(
      id: id,
      title: title,
      description: description,
      link: link,
      price: price,
      imageBytes: imageBytes,
      imageName: imageName,
    );
  }
}  