import 'dart:async';
import 'package:flutter/material.dart';
import 'package:safetynecklaceapp/services/auth.dart';
import 'package:safetynecklaceapp/services/data.dart';
import 'package:safetynecklaceapp/size_config.dart';

class Settingscreen extends StatefulWidget {
  const Settingscreen({super.key});

  @override
  State<Settingscreen> createState() => _SettingscreenState();
}

class _SettingscreenState extends State<Settingscreen> {
  String _name = 'User';
  String _dob = '';
  String _mobile = '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final data = await Data.getProfileData();
    if (data != null && mounted) {
      setState(() {
        _name = data['name'] ?? 'User';
        _dob = data['dob'] ?? '';
        _mobile = data['mobile'] ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const cream = Color(0xFFFFEFD2);
    const cardGold = Color(0xFFF4BF5E);
    return Scaffold(
      backgroundColor: cream,
      appBar: AppBar(backgroundColor: cream, title: const Text('Settings')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // ── Profile card ──────────────────────────────────────
            InkWell(
              onTap: () async {
                await Navigator.pushNamed(context, '/profile');
                _loadProfile(); // refresh after edit
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
                      const CircleAvatar(radius: 65),
                      SizedBox(
                        width: SizeConfig.horizontal! * 38,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(_name, style: const TextStyle(fontSize: 18)),
                            Text(
                              _dob,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.visible,
                              maxLines: 2,
                              style: const TextStyle(fontSize: 18),
                            ),
                            Text(_mobile, style: const TextStyle(fontSize: 18)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Notifications button ──────────────────────────────
            _goldButton(
              label: 'Notifications',
              onPressed: () => Navigator.pushNamed(context, '/notifications'),
            ),

            // ── Language button ───────────────────────────────────
            _goldButton(label: 'Language', onPressed: () {}),

            // ── Logout button ─────────────────────────────────────
            _goldButton(
              label: 'Logout',
              onPressed: () {
                Auth().logout().then((_) {
                  Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
                });
              },
            ),

            // ── Help ──────────────────────────────────────────────
            TextButton(
              onPressed: () {},
              child: const Text(
                'Help',
                style: TextStyle(fontSize: 20, color: Colors.black),
              ),
            ),

            // ── Delete Account ────────────────────────────────────
            TextButton(
              onPressed: () => _confirmDeleteAccount(context),
              child: const Text(
                'Delete Account',
                style: TextStyle(fontSize: 20, color: Colors.red),
              ),
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/home',
                  (_) => false,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
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

  Widget _goldButton({required String label, required VoidCallback onPressed}) {
    return SizedBox(
      width: SizeConfig.horizontal! * 85,
      height: SizeConfig.vertical! * 7,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF4BF5E),
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: const TextStyle(fontSize: 25, color: Color(0xFF3A3A3A)),
        ),
      ),
    );
  }

  Future<void> _confirmDeleteAccount(BuildContext ctx) async {
    final confirmed = await showDialog<bool>(
      context: ctx,
      builder: (c) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to permanently delete your account '
          'and all associated data? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await Data.deleteAllUserData();
      await Auth().currentUser?.delete();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
      }
    }
  }
}
