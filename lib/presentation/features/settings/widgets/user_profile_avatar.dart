// presentation/features/settings/widgets/user_profile_avatar.dart

import 'dart:io';
import 'package:flutter/material.dart';

class UserProfileAvatar extends StatelessWidget {
  final String? imageUrl;
  final File? imageFile;
  final double radius;
  final VoidCallback? onTap;

  const UserProfileAvatar({
    super.key,
    this.imageUrl,
    this.imageFile,
    this.radius = 60,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    ImageProvider? provider;

    if (imageFile != null) {
      provider = FileImage(imageFile!);
    } else if (imageUrl != null && imageUrl!.isNotEmpty) {
      provider = NetworkImage(imageUrl!);
    }

    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: radius,
        backgroundColor: Colors.grey[200],
        // Chúng ta không dùng `backgroundImage` nữa
        // Thay vào đó, dùng `child` để có toàn quyền kiểm soát
        child: provider == null
            ? Icon(
                Icons.person,
                size: radius,
                color: Colors.grey[600],
              )
            : ClipOval(
                child: Image(
                  image: provider,
                  height: radius * 2,
                  width: radius * 2,
                  // Dùng BoxFit.cover để lấp đầy hình tròn, giống hành vi cũ nhưng rõ ràng hơn
                  // Nếu bạn muốn thấy TOÀN BỘ ảnh (có thể có khoảng trống), đổi thành `BoxFit.contain`
                  fit: BoxFit.cover, 
                ),
              ),
      ),
    );
  }
}