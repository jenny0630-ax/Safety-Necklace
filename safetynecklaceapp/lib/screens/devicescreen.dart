import 'dart:async';
import 'package:flutter/material.dart';
import 'package:safetynecklaceapp/services/data.dart';
import 'package:safetynecklaceapp/size_config.dart';
import 'package:timeago/timeago.dart' as timeago;

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
    const cardGold = Color(0xFFF4BF5E);

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
                    child: Row(
                      children: [
                        Icon(
                          _batteryIcon(device.battery),
                          size: 48,
                          color: _batteryColor(device.battery),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Battery',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                              Text(
                                '${device.battery.toStringAsFixed(0)}%',
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Battery bar
                        SizedBox(
                          width: SizeConfig.horizontal! * 30,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: device.battery / 100,
                              minHeight: 14,
                              backgroundColor: Colors.black12,
                              valueColor: AlwaysStoppedAnimation(
                                _batteryColor(device.battery),
                              ),
                            ),
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
                        _statusRow(
                          'Status',
                          device.online ? 'Online' : 'Offline',
                          trailing: CircleAvatar(
                            radius: 8,
                            backgroundColor: device.online
                                ? Colors.green
                                : Colors.grey,
                          ),
                        ),
                        const Divider(),
                        _statusRow(
                          'GPS Fix',
                          device.gpsFix ? 'Active' : 'No Fix',
                          trailing: Icon(
                            device.gpsFix
                                ? Icons.gps_fixed
                                : Icons.gps_not_fixed,
                            color: device.gpsFix ? Colors.green : Colors.red,
                          ),
                        ),
                        const Divider(),
                        _statusRow(
                          'Last Update',
                          device.lastTimestamp > 0
                              ? timeago.format(
                                  DateTime.fromMillisecondsSinceEpoch(
                                    device.lastTimestamp * 1000,
                                  ),
                                )
                              : 'Never',
                          trailing: const Icon(
                            Icons.access_time,
                            color: Colors.black54,
                          ),
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

  Widget _statusRow(String label, String value, {Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 16))),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          if (trailing != null) ...[const SizedBox(width: 8), trailing],
        ],
      ),
    );
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
