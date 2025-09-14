import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
// import 'package:safetynecklaceapp/size_config.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          SizedBox(child: Card()),
          SizedBox(child: Card()),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            ListTile(title: Text('About Device'), onTap: () {}),
            ListTile(title: Text('Settings'), onTap: () {}),
            ListTile(title: Text('Logout'), onTap: () {}),
          ],
        ),
      ),
    );
  }
}
