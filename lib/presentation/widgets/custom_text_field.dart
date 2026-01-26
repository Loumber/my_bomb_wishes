import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData? icon;
  final int maxLines;
  final bool isPrice;
  final String? errorText;
  final ValueChanged<String>? onChanged;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.icon,
    this.maxLines = 1,
    this.isPrice = false,
    this.errorText,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasError = errorText != null;

    return TextField(
      controller: controller,
      onChanged: onChanged,
      maxLines: maxLines,
      style: theme.textTheme.bodyLarge?.copyWith(color: hasError ? Colors.redAccent : null),
      decoration: InputDecoration(
        hintText: hasError ? errorText : hint,
        hintStyle: TextStyle(
          color: hasError ? Colors.redAccent.withOpacity(0.8) : colorScheme.onSurfaceVariant.withOpacity(0.6),
        ),
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.4),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: hasError ? const BorderSide(color: Colors.redAccent, width: 1.5) : BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: hasError ? Colors.redAccent : colorScheme.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        suffixIcon:
            isPrice
                ? _buildPriceSuffix(colorScheme, hasError)
                : (icon != null ? Icon(icon, color: hasError ? Colors.redAccent : colorScheme.primary) : null),
      ),
    );
  }

  Widget _buildPriceSuffix(ColorScheme colorScheme, bool hasError) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '₽',
          style: TextStyle(
            color: hasError ? Colors.redAccent : colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
