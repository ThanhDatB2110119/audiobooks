import 'dart:io';

import 'package:audiobooks/presentation/features/creator/cubit/creator_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';

class ImageSourceSelectorButton extends StatelessWidget {
  const ImageSourceSelectorButton({super.key});

  // _showImageSourceSheet(context);
  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        _showImageSourceSheet(context);
      },
      icon: const FaIcon(FontAwesomeIcons.image, color: Colors.black),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white.withValues(alpha: 0.9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        padding: const EdgeInsets.all(8.0),
      ),
      label: const Text(
        'Chọn ảnh ',
        style: TextStyle(fontSize: 14, color: Colors.black),
      ),
    );
  }

  /// Hiển thị bottom sheet cho phép người dùng chọn nguồn ảnh.
  void _showImageSourceSheet(BuildContext context) {
    final creatorCubit = context.read<CreatorCubit>();
    final imagePicker = ImagePicker();

    showModalBottomSheet(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Chọn từ thư viện'),
                onTap: () async {
                  // Đóng bottom sheet trước
                  Navigator.of(sheetContext).pop();
                  // Sau đó mới gọi image picker
                  final XFile? image = await imagePicker.pickImage(
                    source: ImageSource.gallery,
                  );
                  if (image != null) {
                    creatorCubit.createFromFile(File(image.path));
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Chụp ảnh mới'),
                onTap: () async {
                  // Đóng bottom sheet trước
                  Navigator.of(sheetContext).pop();
                  // Sau đó mới gọi image picker
                  final XFile? image = await imagePicker.pickImage(
                    source: ImageSource.camera,
                  );
                  if (image != null) {
                    creatorCubit.createFromFile(File(image.path));
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
