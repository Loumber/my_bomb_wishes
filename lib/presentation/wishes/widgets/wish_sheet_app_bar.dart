import 'package:flutter/material.dart';

class WishSheetAppBar extends StatelessWidget {
  final bool isEditing;
  final bool isLoading;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  const WishSheetAppBar({
    super.key,
    required this.isEditing,
    required this.isLoading,
    required this.onCancel,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: onCancel,
            child: Text('Отмена', style: TextStyle(color: colorScheme.primary, fontSize: 17)),
          ),
          Text(
            isEditing ? 'Редактировать' : 'Новое желание',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          isLoading
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator.adaptive(strokeWidth: 2.5)),
                )
              : TextButton(
                  onPressed: onSave,
                  child: Text(
                    'Готово',
                    style: TextStyle(color: colorScheme.primary, fontSize: 17, fontWeight: FontWeight.w700),
                  ),
                ),
        ],
      ),
    );
  }
}