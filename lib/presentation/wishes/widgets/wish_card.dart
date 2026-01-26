import 'package:flutter/material.dart';
import 'package:my_bomb_wishes/domain/entities/wish.dart';
import 'package:my_bomb_wishes/presentation/wishes/wish_actions_sheet.dart';
import 'package:my_bomb_wishes/presentation/wishes/wish_detail_sheet.dart';
import 'package:my_bomb_wishes/presentation/wishes/wish_form_sheet.dart';
import 'package:my_bomb_wishes/presentation/wishes/wishes_view_model.dart';
import 'package:shimmer/shimmer.dart';

class WishCard extends StatelessWidget {
  final Wish wish;
  final WishesViewModel viewModel;

  const WishCard({super.key, required this.wish, required this.viewModel});
  LinearGradient _getRandomGradient(String id) {
    final List<List<Color>> gradientPairs = [
      [const Color(0xFFFF5F6D), const Color(0xFFFFC371)],
      [const Color(0xFF2193b0), const Color(0xFF6dd5ed)],
      [const Color(0xFFee0979), const Color(0xFFff6a00)],
      [const Color(0xFF11998e), const Color(0xFF38ef7d)],
      [const Color(0xFF8E2DE2), const Color(0xFF4A00E0)],
    ];

    final index = id.hashCode.abs() % gradientPairs.length;
    final colors = gradientPairs[index];

    return LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: colors);
  }

  @override
  Widget build(BuildContext context) {
    final myId = viewModel.currentUserId;
    final bool isMyProfile = viewModel.isMyProfile;

    final String? effectiveReservedBy = isMyProfile ? null : wish.reservedBy;

    final bool isReserved = effectiveReservedBy != null;
    final bool isReservedByMe = effectiveReservedBy == myId;
    final bool isReservedBySomeoneElse = isReserved && !isReservedByMe;

    final bool shouldShowLock = isReservedBySomeoneElse;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => WishDetailSheet(wish: wish),
                    );
                  },
                  child: _buildImageOrGradient(context),
                ),
              ),
              if (shouldShowLock)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                    child: Center(
                      child: Icon(Icons.lock_outline_rounded, color: Colors.white.withOpacity(0.9), size: 48),
                    ),
                  ),
                ),

              // Бейдж "Вы дарите" (только если забронировал я в чужом профиле)
              if (isReservedByMe)
                Positioned(
                  top: 0,
                  left: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: const BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.only(bottomRight: Radius.circular(12)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star, color: Colors.white, size: 14),
                        SizedBox(width: 4),
                        Text(
                          'Вы дарите',
                          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              Positioned(top: 8, right: 8, child: _buildMenuButton(context)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          wish.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildImageOrGradient(BuildContext context) {
    if (wish.imageUrl != null && wish.imageUrl!.isNotEmpty) {
      // Мы убрали Stack и "распорку" SizedBox(height: 200).
      // Теперь Image.network сам определит высоту виджета.
      return Image.network(
        wish.imageUrl!,
        width: double.infinity,
        // fitWidth растягивает картинку на всю ширину колонки,
        // а высота подбирается автоматически по пропорциям фото.
        fit: BoxFit.fitWidth,

        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;

          // Фиксированную высоту (200) оставляем ТОЛЬКО для момента загрузки,
          // чтобы интерфейс не "скакал" слишком сильно, пока грузится.
          return SizedBox(height: 200, width: double.infinity, child: _buildShimmerPlaceholder(context));
        },
        errorBuilder:
            (context, error, stackTrace) => Container(
              height: 150, // Для ошибки можно оставить фикс. высоту
              width: double.infinity,
              color: Theme.of(context).colorScheme.surfaceVariant,
              child: const Icon(Icons.broken_image, color: Colors.white24, size: 40),
            ),
      );
    } else {
      // Для градиента оставляем фиксированную высоту, так как там нет картинки
      return Container(
        height: 140,
        width: double.infinity,
        decoration: BoxDecoration(gradient: _getRandomGradient(wish.id)),
        child: Center(child: Icon(Icons.auto_awesome, color: Colors.white.withOpacity(0.5), size: 40)),
      );
    }
  }

  // Вспомогательный метод для шиммера (убедись, что он такой)
  Widget _buildShimmerPlaceholder(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade300,
      highlightColor: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade100,
      child: Container(width: double.infinity, height: double.infinity, color: Colors.white),
    );
  }

  Widget _buildMenuButton(BuildContext context) {
    final String? myId = viewModel.currentUserId;
    final bool isMyOwnWish = wish.userId == myId;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (isMyOwnWish) {
            WishActionsSheet.show(
              context: context,
              actions: [
                SheetAction(
                  label: 'Редактировать',
                  icon: Icons.edit_outlined,
                  onTap: () {
                    Navigator.pop(context);
                    _openEditForm(context);
                  },
                ),
                SheetAction(
                  label: wish.isFulfilled ? 'Вернуть в список' : 'Исполнено',
                  icon: wish.isFulfilled ? Icons.settings_backup_restore : Icons.check_circle_outline,
                  onTap: () {
                    Navigator.pop(context);
                    viewModel.toggleWishStatus(wish.id, !wish.isFulfilled);
                  },
                ),
                SheetAction(
                  label: 'Удалить',
                  icon: Icons.delete_outline,
                  isDestructive: true,
                  onTap: () {
                    Navigator.pop(context);
                    viewModel.deleteWish(wish.id);
                  },
                ),
              ],
            );
          } else {
            final String? reservedByStr = wish.reservedBy?.toString();
            final String? currentUserIdStr = myId?.toString();

            final bool isReservedByMe = reservedByStr != null && reservedByStr == currentUserIdStr;
            final bool isReservedBySomeoneElse = reservedByStr != null && !isReservedByMe;

            WishActionsSheet.show(
              context: context,
              title:
                  isReservedBySomeoneElse
                      ? 'Это желание уже забронировано другим человеком.'
                      : 'Владелец не узнает, кем забронировано желание.',
              actions: [
                SheetAction(
                  label: 'Сохранить к себе',
                  icon: Icons.copy_all_outlined,
                  onTap: () async {
                    try {
                      await viewModel.copyWish(wish);
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(const SnackBar(content: Text('Добавлено в ваши желания')));
                      }
                    } catch (e) {
                      if (context.mounted) Navigator.pop(context);
                    }
                  },
                ),
                if (isReservedByMe)
                  SheetAction(
                    label: 'Отменить бронь',
                    icon: Icons.bookmark_remove,
                    isDestructive: true,
                    onTap: () async {
                      await viewModel.toggleReservation(wish);
                      if (context.mounted) Navigator.pop(context);
                    },
                  )
                else if (!isReservedBySomeoneElse)
                  SheetAction(
                    label: 'Забронировать',
                    icon: Icons.card_giftcard_outlined,
                    onTap: () async {
                      await viewModel.toggleReservation(wish);
                      if (context.mounted) Navigator.pop(context);
                    },
                  ),
              ],
            );
          }
        },
        customBorder: const CircleBorder(),
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(color: Colors.black.withOpacity(0.2), shape: BoxShape.circle),
          child: const Icon(Icons.more_horiz_rounded, color: Colors.white, size: 20),
        ),
      ),
    );
  }

  void _openEditForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => WishFormSheet(userId: wish.userId, wish: wish),
    );
  }
}
