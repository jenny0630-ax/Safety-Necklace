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
  bool _loading = true;

  TextEditingController nameController = TextEditingController();
  TextEditingController dobController = TextEditingController();
  TextEditingController mobileController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadExistingProfile();
  }

  Future<void> _loadExistingProfile() async {
    final data = await Data.getProfileData();
    if (data != null && mounted) {
      nameController.text = data['name'] ?? '';
      dobController.text = data['dob'] ?? '';
      mobileController.text = data['mobile'] ?? '';
    }
    if (mounted) setState(() => _loading = false);
  }

  bool canSaveProfileData() {
    return nameController.text.isNotEmpty &&
        dobController.text.isNotEmpty &&
        mobileController.text.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    const cream = Color(0xFFFFEFD2);
    const cardGold = Color(0xFFF4BF5E);
    return Scaffold(
      appBar: AppBar(backgroundColor: cream, title: const Text('Edit Profile')),
      backgroundColor: cream,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(30.0, 0.0, 30.0, 30.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () {
                          ImagePicker()
                              .pickImage(source: ImageSource.gallery)
                              .then((pickedImage) {
                                if (pickedImage != null) {
                                  setState(() {
                                    _profileImage = pickedImage;
                                  });
                                  Data.saveProfileImage(File(pickedImage.path));
                                }
                              });
                        },
                        child: Center(
                          child: CircleAvatar(
                            radius: 60,
                            foregroundImage: _profileImage != null
                                ? FileImage(File(_profileImage!.path))
                                : null,
                            child: _profileImage == null
                                ? const Icon(Icons.camera_alt, size: 32)
                                : null,
                          ),
                        ),
                      ),
                      Styledtextfield(
                        controller: nameController,
                        labelText: "Name",
                      ),
                      Styledtextfield(
                        controller: dobController,
                        labelText: "Date of Birth",
                      ),
                      Styledtextfield(
                        controller: mobileController,
                        labelText: "Mobile Number",
                      ),
                      Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: cardGold,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: canSaveProfileData()
                              ? () {
                                  Data.saveProfileData(
                                    name: nameController.text,
                                    dob: dobController.text,
                                    mobile: mobileController.text,
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Profile saved!'),
                                    ),
                                  );
                                  Navigator.pop(context);
                                }
                              : null,
                          child: const Text(
                            'Save',
                            style: TextStyle(fontSize: 18),
                          ),
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
