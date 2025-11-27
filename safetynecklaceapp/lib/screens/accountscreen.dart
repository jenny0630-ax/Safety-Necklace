import 'package:flutter/material.dart';
import 'package:safetynecklaceapp/services/auth.dart';
import 'package:safetynecklaceapp/size_config.dart';

class Accountscreen extends StatefulWidget {
  const Accountscreen({super.key});

  @override
  State<Accountscreen> createState() => _AccountscreenState();
}

class _AccountscreenState extends State<Accountscreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController oldPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();

  bool isOldValid = false;

  @override
  void initState() {
    super.initState();
    emailController.text = Auth().currentUser?.email ?? '';
    print('User email: ${emailController.text}');
  }

  @override
  Widget build(BuildContext context) {
    const cream = Color(0xFFFFEFD2);
    const softcream = Color(0xFFF9DDAA);
    const cardGold = Color(0xFFF4BF5E);
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
                  child: ElevatedButton(onPressed: () {}, child: Text('Save')),
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
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Old Password',
                      ),
                    ),
                  ),
                  Positioned(
                    right: 5,
                    child: ElevatedButton(
                      onPressed: () {
                        Auth().reauthenticate(oldPasswordController.text).then((
                          value,
                        ) {
                          setState(() {
                            isOldValid = value;
                          });
                        });
                      },
                      child: Text('Save'),
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
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'New Password',
                      ),
                    ),
                  ),
                  Positioned(
                    right: 5,
                    child: ElevatedButton(
                      onPressed: () {
                        Auth().changePassword(newPasswordController.text).then((
                          value,
                        ) {
                          setState(() {
                            isOldValid = false;
                            oldPasswordController.clear();
                            newPasswordController.clear();
                          });
                        });
                      },
                      child: Text('Save'),
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
