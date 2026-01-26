import 'dart:typed_data';
import 'package:flutter/material.dart';


class WishPhotoPicker extends StatelessWidget {
  final Uint8List? imageBytes;
  final String? imageUrl;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const WishPhotoPicker({
    super.key,
    this.imageBytes,
    this.imageUrl,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    final hasImage = imageBytes != null || (imageUrl != null && imageUrl!.isNotEmpty);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            GestureDetector(
              onTap: onTap,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(24),
                  image: hasImage 
                      ? DecorationImage(
                          image: imageBytes != null 
                              ? MemoryImage(imageBytes!) as ImageProvider
                              : NetworkImage(imageUrl!),
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(
                            Colors.black.withOpacity(0.2),
                            BlendMode.darken,
                          ),
                        )
                      : null,
                ),
                child: !hasImage
                    ? _buildPlaceholder(colorScheme)
                    : Center(
                        child: Icon(
                          Icons.photo_camera_rounded,
                          color: Colors.white.withOpacity(0.9),
                          size: 32,
                        ),
                      ),
              ),
            ),

            if (hasImage)
              Positioned(
                top: -8,
                right: -8,
                child: GestureDetector(
                  onTap: onDelete,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(color: colorScheme.surface, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildPlaceholder(ColorScheme colorScheme) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_a_photo_rounded, color: colorScheme.primary, size: 36),
          const SizedBox(height: 8),
          const Text(
            'Добавить фоточку',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ],
      );
}