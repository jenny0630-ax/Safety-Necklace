import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:safetynecklaceapp/services/data.dart';

/// Full-screen map that streams the real-time location of a single
/// paired necklace device.
class MapScreen extends StatefulWidget {
  final String deviceId;
  const MapScreen({super.key, required this.deviceId});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const Color _cream = Color(0xFFFFEFD2);
  static const Color _cardGold = Color(0xFFF4BF5E);
  static const String _tileTemplate =
      'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png';

  final MapController _mapController = MapController();
  StreamSubscription? _sub;
  NecklaceDevice? _device;
  bool _centeredOnce = false;

  @override
  void initState() {
    super.initState();
    _sub = Data.deviceLocationStream(widget.deviceId).listen((dev) {
      if (!mounted) return;
      setState(() => _device = dev);
      if (dev != null && dev.lat != 0.0 && !_centeredOnce) {
        _centeredOnce = true;
        _mapController.move(LatLng(dev.lat, dev.lon), 15.0);
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final LatLng center = _device != null && _device!.lat != 0.0
        ? LatLng(_device!.lat, _device!.lon)
        : const LatLng(33.6846, -117.7957); // default fallback

    return Scaffold(
      backgroundColor: _cream,
      appBar: AppBar(
        backgroundColor: _cream,
        title: Text(_device?.name ?? 'Map'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(initialCenter: center, initialZoom: 15.0),
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
                      TextSourceAttribution('© OpenStreetMap contributors'),
                      TextSourceAttribution('© CARTO'),
                    ],
                  ),
                  if (_device != null && _device!.lat != 0.0)
                    MarkerLayer(
                      markers: [
                        Marker(
                          width: 50,
                          height: 50,
                          point: LatLng(_device!.lat, _device!.lon),
                          child: Icon(
                            Icons.location_on,
                            color: _device!.online ? Colors.red : Colors.grey,
                            size: 36,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),

          // ── Info chip at bottom ───────────────────────────────────
          if (_device != null)
            Positioned(
              bottom: 24,
              left: 16,
              right: 16,
              child: Card(
                color: const Color(0xFFF9DDAA),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 8,
                        backgroundColor: _device!.online
                            ? Colors.green
                            : Colors.grey,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _device!.online ? 'Online' : 'Offline',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Text(
                        '${_device!.lat.toStringAsFixed(5)}, '
                        '${_device!.lon.toStringAsFixed(5)}',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      // ── Re-center FAB ──────────────────────────────────────────
      floatingActionButton: FloatingActionButton.small(
        backgroundColor: _cardGold,
        onPressed: () {
          if (_device != null && _device!.lat != 0.0) {
            _mapController.move(LatLng(_device!.lat, _device!.lon), 15.0);
          }
        },
        child: const Icon(Icons.my_location, color: Colors.black87),
      ),
    );
  }
}
