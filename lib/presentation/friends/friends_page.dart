import 'package:flutter/material.dart';
import 'package:my_bomb_wishes/common/di/di.dart';
import 'package:my_bomb_wishes/presentation/friends/widgets/friends_header.dart';
import 'package:my_bomb_wishes/presentation/friends/widgets/friends_list_stream.dart';
import 'package:my_bomb_wishes/presentation/friends/widgets/friends_tab_bar.dart';
import 'package:my_bomb_wishes/presentation/pages/friends_search_page.dart';
import 'friends_view_model.dart';

class FriendsPage extends StatefulWidget {
  final String userId;
  const FriendsPage({super.key, required this.userId});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  late final FriendsViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<FriendsViewModel>(param1: widget.userId);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            FriendsHeader(
              isMyProfile: _viewModel.isMyProfile,
              onSearchTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FriendsSearchPage()),
              ),
            ),
            const SizedBox(height: 8),
            StreamBuilder<FriendsTab>(
              stream: _viewModel.currentTabStream,
              builder: (context, snapshot) {
                return FriendsTabBar(
                  currentTab: snapshot.data ?? FriendsTab.following,
                  onTabChanged: _viewModel.setTab,
                );
              },
            ),
            const SizedBox(height: 16),            
            Expanded(
              child: FriendsListStream(viewModel: _viewModel),
            ),
          ],
        ),
      ),
    );
  }
}