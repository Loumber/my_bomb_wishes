import 'package:flutter/material.dart';
import 'package:my_bomb_wishes/common/di/di.dart';
import 'package:my_bomb_wishes/domain/entities/user_profile.dart';
import 'package:my_bomb_wishes/presentation/profile/profile_view.dart';
import 'package:my_bomb_wishes/presentation/profile/profile_view_model.dart';

class UserListTile extends StatefulWidget {
  final UserProfile user;
  const UserListTile({super.key, required this.user});

  @override
  State<UserListTile> createState() => _UserListTileState();
}

class _UserListTileState extends State<UserListTile> {
  late final ProfileViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<ProfileViewModel>(param1: widget.user.id);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: ListTile(
        onTap:
            () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileView(profile: widget.user))),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: CircleAvatar(
          radius: 22,
          backgroundColor: colorScheme.secondaryContainer,
          child: ClipOval(
            child:
                widget.user.photoUrl.isNotEmpty
                    ? Image.network(
                      widget.user.photoUrl,
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.person, size: 24, color: colorScheme.onSecondaryContainer);
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                        );
                      },
                    )
                    : Icon(Icons.person, size: 24, color: colorScheme.onSecondaryContainer),
          ),
        ),
        title: Text(
          widget.user.firstName,
          style: TextStyle(color: colorScheme.onSurface, fontSize: 17, fontWeight: FontWeight.w500),
        ),
        trailing: _viewModel.isMyProfile ? null : _buildFollowButton(colorScheme),
      ),
    );
  }

  Widget _buildFollowButton(ColorScheme colorScheme) {
    return StreamBuilder<bool?>(
      stream: _viewModel.isFollowingStream,
      builder: (context, followSnapshot) {
        if (!followSnapshot.hasData) {
          return Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(color: colorScheme.secondaryContainer.withOpacity(0.5), shape: BoxShape.circle),
          );
        }

        final isFollowing = followSnapshot.data ?? false;

        return StreamBuilder<bool>(
          stream: _viewModel.isLoadingStream,
          initialData: false,
          builder: (context, loadingSnapshot) {
            final isLoading = loadingSnapshot.data ?? false;

            return GestureDetector(
              onTap: isLoading ? null : () => _viewModel.toggleFollow(),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isFollowing ? colorScheme.primary.withOpacity(0.1) : colorScheme.secondaryContainer,
                  shape: BoxShape.circle,
                ),
                child:
                    isLoading
                        ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: colorScheme.primary),
                        )
                        : Icon(isFollowing ? Icons.check : Icons.add, color: colorScheme.primary, size: 18),
              ),
            );
          },
        );
      },
    );
  }
}
