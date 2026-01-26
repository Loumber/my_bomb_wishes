import 'package:flutter/material.dart';
import 'package:my_bomb_wishes/presentation/widgets/tile_button.dart';
import 'package:my_bomb_wishes/presentation/wishes/wish_form_sheet.dart';
import 'package:my_bomb_wishes/presentation/wishes/wishes_view_model.dart';

class MyProfileActions extends StatelessWidget {
  final WishesViewModel wishesViewModel;
  final String profileId;

  const MyProfileActions({super.key, required this.wishesViewModel, required this.profileId});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return IntrinsicHeight(
      child: StreamBuilder<WishFilter>(
        stream: wishesViewModel.filterStream,
        initialData: WishFilter.active,
        builder: (context, snapshot) {
          final currentFilter = snapshot.data ?? WishFilter.active;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _WishesCountTile(wishesViewModel: wishesViewModel, isActive: currentFilter == WishFilter.active),
              const SizedBox(width: 8),
              TileButton(
                icon: Icons.add,
                onTap:
                    () => showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      useSafeArea: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => WishFormSheet(userId: profileId),
                    ),
                width: 64,
                alignment: MainAxisAlignment.center,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  children: [
                    TileButton(
                      icon: Icons.check_rounded,
                      label: 'Исполнено',
                      width: double.infinity,
                      onTap: wishesViewModel.showFulfilledWishes,
                      backgroundColor:
                          currentFilter == WishFilter.fulfilled
                              ? colorScheme.primaryContainer
                              : colorScheme.secondaryContainer,
                      contentColor:
                          currentFilter == WishFilter.fulfilled
                              ? colorScheme.onPrimaryContainer
                              : colorScheme.onSecondaryContainer,
                    ),
                    const SizedBox(height: 8),
                    TileButton(
                      icon: Icons.card_giftcard_rounded,
                      label: 'Хочу подарить',
                      width: double.infinity,
                      onTap: wishesViewModel.showReservedWishes,
                      backgroundColor:
                          currentFilter == WishFilter.reserved
                              ? colorScheme.primaryContainer
                              : colorScheme.secondaryContainer,
                      contentColor:
                          currentFilter == WishFilter.reserved
                              ? colorScheme.onPrimaryContainer
                              : colorScheme.onSecondaryContainer,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _WishesCountTile extends StatelessWidget {
  final WishesViewModel wishesViewModel;
  final bool isActive;

  const _WishesCountTile({required this.wishesViewModel, required this.isActive});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return StreamBuilder<int>(
      stream: wishesViewModel.activeWishesCountStream,
      builder: (context, countSnapshot) {
        final countText = countSnapshot.hasData ? "${countSnapshot.data}" : "—";

        return TileButton(
          onTap: wishesViewModel.showActiveWishes,
          width: 100,
          height: 112,
          backgroundColor: isActive ? colorScheme.primaryContainer : colorScheme.secondaryContainer,
          contentColor: isActive ? colorScheme.onPrimaryContainer : colorScheme.onSecondaryContainer,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Мои\nжелания', style: TextStyle(fontWeight: FontWeight.bold, height: 1.1, fontSize: 13)),
              Text(countText, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            ],
          ),
        );
      },
    );
  }
}
