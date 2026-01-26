import 'package:flutter/material.dart';
import 'package:my_bomb_wishes/domain/entities/user_profile.dart';
import 'package:my_bomb_wishes/presentation/friends/friends_view_model.dart';
import 'package:my_bomb_wishes/presentation/friends/widgets/user_list_tile.dart';

class FriendsListStream extends StatelessWidget {
  final FriendsViewModel viewModel;

  const FriendsListStream({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return StreamBuilder<List<UserProfile>>(
      stream: viewModel.usersStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }

        final users = snapshot.data ?? [];

        if (users.isEmpty) {
          return Center(
            child: Text(
              'Пока никого нет',
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          );
        }

        return ListView.separated(
          itemCount: users.length,
          padding: const EdgeInsets.only(bottom: 24),
          // Оставляем физику для плавного скролла в Telegram Mini App
          physics: const AlwaysScrollableScrollPhysics(),
          separatorBuilder: (_, __) => Divider(
            color: colorScheme.outlineVariant.withOpacity(0.2),
            height: 1,
            indent: 72,
          ),
          itemBuilder: (context, index) => UserListTile(user: users[index]),
        );
      },
    );
  }
}