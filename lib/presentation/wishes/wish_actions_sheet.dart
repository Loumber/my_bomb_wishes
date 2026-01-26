import 'package:flutter/material.dart';

class SheetAction {
  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final bool isDestructive;
  final bool isDefault;

  SheetAction({
    required this.label,
    required this.onTap,
    this.icon,
    this.isDestructive = false,
    this.isDefault = false,
  });
}

class WishActionsSheet extends StatelessWidget {
  final List<SheetAction> actions;
  final String? title;

  const WishActionsSheet({super.key, required this.actions, this.title});

  static Future<void> show({required BuildContext context, required List<SheetAction> actions, String? title}) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => WishActionsSheet(actions: actions, title: title),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.all(16),
      constraints: const BoxConstraints(maxWidth: 500),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(color: colorScheme.surface, borderRadius: BorderRadius.circular(24)),
            child: Column(
              children: [
                if (title != null) _buildTitle(colorScheme),
                ...List.generate(actions.length, (index) {
                  final action = actions[index];
                  return Column(
                    children: [
                      if (index > 0 || title != null)
                        Divider(height: 1, color: colorScheme.outlineVariant.withOpacity(0.5)),
                      _buildActionTile(context, action, colorScheme),
                    ],
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Кнопка отмены
          _buildCancelButton(context, colorScheme),
        ],
      ),
    );
  }

  Widget _buildTitle(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      child: Text(
        title!,
        textAlign: TextAlign.center,
        style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14),
      ),
    );
  }

  Widget _buildActionTile(BuildContext context, SheetAction action, ColorScheme colorScheme) {
    final textColor = action.isDestructive ? colorScheme.error : colorScheme.primary;
    return InkWell(
      onTap: action.onTap,
      borderRadius: BorderRadius.zero,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (action.icon != null) Align(alignment: Alignment.centerLeft, child: Icon(action.icon, color: textColor)),
            Text(
              action.label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textColor,
                fontSize: 18,
                fontWeight: action.isDefault ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCancelButton(BuildContext context, ColorScheme colorScheme) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => Navigator.pop(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: Text(
                'Отмена',
                style: TextStyle(color: colorScheme.onSurface, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
