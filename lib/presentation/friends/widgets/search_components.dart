import 'package:flutter/material.dart';
import 'package:my_bomb_wishes/presentation/profile/profile_view_model.dart';
import 'package:rxdart/rxdart.dart';

class SearchTextField extends StatelessWidget {
  final ValueChanged<String> onChanged;
  const SearchTextField({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          filled: true,
          fillColor: colorScheme.secondaryContainer.withOpacity(0.4),
          prefixIcon: const Icon(Icons.search),
          hintText: 'Поиск',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
        ),
      ),
    );
  }
}

class SearchEmptyState extends StatelessWidget {
  const SearchEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    return Center(
      child: Padding(
        padding: EdgeInsets.only(bottom: keyboardHeight / 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: 64, color: Theme.of(context).colorScheme.outline.withOpacity(0.5)),
            const SizedBox(height: 16),
            const Text('Пользователи не найдены'),
          ],
        ),
      ),
    );
  }
}

class FollowButton extends StatelessWidget {
  final ProfileViewModel viewModel;
  const FollowButton({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return StreamBuilder<Map<String, bool>>(
      stream: Rx.combineLatest2<bool?, bool, Map<String, bool>>(
        viewModel.isFollowingStream,
        viewModel.isLoadingStream,
        (isFollowing, isLoading) => {'isFollowing': isFollowing ?? false, 'isLoading': isLoading},
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        final isFollowing = snapshot.data!['isFollowing']!;
        final isLoading = snapshot.data!['isLoading']!;

        return ElevatedButton(
          onPressed: isLoading ? null : () => viewModel.toggleFollow(),
          style: ElevatedButton.styleFrom(
            backgroundColor: isFollowing ? colorScheme.secondaryContainer : colorScheme.primary,
            foregroundColor: isFollowing ? colorScheme.onSecondaryContainer : colorScheme.onPrimary,
            elevation: 0,
            minimumSize: const Size(110, 34),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          ),
          child: isLoading
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : Text(isFollowing ? 'Отписаться' : 'Подписаться'),
        );
      },
    );
  }
}