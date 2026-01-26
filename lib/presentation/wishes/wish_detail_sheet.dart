import 'package:flutter/material.dart';
import 'package:my_bomb_wishes/common/di/di.dart';
import 'package:my_bomb_wishes/domain/entities/wish.dart';
import 'package:my_bomb_wishes/presentation/wishes/wish_actions_sheet.dart';
import 'package:my_bomb_wishes/presentation/wishes/wishes_view_model.dart';
import 'package:url_launcher/url_launcher.dart';

class WishDetailSheet extends StatelessWidget {
  final Wish wish;

  const WishDetailSheet({super.key, required this.wish});

  Future<void> _launchURL(BuildContext context, String urlString) async {
    String processedUrl = urlString.trim();
    if (!processedUrl.startsWith('http://') && !processedUrl.startsWith('https://')) {
      processedUrl = 'https://$processedUrl';
    }

    final Uri url = Uri.parse(processedUrl);

    try {
      final bool launched = await launchUrl(url, mode: LaunchMode.externalApplication);
      if (!launched) throw 'Не удалось открыть ссылку';
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка открытия: $processedUrl'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final viewModel = getIt<WishesViewModel>(param1: wish.userId);

    // ПРИМЕНЯЕМ ЛОГИКУ ПО АВТОРУ:
    final String? myId = viewModel.currentUserId;
    final bool isMyOwnWish = wish.userId.toString() == myId?.toString();

    return Container(
      constraints: const BoxConstraints(maxWidth: 600),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: colorScheme.onSurfaceVariant.withOpacity(0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (wish.imageUrl != null && wish.imageUrl!.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        wish.imageUrl!,
                        width: double.infinity,
                        fit: BoxFit.contain,
                        alignment: Alignment.center,
                        errorBuilder:
                            (_, __, ___) => Container(
                              height: 200,
                              color: colorScheme.surfaceVariant,
                              child: const Icon(Icons.broken_image, size: 50),
                            ),
                      ),
                    ),
                  const SizedBox(height: 20),
                  Text(wish.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  if (wish.price != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      '${wish.price!.toStringAsFixed(0)} ₽',
                      style: TextStyle(fontSize: 20, color: colorScheme.primary, fontWeight: FontWeight.w600),
                    ),
                  ],
                  if (wish.description != null && wish.description!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(wish.description!, style: TextStyle(fontSize: 16, color: colorScheme.onSurfaceVariant)),
                  ],
                  const SizedBox(height: 32),
                  if (wish.link != null && wish.link!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildActionButton(
                        context,
                        icon: Icons.shopping_cart_outlined,
                        label: 'Где купить',
                        onPressed: () => _launchURL(context, wish.link!),
                        isPrimary: true,
                      ),
                    ),
                  IntrinsicHeight(
                    child: Row(
                      children: [
                        Expanded(
                          child:
                              isMyOwnWish
                                  ? _buildActionButton(
                                    context,
                                    icon: wish.isFulfilled ? Icons.settings_backup_restore : Icons.check_circle,
                                    label: wish.isFulfilled ? 'В список' : 'Исполнено',
                                    onPressed: () async {
                                      await viewModel.toggleWishStatus(wish.id, !wish.isFulfilled);
                                      if (context.mounted) Navigator.pop(context);
                                    },
                                    isPrimary: false,
                                  )
                                  : Builder(
                                    builder: (context) {
                                      final bool isReservedByMe = wish.reservedBy?.toString() == myId?.toString();
                                      final bool isReservedBySomeoneElse = wish.reservedBy != null && !isReservedByMe;

                                      if (isReservedBySomeoneElse) {
                                        return _buildActionButton(
                                          context,
                                          icon: Icons.lock_clock_outlined,
                                          label: 'Забронировано',
                                          onPressed: null,
                                          isPrimary: false,
                                        );
                                      }
                                      return _buildActionButton(
                                        context,
                                        icon: isReservedByMe ? Icons.bookmark_remove : Icons.bookmark_add_outlined,
                                        label: isReservedByMe ? 'Отменить бронь' : 'Забронировать',
                                        onPressed: () async {
                                          try {
                                            await viewModel.toggleReservation(wish);
                                            if (context.mounted) Navigator.pop(context);
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    isReservedByMe
                                                        ? 'Бронирование отменено'
                                                        : 'Вы забронировали подарок',
                                                  ),
                                                  behavior: SnackBarBehavior.floating,
                                                ),
                                              );
                                            }
                                          } catch (e) {
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text('Ошибка обновления статуса')),
                                              );
                                            }
                                          }
                                        },
                                        isPrimary: isReservedByMe, // Синяя кнопка, если уже забронировано
                                      );
                                    },
                                  ),
                        ),
                        const SizedBox(width: 12),
                        // Передаем isMyOwnWish вместо isMyProfile
                        _buildMoreButton(context, viewModel, isMyOwnWish),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    required bool isPrimary,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return FilledButton.icon(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        minimumSize: const Size(double.infinity, 56),
        backgroundColor: isPrimary ? colorScheme.primary : colorScheme.surfaceVariant,
        foregroundColor: isPrimary ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      icon: Icon(icon),
      label: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
    );
  }

  // ... (остальной код класса без изменений)

  Widget _buildMoreButton(BuildContext context, WishesViewModel viewModel, bool isMyOwnWish) {
    // Добавляем расчеты здесь для меню
    final String? myId = viewModel.currentUserId;
    final bool isReservedByMe = wish.reservedBy?.toString() == myId?.toString();

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
      ),
      child: IconButton(
        padding: const EdgeInsets.all(16),
        onPressed: () {
          if (isMyOwnWish) {
            // --- МЕНЮ ДЛЯ СОБСТВЕННОГО ЖЕЛАНИЯ ---
            WishActionsSheet.show(
              context: context,
              actions: [
                SheetAction(
                  label: 'Редактировать',
                  icon: Icons.edit_outlined,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                    // _openEditForm(context); // Вызовите ваш метод здесь
                  },
                ),
                SheetAction(
                  label: 'Удалить',
                  icon: Icons.delete_outline,
                  isDestructive: true,
                  onTap: () {
                    viewModel.deleteWish(wish.id);
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          } else {
            // --- МЕНЮ ДЛЯ ЧУЖОГО ЖЕЛАНИЯ ---
            WishActionsSheet.show(
              context: context,
              title: 'Владелец не узнает, кем забронировано желание.',
              actions: [
                // 1. Сохранить к себе
                SheetAction(
                  label: 'Сохранить к себе',
                  icon: Icons.copy_all_outlined,
                  onTap: () async {
                    await viewModel.copyWish(wish);
                    if (context.mounted) Navigator.pop(context);
                  },
                ),
                if (isReservedByMe)
                  SheetAction(
                    label: 'Отменить бронь',
                    icon: Icons.bookmark_remove,
                    isDestructive: true,
                    onTap: () async {
                      await viewModel.toggleReservation(wish);
                      if (context.mounted) {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      }
                    },
                  ),
              ],
            );
          }
        },
        icon: const Icon(Icons.more_horiz_rounded),
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}
