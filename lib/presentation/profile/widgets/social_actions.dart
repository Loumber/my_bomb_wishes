import 'package:flutter/material.dart';
import 'package:my_bomb_wishes/presentation/friends/friends_page.dart';
import 'package:my_bomb_wishes/presentation/profile/profile_view_model.dart';
import 'package:shimmer/shimmer.dart';

class SocialActions extends StatelessWidget {
  final ProfileViewModel viewModel;

  const SocialActions({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Изменили тип на <bool?>
        StreamBuilder<bool?>(
          stream: viewModel.isFollowingStream,
          builder: (context, followSnapshot) {
            // Если данных нет (null) или ждем подключения — шиммер
            if (followSnapshot.connectionState == ConnectionState.waiting || !followSnapshot.hasData) {
              return _buildShimmerCircle();
            }

            final isFollowing = followSnapshot.data ?? false;

            return StreamBuilder<bool>(
              stream: viewModel.isLoadingStream,
              initialData: false,
              builder: (context, loadingSnapshot) {
                final isLoading = loadingSnapshot.data ?? false;
                final colorScheme = Theme.of(context).colorScheme;

                return _CircleActionButton(
                  icon: isFollowing ? Icons.check : Icons.add,
                  onTap: isLoading ? () {} : () => viewModel.toggleFollow(),
                  isLoading: isLoading,
                  backgroundColor: isFollowing ? colorScheme.secondaryContainer : colorScheme.primary,
                  iconColor: isFollowing ? colorScheme.onSecondaryContainer : colorScheme.onPrimary,
                );
              },
            );
          },
        ),
        const SizedBox(width: 12),
        _FriendsCounter(viewModel: viewModel),
      ],
    );
  }

  Widget _buildShimmerCircle() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.withOpacity(0.1),
      highlightColor: Colors.grey.withOpacity(0.05),
      child: Container(
        width: 48,
        height: 48,
        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
      ),
    );
  }
}

class _CircleActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color backgroundColor;
  final Color iconColor;
  final bool isLoading;
  const _CircleActionButton({
    required this.icon,
    required this.onTap,
    required this.backgroundColor,
    required this.iconColor,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 48,
        height: 48,
        decoration: BoxDecoration(color: backgroundColor, shape: BoxShape.circle),
        child: Center(
          child:
              isLoading
                  ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: iconColor))
                  : Icon(icon, color: iconColor, size: 22),
        ),
      ),
    );
  }
}

class _FriendsCounter extends StatelessWidget {
  final ProfileViewModel viewModel;
  const _FriendsCounter({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return StreamBuilder<int?>(
      stream: viewModel.friendsCountStream,
      builder: (context, snapshot) {
        // Показываем шиммер, если соединение только устанавливается
        // или если данные еще не пришли (равны null)
        if (snapshot.connectionState == ConnectionState.waiting || !snapshot.hasData) {
          return _buildShimmerBadge();
        }

        // К этому моменту мы уверены, что count не null (благодаря hasData)
        final count = snapshot.data ?? 0;

        return GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => FriendsPage(userId: viewModel.profileId)));
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(color: colorScheme.secondaryContainer, borderRadius: BorderRadius.circular(25)),
            child: Text(
              '$count ${_getFriendNoun(count)}',
              style: TextStyle(color: colorScheme.onSecondaryContainer, fontWeight: FontWeight.w600),
            ),
          ),
        );
      },
    );
  }

  Widget _buildShimmerBadge() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.withOpacity(0.1),
      highlightColor: Colors.grey.withOpacity(0.05),
      child: Container(
        width: 100,
        height: 44,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25)),
      ),
    );
  }

  String _getFriendNoun(int count) {
    if (count % 10 == 1 && count % 100 != 11) return 'друг';
    if (count % 10 >= 2 && count % 10 <= 4 && (count % 100 < 10 || count % 100 >= 20)) {
      return 'друга';
    }
    return 'друзей';
  }
}
