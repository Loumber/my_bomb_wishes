import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:my_bomb_wishes/domain/entities/wish.dart';
import 'package:my_bomb_wishes/presentation/wishes/widgets/wish_card.dart';
import 'package:my_bomb_wishes/presentation/wishes/wishes_view_model.dart';

class WishesGrid extends StatelessWidget {
  final WishesViewModel viewModel;
  const WishesGrid({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return StreamBuilder<List<Wish>>(
      stream: viewModel.filteredWishesStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 60.0),
              child: Center(child: CircularProgressIndicator.adaptive()),
            ),
          );
        }
        if (snapshot.hasError) {
          return SliverToBoxAdapter(child: Center(child: Text('Ошибка загрузки: ${snapshot.error}')));
        }

        final wishes = snapshot.data ?? [];

        if (wishes.isEmpty) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 80.0),
              child: StreamBuilder<bool>(
                stream: viewModel.isFulfilledFilterStream,
                builder: (context, filterSnap) {
                  final isFulfilled = filterSnap.data ?? false;
                  return Center(
                    child: Column(
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 48, color: colorScheme.outline),
                        const SizedBox(height: 16),
                        Text(
                          isFulfilled ? 'Подарков пока нет' : 'Список желаний пуст',
                          style: TextStyle(color: colorScheme.outline, fontSize: 16),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverMasonryGrid.count(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            itemBuilder: (context, index) {
              return WishCard(wish: wishes[index], viewModel: viewModel);
            },
            childCount: wishes.length,
          ),
        );
      },
    );
  }
}
