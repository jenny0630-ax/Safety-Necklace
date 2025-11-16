import 'dart:io';

import 'package:flutter/material.dart';
import 'package:safetynecklaceapp/components/styledInputField.dart';
import 'package:image_picker/image_picker.dart';
import 'package:safetynecklaceapp/services/data.dart';

class Profilescreen extends StatefulWidget {
  const Profilescreen({super.key});

  @override
  State<Profilescreen> createState() => _ProfilescreenState();
}

class _ProfilescreenState extends State<Profilescreen> {
  XFile? _profileImage;

  @override
  Widget build(BuildContext context) {
    const cream = Color(0xFFFFEFD2);
    const softcream = Color(0xFFF9DDAA);
    const cardGold = Color(0xFFF4BF5E);
    return Scaffold(
      backgroundColor: cream,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    ImagePicker().pickImage(source: ImageSource.gallery).then((
                      pickedImage,
                    ) {
                      if (pickedImage != null) {
                        setState(() {
                          _profileImage = pickedImage;
                        });

                        Data.saveProfileImage(File(pickedImage.path));
                      }
                    });
                  },
                  child: CircleAvatar(
                    radius: 60,
                    foregroundImage: _profileImage != null
                        ? FileImage(File(_profileImage!.path))
                        : null,
                  ),
                ),
                Styledtextfield(labelText: "Name"),
                Styledtextfield(labelText: "Date of Birth"),
                Styledtextfield(labelText: "Mobile Number"),
                Styledtextfield(labelText: "Email"),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
