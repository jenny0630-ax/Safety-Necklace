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
  String _email = '';

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
        _email = data['email'] ?? Auth().currentUser?.email ?? '';
      });
    } else if (mounted) {
      setState(() {
        _email = Auth().currentUser?.email ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const cream = Color(0xFFFFEFD2);
    const cardGold = Color(0xFFF4BF5E);

    final int? age = _parseAge(_dob);

    return Scaffold(
      backgroundColor: cream,
      appBar: AppBar(backgroundColor: cream, title: const Text('Settings')),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 14),
            // ── Profile card ──────────────────────────────────────
            InkWell(
              onTap: () async {
                await Navigator.pushNamed(context, '/profile');
                _loadProfile(); // refresh after edit
              },
              child: SizedBox(
                width: SizeConfig.horizontal! * 85,
                height: SizeConfig.vertical! * 17,
                child: Card(
                  color: cardGold,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 40,
                          backgroundColor: Color(0xFF9E9E9E),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(_name, style: const TextStyle(fontSize: 22)),
                              Text(_dob, style: const TextStyle(fontSize: 18)),
                              if (age != null)
                                Text(
                                  'Age: $age',
                                  style: const TextStyle(fontSize: 18),
                                ),
                              Text(
                                _mobile.isEmpty ? _email : _mobile,
                                style: const TextStyle(fontSize: 18),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── Notifications button ──────────────────────────────
            _goldButton(
              label: 'Notifications',
              onPressed: () => Navigator.pushNamed(context, '/notifications'),
            ),

            const SizedBox(height: 12),

            // ── Language button ───────────────────────────────────
            _goldButton(label: 'Language', onPressed: () {}),

            const SizedBox(height: 12),

            // ── Logout button ─────────────────────────────────────
            _goldButton(
              label: 'Logout',
              onPressed: () {
                Auth().logout().then((_) {
                  Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
                });
              },
            ),

            const Spacer(),

            // ── Help ──────────────────────────────────────────────
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(foregroundColor: Colors.black),
              child: const Text(
                'Help',
                style: TextStyle(
                  fontSize: 34 / 1.6,
                  decoration: TextDecoration.underline,
                  decorationThickness: 1.8,
                ),
              ),
            ),

            // ── Delete Account ────────────────────────────────────
            TextButton(
              onPressed: () => _confirmDeleteAccount(context),
              style: TextButton.styleFrom(foregroundColor: Colors.black87),
              child: const Text(
                'Delete Account',
                style: TextStyle(fontSize: 34 / 1.6),
              ),
            ),

            const SizedBox(height: 16),
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
          style: const TextStyle(fontSize: 36 / 1.6, color: Color(0xFF3A3A3A)),
        ),
      ),
    );
  }

  int? _parseAge(String dob) {
    if (dob.trim().isEmpty) return null;

    final now = DateTime.now();
    DateTime? birth;

    final DateTime? parsed = DateTime.tryParse(dob.trim());
    if (parsed != null) {
      birth = parsed;
    } else {
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
