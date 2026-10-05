import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

const String employeeProfileAvatarHeroTag = 'employee-profile-avatar';

class AppAvatar extends StatelessWidget {
  final String url;
  final String name;
  final double radius;

  const AppAvatar({
    super.key,
    required this.url,
    required this.name,
    this.radius = 20,
  });

  String get _initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return 'U';
  }

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.primary,
      child: ClipOval(
        child: Image.network(
          url,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: AppColors.primary,
              alignment: Alignment.center,
              child: Text(
                _initials,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: radius * 0.8,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
