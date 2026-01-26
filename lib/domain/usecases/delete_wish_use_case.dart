import 'package:my_bomb_wishes/domain/repositories/wish_repository.dart';

class DeleteWishUseCase {
  final WishRepository _repository;
  DeleteWishUseCase(this._repository);

  Future<void> call(String wishId) async => await _repository.deleteWish(wishId);
}