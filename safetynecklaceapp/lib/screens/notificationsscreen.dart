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

    return Scaffold(
      backgroundColor: cream,
      appBar: AppBar(
        backgroundColor: cream,
        title: const Text('Notifications'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.fromLTRB(26, 28, 26, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _toggleRow('Sound', _sound, (v) {
                    setState(() => _sound = v);
                    _save();
                  }),
                  const SizedBox(height: 10),
                  _toggleRow('Vibration', _vibration, (v) {
                    setState(() => _vibration = v);
                    _save();
                  }),
                ],
              ),
            ),
    );
  }

  Widget _toggleRow(String title, bool value, ValueChanged<bool> onChanged) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 36 / 1.6,
              color: Color(0xFF3D3D3D),
            ),
          ),
        ),
        Switch(
          value: value,
          activeColor: const Color(0xFF96D98E),
          activeTrackColor: const Color(0xFFA7E3A3),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          inactiveThumbColor: Colors.white,
          inactiveTrackColor: const Color(0xFFA9ACB2),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
