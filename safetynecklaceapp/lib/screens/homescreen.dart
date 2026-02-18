import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:safetynecklaceapp/services/auth.dart';
import 'package:safetynecklaceapp/services/data.dart';
import 'package:safetynecklaceapp/screens/devicescreen.dart';
import 'package:safetynecklaceapp/screens/mapscreen.dart';
import 'package:safetynecklaceapp/size_config.dart';
import 'package:timeago/timeago.dart' as timeago;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const LatLng _defaultCenter = LatLng(33.6846, -117.7957);
  static const String _tileTemplate =
      'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png';

  List<NecklaceDevice> _devices = [];
  List<DeviceAlert> _alerts = [];
  StreamSubscription? _deviceSub;
  StreamSubscription? _alertSub;

  @override
  void initState() {
    super.initState();
    _deviceSub = Data.devicesStream().listen((devs) {
      if (mounted) setState(() => _devices = devs);
    });
    _alertSub = Data.alertsStream().listen((alerts) {
      if (mounted) setState(() => _alerts = alerts);
    });
  }

  @override
  void dispose() {
    _deviceSub?.cancel();
    _alertSub?.cancel();
    super.dispose();
  }

  LatLng get _mapCenter {
    if (_devices.isNotEmpty && _devices.first.lat != 0.0) {
      return LatLng(_devices.first.lat, _devices.first.lon);
    }
    return _defaultCenter;
  }

  @override
  Widget build(BuildContext context) {
    const cream = Color(0xFFFFEFD2);
    const softcream = Color(0xFFF9DDAA);
    const cardGold = Color(0xFFF4BF5E);

    return Scaffold(
      backgroundColor: cream,
      appBar: AppBar(
        backgroundColor: cream,
        title: const Text('SafeNeck'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          children: [
            // ── Map preview ────────────────────────────────────────
            GestureDetector(
              onTap: () {
                if (_devices.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          MapScreen(deviceId: _devices.first.deviceId),
                    ),
                  );
                }
              },
              child: SizedBox(
                width: SizeConfig.horizontal! * 90,
                height: SizeConfig.horizontal! * 48,
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: AbsorbPointer(
                      child: FlutterMap(
                        options: MapOptions(
                          initialCenter: _mapCenter,
                          initialZoom: 13.0,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: _tileTemplate,
                            subdomains: const ['a', 'b', 'c', 'd'],
                            userAgentPackageName:
                                'com.safetynecklace.safetynecklaceapp',
                            maxZoom: 20,
                          ),
                          RichAttributionWidget(
                            attributions: const [
                              TextSourceAttribution(
                                '© OpenStreetMap contributors',
                              ),
                              TextSourceAttribution('© CARTO'),
                            ],
                          ),
                          MarkerLayer(
                            markers: _devices
                                .where((d) => d.lat != 0.0)
                                .map(
                                  (d) => Marker(
                                    width: 40,
                                    height: 40,
                                    point: LatLng(d.lat, d.lon),
                                    child: Icon(
                                      Icons.location_on,
                                      color: d.online
                                          ? Colors.red
                                          : Colors.grey,
                                      size: 36,
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ── Alerts & device list ───────────────────────────────
            Expanded(
              child: SizedBox(
                width: SizeConfig.horizontal! * 90,
                child: Card(
                  color: softcream,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ListView(
                      children: [
                        // Device cards
                        ..._devices.map((d) => _deviceCard(d, cardGold)),
                        // Alert cards
                        ..._alerts
                            .where((a) => !a.acknowledged)
                            .take(10)
                            .map((a) => _alertCard(a, cardGold)),
                        if (_devices.isEmpty && _alerts.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(32),
                            child: Center(
                              child: Text(
                                'No paired necklaces yet.\nTap + to pair one.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      // ── Pair-device FAB ──────────────────────────────────────────
      floatingActionButton: FloatingActionButton(
        backgroundColor: cardGold,
        onPressed: () => _showPairDialog(context),
        child: const Icon(Icons.add, color: Colors.black87),
      ),

      // ── Drawer ───────────────────────────────────────────────────
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFFF4BF5E)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Icon(
                    Icons.diamond_outlined,
                    size: 48,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    Auth().currentUser?.email ?? '',
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/settings');
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

  // ── Device card ──────────────────────────────────────────────────
  Widget _deviceCard(NecklaceDevice d, Color cardGold) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SizedBox(
        height: SizeConfig.vertical! * 8,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DeviceScreen(deviceId: d.deviceId),
              ),
            );
          },
          child: Card(
            color: cardGold,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 8,
                    backgroundColor: d.online ? Colors.green : Colors.grey,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      d.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Text(
                    '${d.battery.toStringAsFixed(0)}%',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.battery_std,
                    size: 18,
                    color: d.battery > 20 ? Colors.green : Colors.red,
                  ),
                  const Icon(Icons.chevron_right, size: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Alert card ───────────────────────────────────────────────────
  Widget _alertCard(DeviceAlert a, Color cardGold) {
    final bool isFall = a.type == 'fall';
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SizedBox(
        height: SizeConfig.vertical! * 8,
        child: Card(
          color: cardGold,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                child: Icon(
                  isFall ? Icons.warning_rounded : Icons.info_outline,
                  size: SizeConfig.horizontal! * 8,
                  color: isFall
                      ? const Color.fromARGB(255, 228, 28, 28)
                      : Colors.blue,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isFall ? 'Fall Detected!' : a.type,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(a.deviceName, style: const TextStyle(fontSize: 13)),
                  ],
                ),
              ),
              Text(
                a.timestamp > 0
                    ? timeago.format(
                        DateTime.fromMillisecondsSinceEpoch(a.timestamp * 1000),
                      )
                    : '',
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: () => Data.acknowledgeAlert(a.alertId),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Pair device dialog ───────────────────────────────────────────
  Future<void> _showPairDialog(BuildContext ctx) async {
    final idController = TextEditingController();
    final nameController = TextEditingController();

    await showDialog(
      context: ctx,
      builder: (c) => AlertDialog(
        title: const Text('Pair a Necklace'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: idController,
              decoration: const InputDecoration(
                labelText: 'Device ID',
                hintText: 'e.g. e00fce68...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name (optional)',
                hintText: 'e.g. Jenny\'s Necklace',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF4BF5E),
            ),
            onPressed: () {
              final id = idController.text.trim();
              if (id.isNotEmpty) {
                final name = nameController.text.trim();
                Data.pairDevice(id, name: name.isEmpty ? null : name);
                Navigator.pop(c);
              }
            },
            child: const Text('Pair'),
          ),
        ],
      ),
    );
  }
}
