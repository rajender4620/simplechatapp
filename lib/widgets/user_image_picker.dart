import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  const UserImagePicker({super.key, required this.pickedImage});

  final void Function(File pickedImage) pickedImage;
  @override
  State<UserImagePicker> createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  File? pickedImageFile;

  void pickImage() async {
    final pickedimage = await ImagePicker().pickImage(
        source: ImageSource.gallery, imageQuality: 50, maxWidth: 150);
    if (pickedimage == null) {
      return;
    }
    setState(() {
      pickedImageFile = File(pickedimage.path);
    });
    widget.pickedImage(pickedImageFile!);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.grey,
          foregroundImage:
              pickedImageFile != null ? FileImage(pickedImageFile!) : null,
        ),
        TextButton.icon(
            onPressed: () {
              pickImage();
            },
            icon: const Icon(Icons.image, color: Colors.deepPurple),
            label: const Text(
              'Add Image',
              style: TextStyle(color: Colors.deepPurple),
            )),
      ],
    );
  }
}
