import 'package:flutter/material.dart';
import 'package:my_bomb_wishes/presentation/friends/friends_view_model.dart';

class FriendsTabBar extends StatelessWidget {
  final FriendsTab currentTab;
  final Function(FriendsTab) onTabChanged;

  const FriendsTabBar({
    super.key,
    required this.currentTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _SegmentButton(
            label: 'Подписки',
            isSelected: currentTab == FriendsTab.following,
            onTap: () => onTabChanged(FriendsTab.following),
          ),
          _SegmentButton(
            label: 'Подписчики',
            isSelected: currentTab == FriendsTab.followers,
            onTap: () => onTabChanged(FriendsTab.followers),
          ),
        ],
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SegmentButton({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? colorScheme.primaryContainer : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? colorScheme.onPrimaryContainer : colorScheme.onSecondaryContainer.withOpacity(0.7),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }
}