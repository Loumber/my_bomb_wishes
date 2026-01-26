import 'package:flutter/material.dart';
import 'package:my_bomb_wishes/common/di/di.dart';
import 'package:my_bomb_wishes/domain/entities/user_profile.dart'; // Не забудь импорт сущности
import 'package:my_bomb_wishes/presentation/friends/friends_page.dart';
import 'package:my_bomb_wishes/presentation/profile/auth_view_model.dart';
import 'package:my_bomb_wishes/presentation/profile/profile_state.dart';
import 'package:my_bomb_wishes/presentation/profile/profile_view.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  late final AuthViewModel _vm;
  late TabController _tabController;
  final GlobalKey _tabKey = GlobalKey();
  double _tabWidth = 0;

  @override
  void initState() {
    super.initState();
    _vm = getIt<AuthViewModel>();
    _vm.signIn();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: StreamBuilder<AuthPageState>(
          stream: _vm.pageState,
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const SizedBox.shrink();
            final state = snapshot.data!;
            if (state.error != null && state.profile == null) {
              return Center(child: Text('Ошибка: ${state.error}'));
            }
            if (state.isLoading && state.profile == null) {
              return const Center(child: CircularProgressIndicator.adaptive());
            }
            if (state.isAuthorized && state.profile != null) {
              return _buildAuthorizedContent(state.profile!);
            }
            return const Center(child: Text('Пожалуйста, войдите через Telegram'));
          },
        ),
      ),
    );
  }

  Widget _buildAuthorizedContent(UserProfile profile) {
    return Column(
      children: [
        _buildTopTabBar(context),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [ProfileView(profile: profile), FriendsPage(userId: profile.id)],
          ),
        ),
      ],
    );
  }

  Widget _buildTopTabBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: AnimatedBuilder(
        animation: _tabController.animation!,
        builder: (context, _) {
          final double offset = _tabController.animation!.value;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final RenderBox? renderBox = _tabKey.currentContext?.findRenderObject() as RenderBox?;
            if (renderBox != null && renderBox.size.width != _tabWidth) {
              setState(() {
                _tabWidth = renderBox.size.width;
              });
            }
          });

          return SizedBox(
            height: 4,
            child: Stack(
              children: [
                Row(
                  children: [
                    Expanded(child: _buildStaticBase(context, key: _tabKey)),
                    const SizedBox(width: 32),
                    Expanded(child: _buildStaticBase(context)),
                  ],
                ),
                Positioned(
                  left: (_tabWidth + 32) * offset,
                  width: _tabWidth,
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStaticBase(BuildContext context, {Key? key}) {
    return Container(
      key: key,
      height: 4,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Theme.of(context).colorScheme.secondaryContainer,
      ),
    );
  }
}
