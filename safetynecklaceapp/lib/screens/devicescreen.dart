import 'dart:async';
import 'package:flutter/material.dart';
import 'package:safetynecklaceapp/services/data.dart';

/// Device detail screen – shows battery, sensor functions, and status
/// for a single paired necklace.
class DeviceScreen extends StatefulWidget {
  final String deviceId;
  const DeviceScreen({super.key, required this.deviceId});

  @override
  State<DeviceScreen> createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen> {
  StreamSubscription? _sub;
  NecklaceDevice? _device;

  @override
  void initState() {
    super.initState();
    _sub = Data.deviceLocationStream(widget.deviceId).listen((dev) {
      if (mounted) setState(() => _device = dev);
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  // Battery colour: green > 50, yellow > 20, red otherwise
  Color _batteryColor(double pct) {
    if (pct > 50) return const Color(0xFF4CAF50);
    if (pct > 20) return const Color(0xFFF4BF5E);
    return const Color(0xFFE53935);
  }

  IconData _batteryIcon(double pct) {
    if (pct > 80) return Icons.battery_full;
    if (pct > 50) return Icons.battery_5_bar;
    if (pct > 20) return Icons.battery_3_bar;
    return Icons.battery_1_bar;
  }

  @override
  Widget build(BuildContext context) {
    const cream = Color(0xFFFFEFD2);
    const softcream = Color(0xFFF9DDAA);

    final device = _device;

    return Scaffold(
      backgroundColor: cream,
      appBar: AppBar(
        backgroundColor: cream,
        title: Text(device?.name ?? 'Device'),
        centerTitle: true,
      ),
      body: device == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                children: [
                  // ── Battery card ──────────────────────────────────
                  _sectionCard(
                    softcream,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 48,
                              height: 90,
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF656565),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: List.generate(4, (i) {
                                  final threshold = (i + 1) * 25;
                                  final active = device.battery >= threshold;
                                  return Container(
                                    height: 16,
                                    decoration: BoxDecoration(
                                      color: active
                                          ? const Color(0xFF97E37A)
                                          : const Color(0xFFB8BEC6),
                                      borderRadius: BorderRadius.circular(7),
                                    ),
                                  );
                                }),
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              _batteryIcon(device.battery),
                              color: _batteryColor(device.battery),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '${device.battery.toStringAsFixed(0)}%',
                          style: const TextStyle(
                            fontSize: 38 / 1.6,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Status card ───────────────────────────────────
                  _sectionCard(
                    softcream,
                    child: Column(
                      children: [
                        _activityRow(
                          dotColor: const Color(0xFF7EE081),
                          title: device.name,
                          subtitle:
                              'Open from: ${_timeFromTimestamp(device.lastTimestamp)}',
                        ),
                        const SizedBox(height: 8),
                        _activityRow(
                          dotColor: const Color(0xFFFF7F7F),
                          title: device.name,
                          subtitle:
                              'Close from: ${_timeFromTimestamp(device.lastTimestamp)}',
                          trailing: Icon(
                            device.gpsFix
                                ? Icons.gps_fixed
                                : Icons.gps_not_fixed,
                            color: const Color(0xFF9AA0A7),
                            size: 20,
                          ),
                        ),
                        const SizedBox(height: 22),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: const [
                            Icon(
                              Icons.circle,
                              size: 11,
                              color: Color(0xFF7EE081),
                            ),
                            SizedBox(width: 6),
                            Text('Online', style: TextStyle(fontSize: 12)),
                            SizedBox(width: 16),
                            Icon(
                              Icons.close,
                              size: 14,
                              color: Color(0xFFFF7F7F),
                            ),
                            SizedBox(width: 6),
                            Text('Offline', style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Necklace functions ─────────────────────────────
                  _sectionCard(
                    softcream,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(bottom: 8),
                          child: Text(
                            'Necklace Functions',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        _functionTile(
                          Icons.location_on,
                          'GPS Tracking',
                          'Real-time location updates',
                          Colors.blue,
                        ),
                        _functionTile(
                          Icons.warning_amber_rounded,
                          'Fall Detection',
                          'BNO085 IMU accelerometer',
                          Colors.orange,
                        ),
                        _functionTile(
                          Icons.cell_tower,
                          'Cellular Connection',
                          'Boron 404X LTE-M',
                          Colors.green,
                        ),
                        _functionTile(
                          Icons.battery_charging_full,
                          'Battery Monitor',
                          'LiPo fuel gauge',
                          Colors.amber,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Remove device button ──────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.link_off),
                      label: const Text(
                        'Remove Necklace',
                        style: TextStyle(fontSize: 16),
                      ),
                      onPressed: () => _confirmRemove(context),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────

  Widget _sectionCard(Color color, {required Widget child}) {
    return Card(
      color: color,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(padding: const EdgeInsets.all(16), child: child),
    );
  }

  Widget _activityRow({
    required Color dotColor,
    required String title,
    required String subtitle,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.circle, size: 12, color: dotColor),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 30 / 1.6,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                Text(subtitle, style: const TextStyle(fontSize: 22 / 1.6)),
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 8), trailing],
        ],
      ),
    );
  }

  String _timeFromTimestamp(int ts) {
    if (ts <= 0) return '--:--';
    final dt = DateTime.fromMillisecondsSinceEpoch(ts * 1000);
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute$period';
  }

  Widget _functionTile(
    IconData icon,
    String title,
    String subtitle,
    Color iconColor,
  ) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: iconColor.withOpacity(0.15),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.check_circle, color: Colors.green, size: 20),
    );
  }

  Future<void> _confirmRemove(BuildContext ctx) async {
    final confirmed = await showDialog<bool>(
      context: ctx,
      builder: (c) => AlertDialog(
        title: const Text('Remove Necklace'),
        content: const Text(
          'Are you sure you want to unpair this necklace? '
          'You will stop receiving alerts from it.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await Data.removeDevice(widget.deviceId);
      if (mounted) Navigator.pop(context);
    }
  }
}
