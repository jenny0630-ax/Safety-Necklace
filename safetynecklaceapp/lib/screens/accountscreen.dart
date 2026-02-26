import 'package:flutter/material.dart';
import 'package:safetynecklaceapp/services/auth.dart';
import 'package:safetynecklaceapp/size_config.dart';

class Accountscreen extends StatefulWidget {
  const Accountscreen({super.key});

  @override
  State<Accountscreen> createState() => _AccountscreenState();
}

class _AccountscreenState extends State<Accountscreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();

  bool isOldValid = false;

  @override
  void initState() {
    super.initState();
    emailController.text = Auth().currentUser?.email ?? '';
  }

  @override
  void dispose() {
    emailController.dispose();
    oldPasswordController.dispose();
    newPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    const cream = Color(0xFFFFEFD2);
    return Scaffold(
      appBar: AppBar(backgroundColor: cream),
      backgroundColor: cream,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Stack(
              children: [
                SizedBox(
                  width: SizeConfig.horizontal! * 85,
                  child: TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Email',
                    ),
                  ),
                ),
                Positioned(
                  right: 5,
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Email changes are disabled in this MVP. Use password reset if needed.',
                          ),
                        ),
                      );
                    },
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
            if (!isOldValid)
              Stack(
                children: [
                  SizedBox(
                    width: SizeConfig.horizontal! * 85,
                    child: TextField(
                      controller: oldPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Old Password',
                      ),
                    ),
                  ),
                  Positioned(
                    right: 5,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (oldPasswordController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Enter your current password.'),
                            ),
                          );
                          return;
                        }
                        final value = await Auth().reauthenticate(
                          oldPasswordController.text,
                        );
                        if (!context.mounted) return;
                        setState(() {
                          isOldValid = value;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              value
                                  ? 'Password verified. Enter a new password.'
                                  : 'Could not verify password.',
                            ),
                          ),
                        );
                      },
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            if (isOldValid)
              Stack(
                children: [
                  SizedBox(
                    width: SizeConfig.horizontal! * 85,
                    child: TextField(
                      controller: newPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'New Password',
                      ),
                    ),
                  ),
                  Positioned(
                    right: 5,
                    child: ElevatedButton(
                      onPressed: () async {
                        final newPassword = newPasswordController.text.trim();
                        if (newPassword.length < 6) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'New password must be at least 6 characters.',
                              ),
                            ),
                          );
                          return;
                        }
                        final error = await Auth().changePassword(newPassword);
                        if (!context.mounted) return;
                        setState(() {
                          isOldValid = false;
                          oldPasswordController.clear();
                          newPasswordController.clear();
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              error == null
                                  ? 'Password updated.'
                                  : 'Failed to update password: $error',
                            ),
                          ),
                        );
                      },
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
