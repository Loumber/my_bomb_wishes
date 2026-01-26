import 'package:flutter/material.dart';

class FriendsHeader extends StatelessWidget {
  final bool isMyProfile;
  final VoidCallback onSearchTap;

  const FriendsHeader({
    super.key,
    required this.isMyProfile,
    required this.onSearchTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bool showBackButton = !isMyProfile;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          if (showBackButton)
            IconButton(
              icon: Icon(Icons.arrow_back_ios_new, color: colorScheme.onSurface, size: 22),
              onPressed: () => Navigator.of(context).pop(),
            ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Друзья',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
            ),
          ),
          if (!showBackButton)
            TextButton.icon(
              onPressed: onSearchTap,
              icon: Icon(Icons.person_add_alt_1, color: colorScheme.primary, size: 20),
              label: Text(
                'Найти',
                style: TextStyle(color: colorScheme.primary, fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
        ],
      ),
    );
  }
}