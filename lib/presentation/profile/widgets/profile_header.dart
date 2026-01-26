import 'package:flutter/material.dart';
import 'package:my_bomb_wishes/domain/entities/user_profile.dart';

class ProfileHeader extends StatelessWidget {
  final UserProfile profile;
  const ProfileHeader({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor: colorScheme.secondaryContainer,
          child: ClipOval(
            child:
                profile.photoUrl.isNotEmpty
                    ? Image.network(
                      profile.photoUrl,
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.person, size: 50, color: colorScheme.onSecondaryContainer);
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value:
                                loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                    : null,
                          ),
                        );
                      },
                    )
                    : Icon(Icons.person, size: 50, color: colorScheme.onSecondaryContainer),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          profile.firstName,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
        ),
      ],
    );
  }
}
