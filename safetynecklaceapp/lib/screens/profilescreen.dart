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

  TextEditingController nameController = TextEditingController();
  TextEditingController dobController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  // TextEditingController emailController = TextEditingController();

  bool canSaveProfileData() {
    return nameController.text.isNotEmpty &&
        dobController.text.isNotEmpty &&
        mobileController.text.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    const cream = Color(0xFFFFEFD2);
    const softcream = Color(0xFFF9DDAA);
    const cardGold = Color(0xFFF4BF5E);
    return Scaffold(
      appBar: AppBar(backgroundColor: cream),
      backgroundColor: cream,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(30.0, 0.0, 30.0, 30.0),
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
                Styledtextfield(controller: nameController, labelText: "Name"),
                Styledtextfield(
                  controller: dobController,
                  labelText: "Date of Birth",
                ),
                Styledtextfield(
                  controller: mobileController,
                  labelText: "Mobile Number",
                ),

                // Styledtextfield(
                //   controller: emailController,
                //   labelText: "Email",
                // ),
                Center(
                  child: ElevatedButton(
                    onPressed: canSaveProfileData()
                        ? () {
                            Data.saveProfileData(
                              name: nameController.text,
                              dob: dobController.text,
                              mobile: mobileController.text,
                              // email: emailController.text,
                            );
                          }
                        : null,
                    child: Text("Save"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
