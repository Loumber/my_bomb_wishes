import 'package:flutter/material.dart';
import 'package:my_bomb_wishes/common/di/di.dart';
import 'package:my_bomb_wishes/domain/entities/user_profile.dart';
import 'package:my_bomb_wishes/presentation/friends/friends_search_view_model.dart';
import 'package:my_bomb_wishes/presentation/friends/widgets/search_components.dart';
import 'package:my_bomb_wishes/presentation/profile/profile_view.dart';
import 'package:my_bomb_wishes/presentation/profile/profile_view_model.dart';
import 'package:my_bomb_wishes/presentation/widgets/user_avatar.dart';

class FriendsSearchPage extends StatefulWidget {
  const FriendsSearchPage({super.key});

  @override
  State<FriendsSearchPage> createState() => _FriendsSearchPageState();
}

class _FriendsSearchPageState extends State<FriendsSearchPage> {
  late final FriendsSearchViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<FriendsSearchViewModel>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Найти друзей'),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, size: 20), onPressed: () => Navigator.pop(context)),
      ),
      body: Column(
        children: [
          SearchTextField(onChanged: _viewModel.onSearchChanged),
          Expanded(
            child: StreamBuilder<List<UserProfile>>(
              stream: _viewModel.searchResultsStream,
              builder: (context, snapshot) {
                final users = snapshot.data ?? [];
                if (users.isEmpty) return const SearchEmptyState();

                return ListView.separated(
                  padding: const EdgeInsets.only(top: 16, bottom: 20),
                  itemCount: users.length,
                  separatorBuilder: (_, __) => const Divider(indent: 72),
                  itemBuilder: (context, index) => UserSearchTile(user: users[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class UserSearchTile extends StatefulWidget {
  final UserProfile user;
  const UserSearchTile({super.key, required this.user});

  @override
  State<UserSearchTile> createState() => _UserSearchTileState();
}

class _UserSearchTileState extends State<UserSearchTile> {
  late final ProfileViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = getIt<ProfileViewModel>(param1: widget.user.id);
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: UserAvatar(photoUrl: widget.user.photoUrl),
      title: Text(widget.user.firstName),
      subtitle: widget.user.username != null ? Text('@${widget.user.username}') : null,
      trailing: _vm.isMyProfile ? null : FollowButton(viewModel: _vm),
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileView(profile: widget.user))),
    );
  }
}
