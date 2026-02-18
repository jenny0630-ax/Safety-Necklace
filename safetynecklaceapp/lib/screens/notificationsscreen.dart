import 'package:flutter/material.dart';
import 'package:safetynecklaceapp/services/data.dart';

/// Notification preferences screen – Sound and Vibration toggles
/// matching the wireframe.
class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool _sound = true;
  bool _vibration = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await Data.getNotificationPrefs();
    if (mounted) {
      setState(() {
        _sound = prefs['sound'] ?? true;
        _vibration = prefs['vibration'] ?? false;
        _loading = false;
      });
    }
  }

  Future<void> _save() async {
    await Data.saveNotificationPrefs(sound: _sound, vibration: _vibration);
  }

  @override
  Widget build(BuildContext context) {
    const cream = Color(0xFFFFEFD2);
    const softcream = Color(0xFFF9DDAA);

    return Scaffold(
      backgroundColor: cream,
      appBar: AppBar(
        backgroundColor: cream,
        title: const Text('Notifications'),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Card(
                color: softcream,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SwitchListTile(
                      title: const Text(
                        'Sound',
                        style: TextStyle(fontSize: 20),
                      ),
                      value: _sound,
                      activeColor: const Color(0xFFF4BF5E),
                      onChanged: (v) {
                        setState(() => _sound = v);
                        _save();
                      },
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      title: const Text(
                        'Vibration',
                        style: TextStyle(fontSize: 20),
                      ),
                      value: _vibration,
                      activeColor: const Color(0xFFF4BF5E),
                      onChanged: (v) {
                        setState(() => _vibration = v);
                        _save();
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
