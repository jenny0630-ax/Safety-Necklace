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
            InkWell(
              onTap: () {
                Navigator.pushNamed(context, '/profile');
              },
              child: SizedBox(
                width: SizeConfig.horizontal! * 85,
                height: SizeConfig.vertical! * 25,
                child: Card(
                  color: cardGold,
                  elevation: 5,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CircleAvatar(radius: 65),
                      SizedBox(
                        width: SizeConfig.horizontal! * 38,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text("Jane Doe", style: TextStyle(fontSize: 18)),
                            Text(
                              "September 31, 1999",
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.visible,
                              maxLines: 2,
                              style: TextStyle(fontSize: 18),
                            ),
                            Text("Age: 32", style: TextStyle(fontSize: 18)),
                            Text(
                              "123-456-7890",
                              style: TextStyle(fontSize: 18),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              width: SizeConfig.horizontal! * 85,
              height: SizeConfig.vertical! * 7,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: cardGold,
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {},
                child: Text(
                  "Notifications",
                  style: TextStyle(
                    fontSize: 25,
                    color: const Color(0xFF3A3A3A),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: SizeConfig.horizontal! * 85,
              height: SizeConfig.vertical! * 7,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: cardGold,
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {},
                child: Text(
                  "Language",
                  style: TextStyle(fontSize: 25, color: Color(0xFF3A3A3A)),
                ),
              ),
            ),
            SizedBox(
              width: SizeConfig.horizontal! * 85,
              height: SizeConfig.vertical! * 7,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: cardGold,
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/account');
                },
                child: Text(
                  "Account Information",
                  style: TextStyle(fontSize: 25, color: Color(0xFF3A3A3A)),
                ),
              ),
            ),
            SizedBox(
              width: SizeConfig.horizontal! * 85,
              height: SizeConfig.vertical! * 7,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: cardGold,
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {},
                child: Text(
                  "Logout",
                  style: TextStyle(fontSize: 25, color: Color(0xFF3A3A3A)),
                ),
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
