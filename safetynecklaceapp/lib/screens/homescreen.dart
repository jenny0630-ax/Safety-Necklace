import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:safetynecklaceapp/services/auth.dart';
import 'package:safetynecklaceapp/size_config.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const LatLng _center = LatLng(33.6846, -117.7957);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const cream = Color(0xFFFFEFD2);
    const softcream = Color(0xFFF9DDAA);
    const cardGold = Color(0xFFF4BF5E);

    return Scaffold(
      backgroundColor: cream,
      appBar: AppBar(backgroundColor: cream),
      body: Center(
        child: Column(
          children: [
            SizedBox(
              width: SizeConfig.horizontal! * 90,
              height: SizeConfig.horizontal! * 90,
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: _center,
                      initialZoom: 13.0,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                      ),
                      // MarkerLayer(
                      //   markers: [
                      //     Marker(
                      //       width: 80.0,
                      //       height: 80.0,
                      //       point: _center,
                      //       builder: (ctx) => const Icon(
                      //         Icons.location_on,
                      //         color: Colors.red,
                      //         size: 40,
                      //       ),
                      //     ),
                      //   ],
                      // ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              width: SizeConfig.horizontal! * 90,
              height: SizeConfig.vertical! * 40,
              child: Card(
                color: softcream,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView(
                    children: [
                      SizedBox(
                        height: SizeConfig.vertical! * 8,
                        width: SizeConfig.horizontal! * 80,
                        child: Card(
                          color: cardGold,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Text(
                              'Test',
                              style: theme.textTheme.headlineSmall,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            ListTile(title: Text('About Device'), onTap: () {}),
            ListTile(title: Text('Settings'), onTap: () {}),
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
