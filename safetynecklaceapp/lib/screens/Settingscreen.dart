import 'package:flutter/material.dart';
import 'package:safetynecklaceapp/services/auth.dart';
import 'package:safetynecklaceapp/size_config.dart';

class Settingscreen extends StatefulWidget {
  const Settingscreen({super.key});

  @override
  State<Settingscreen> createState() => _SettingscreenState();
}

class _SettingscreenState extends State<Settingscreen> {
  @override
  Widget build(BuildContext context) {
    const cream = Color(0xFFFFEFD2);
    const softcream = Color(0xFFF9DDAA);
    const cardGold = Color(0xFFF4BF5E);
    return Scaffold(
      backgroundColor: cream,
      appBar: AppBar(backgroundColor: cream),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: SizeConfig.horizontal! * 85,
              height: SizeConfig.vertical! * 25,
              child: Card(
                child: Row(
                  children: [
                    CircleAvatar(),
                    Column(
                      children: [
                        Text("asdf"),
                        Text("asdf"),
                        Text("asdf"),
                        Text("asdf"),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: SizeConfig.horizontal! * 85,
              height: SizeConfig.vertical! * 7,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: cardGold,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {},
                child: Text("Notifications", style: TextStyle(fontSize: 25)),
              ),
            ),
            SizedBox(
              width: SizeConfig.horizontal! * 85,
              height: SizeConfig.vertical! * 7,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: cardGold,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {},
                child: Text("Language", style: TextStyle(fontSize: 25)),
              ),
            ),
            SizedBox(
              width: SizeConfig.horizontal! * 85,
              height: SizeConfig.vertical! * 7,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: cardGold,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {},
                child: Text("Logout", style: TextStyle(fontSize: 25)),
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                "Help",
                style: TextStyle(fontSize: 20, color: Colors.black),
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                "Delete Account",
                style: TextStyle(fontSize: 20, color: Colors.black),
              ),
            ),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            ListTile(title: Text('About Device'), onTap: () {}),
            ListTile(
              title: Text('Settings'),
              onTap: () {
                // Navigator.pushNamed(context, '/settings');
              },
            ),
            ListTile(
              title: Text('Logout'),
              onTap: () {
                Auth().logout().then((_) {
                  Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
