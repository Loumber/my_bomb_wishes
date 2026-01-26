import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final String photoUrl;
  final double radius;

  const UserAvatar({super.key, required this.photoUrl, this.radius = 22});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return CircleAvatar(
      radius: radius,
      backgroundColor: colorScheme.secondaryContainer,
      child: ClipOval(
        child: photoUrl.isNotEmpty
            ? Image.network(
                photoUrl,
                width: radius * 2,
                height: radius * 2,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Icon(Icons.person, size: radius, color: colorScheme.onSecondaryContainer),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: SizedBox(
                      width: radius,
                      height: radius,
                      child: CircularProgressIndicator(strokeWidth: 2, color: colorScheme.primary.withOpacity(0.5)),
                    ),
                  );
                },
              )
            : Icon(Icons.person, size: radius, color: colorScheme.onSecondaryContainer),
      ),
    );
  }
}