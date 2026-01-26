import 'package:flutter/material.dart';
import 'package:my_bomb_wishes/common/di/di.dart';
import 'package:my_bomb_wishes/domain/entities/user_profile.dart';
import 'package:my_bomb_wishes/presentation/profile/profile_view_model.dart';
import 'package:my_bomb_wishes/presentation/profile/widgets/my_profile_actions.dart';
import 'package:my_bomb_wishes/presentation/profile/widgets/profile_header.dart';
import 'package:my_bomb_wishes/presentation/profile/widgets/social_actions.dart';
import 'package:my_bomb_wishes/presentation/wishes/wishes_grid.dart';
import 'package:my_bomb_wishes/presentation/wishes/wishes_view_model.dart';

class ProfileView extends StatefulWidget {
  final UserProfile profile;
  const ProfileView({super.key, required this.profile});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  late final WishesViewModel wishesViewModel;
  late final ProfileViewModel profileViewModel;

  @override
  void initState() {
    super.initState();
    wishesViewModel = getIt<WishesViewModel>(param1: widget.profile.id);
    profileViewModel = getIt<ProfileViewModel>(param1: widget.profile.id);
  }

  @override
  void dispose() {
    wishesViewModel.dispose();
    profileViewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            toolbarHeight: profileViewModel.isMyProfile ? 0 : 44,
            floating: true,
            pinned: false,
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false,
            leading:
                !profileViewModel.isMyProfile
                    ? IconButton(
                      icon: Icon(Icons.arrow_back_ios_new, color: colorScheme.onSurface),
                      onPressed: () => Navigator.of(context).pop(),
                    )
                    : null,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, profileViewModel.isMyProfile ? 0 : 24, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(child: ProfileHeader(profile: widget.profile)),
                  const SizedBox(height: 24),
                  profileViewModel.isMyProfile
                      ? MyProfileActions(wishesViewModel: wishesViewModel, profileId: widget.profile.id)
                      : SocialActions(viewModel: profileViewModel),
                ],
              ),
            ),
          ),
          WishesGrid(viewModel: wishesViewModel),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }
}
