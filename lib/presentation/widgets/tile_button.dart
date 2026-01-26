import 'package:flutter/material.dart';

class TileButton extends StatelessWidget {
  final IconData? icon; // Сделали опциональным (?)
  final String label;
  final Widget? child; // ДОБАВИЛИ ЭТО ПОЛЕ
  final VoidCallback onTap;
  final double? width;
  final double height;
  final Color? backgroundColor;
  final Color? contentColor;
  final MainAxisAlignment alignment;

  const TileButton({
    super.key,
    this.icon, // Убрали required
    this.label = '',
    this.child, // ДОБАВИЛИ В КОНСТРУКТОР
    required this.onTap,
    this.width,
    this.height = 52,
    this.backgroundColor,
    this.contentColor,
    this.alignment = MainAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: backgroundColor ?? Theme.of(context).colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            // ЛОГИКА ТУТ: Если есть child — рисуем его, если нет — стандартный Row
            child: child ?? Row(
              mainAxisAlignment: alignment,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) Icon(icon, color: contentColor ?? Theme.of(context).colorScheme.onSecondaryContainer, size: 22),
                if (label.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      label,
                      style: TextStyle(
                        color: contentColor ?? Theme.of(context).colorScheme.onSecondaryContainer,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}