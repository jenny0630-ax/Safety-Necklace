import 'dart:io';

import 'package:flutter/material.dart';
import 'package:safetynecklaceapp/components/styledInputField.dart';
import 'package:image_picker/image_picker.dart';
import 'package:safetynecklaceapp/services/auth.dart';
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
  TextEditingController emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    nameController.addListener(_refresh);
    dobController.addListener(_refresh);
    mobileController.addListener(_refresh);
    emailController.addListener(_refresh);
    _loadExistingProfile();
  }

  @override
  void dispose() {
    nameController.removeListener(_refresh);
    dobController.removeListener(_refresh);
    mobileController.removeListener(_refresh);
    emailController.removeListener(_refresh);
    nameController.dispose();
    dobController.dispose();
    mobileController.dispose();
    emailController.dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  Future<void> _loadExistingProfile() async {
    final data = await Data.getProfileData();
    if (data != null && mounted) {
      nameController.text = data['name'] ?? '';
      dobController.text = data['dob'] ?? '';
      mobileController.text = data['mobile'] ?? '';
      emailController.text = data['email'] ?? Auth().currentUser?.email ?? '';
    } else if (mounted) {
      emailController.text = Auth().currentUser?.email ?? '';
    }
    if (mounted) setState(() => _loading = false);
  }

  bool canSaveProfileData() {
    return nameController.text.isNotEmpty &&
        dobController.text.isNotEmpty &&
        mobileController.text.isNotEmpty &&
        emailController.text.isNotEmpty;
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
                      Styledtextfield(
                        controller: emailController,
                        labelText: "Email",
                      ),
                      _profileSummaryCard(),
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
                                    email: emailController.text,
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

  Widget _profileSummaryCard() {
    const cardGold = Color(0xFFF4BF5E);
    final int? age = _ageFromDob(dobController.text);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 22),
      decoration: BoxDecoration(
        color: cardGold,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(nameController.text.isEmpty ? 'Jane Doe' : nameController.text),
          const SizedBox(height: 4),
          Text(
            dobController.text.isEmpty ? 'January 1, 1999' : dobController.text,
          ),
          const SizedBox(height: 4),
          Text(age == null ? 'Age: 32' : 'Age: $age'),
          const SizedBox(height: 4),
          Text(
            mobileController.text.isEmpty
                ? '123-456-7890'
                : mobileController.text,
          ),
        ],
      ),
    );
  }

  int? _ageFromDob(String dob) {
    if (dob.trim().isEmpty) return null;
    final now = DateTime.now();

    DateTime? birth = DateTime.tryParse(dob.trim());
    if (birth == null) {
      final parts = dob.split('/');
      if (parts.length == 3) {
        final month = int.tryParse(parts[0]);
        final day = int.tryParse(parts[1]);
        final year = int.tryParse(parts[2]);
        if (month != null && day != null && year != null) {
          birth = DateTime(year, month, day);
        }
      }
    }

    if (birth == null) return null;
    var age = now.year - birth.year;
    final hadBirthday =
        now.month > birth.month ||
        (now.month == birth.month && now.day >= birth.day);
    if (!hadBirthday) age -= 1;
    return age < 0 ? null : age;
  }
}
