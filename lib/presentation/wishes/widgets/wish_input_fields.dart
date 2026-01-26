import 'package:flutter/material.dart';
import 'package:my_bomb_wishes/presentation/widgets/custom_text_field.dart';

class WishInputFields extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController descController;
  final TextEditingController linkController;
  final TextEditingController priceController;
  final String? titleError;
  final ValueChanged<String> onTitleChanged;

  const WishInputFields({
    super.key,
    required this.titleController,
    required this.descController,
    required this.linkController,
    required this.priceController,
    this.titleError,
    required this.onTitleChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomTextField(controller: linkController, hint: 'Ссылка', icon: Icons.link),
        const SizedBox(height: 16),
        CustomTextField(
          controller: titleController,
          hint: 'Название',
          errorText: titleError,
          onChanged: onTitleChanged,
        ),
        const SizedBox(height: 16),
        CustomTextField(controller: descController, hint: 'Описание', maxLines: 4),
        const SizedBox(height: 16),
        CustomTextField(controller: priceController, hint: 'Цена', isPrice: true),
      ],
    );
  }
}