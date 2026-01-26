import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:my_bomb_wishes/common/di/di.dart';
import 'package:my_bomb_wishes/presentation/widgets/wish_photo_picker.dart';
import 'package:my_bomb_wishes/presentation/wishes/widgets/wish_input_fields.dart';
import 'package:my_bomb_wishes/presentation/wishes/widgets/wish_sheet_app_bar.dart';
import '../../domain/entities/wish.dart'; // Путь к вашей модели Wish
import 'wishes_view_model.dart';

class WishFormSheet extends StatefulWidget {
  final String userId;
  final Wish? wish;

  const WishFormSheet({super.key, required this.userId, this.wish});

  @override
  State<WishFormSheet> createState() => _WishFormSheetState();
}

class _WishFormSheetState extends State<WishFormSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  late final TextEditingController _linkController;
  late final TextEditingController _priceController;

  bool _isImageDeleted = false;
  Uint8List? _pickedImageBytes;
  String? _pickedImageName;
  String? _titleError;
  bool _isLoading = false;

  bool get _isEditing => widget.wish != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.wish?.title);
    _descController = TextEditingController(text: widget.wish?.description);
    _linkController = TextEditingController(text: widget.wish?.link);
    final priceText = widget.wish?.price != null ? widget.wish!.price!.toStringAsFixed(0).replaceAll('.', ',') : '';
    _priceController = TextEditingController(text: priceText);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _linkController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTopHandle(colorScheme),
            WishSheetAppBar(
              isEditing: _isEditing,
              isLoading: _isLoading,
              onCancel: () => Navigator.pop(context),
              onSave: _saveWish,
            ),
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
                child: Column(
                  children: [
                    WishPhotoPicker(
                      imageBytes: _pickedImageBytes,
                      onTap: _pickImage,
                      imageUrl: _isImageDeleted ? null : widget.wish?.imageUrl,
                      onDelete:
                          () => setState(() {
                            _pickedImageBytes = null;
                            _isImageDeleted = true;
                          }),
                    ),
                    const SizedBox(height: 24),
                    WishInputFields(
                      titleController: _titleController,
                      descController: _descController,
                      linkController: _linkController,
                      priceController: _priceController,
                      titleError: _titleError,
                      onTitleChanged: (val) {
                        if (_titleError != null && val.isNotEmpty) {
                          setState(() => _titleError = null);
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopHandle(ColorScheme colorScheme) {
    return Container(
      width: 36,
      height: 4,
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.onSurfaceVariant.withOpacity(0.4),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      final bytes = await ImagePickerWeb.getImageAsBytes();
      if (bytes != null) {
        setState(() {
          _pickedImageBytes = bytes;
          _pickedImageName = "image_${DateTime.now().millisecondsSinceEpoch}.jpg";
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка выбора фото: $e')));
      }
    }
  }

  Future<void> _saveWish() async {
    final title = _titleController.text.trim();

    if (title.isEmpty) {
      setState(() => _titleError = 'Введите название желания');
      return;
    }

    setState(() {
      _titleError = null;
      _isLoading = true;
    });

    try {
      final wishesVM = getIt<WishesViewModel>(param1: widget.userId);

      if (_isEditing) {
        await wishesVM.updateWish(
          id: widget.wish!.id,
          title: title,
          description: _descController.text.trim(),
          link: _linkController.text.trim(),
          price: double.tryParse(_priceController.text.replaceAll(',', '.')),
          imageBytes: _pickedImageBytes,
          imageName: _pickedImageName,
        );
      } else {
        await wishesVM.createWish(
          title: title,
          description: _descController.text.trim(),
          link: _linkController.text.trim(),
          price: double.tryParse(_priceController.text.replaceAll(',', '.')),
          imageBytes: _pickedImageBytes,
          imageName: _pickedImageName,
        );
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
