import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_database/firebase_database.dart';
import 'package:safetynecklaceapp/services/auth.dart';

/// Represents a single paired necklace device.
class NecklaceDevice {
  final String deviceId;
  final String name;
  final double lat;
  final double lon;
  final double battery;
  final bool gpsFix;
  final bool online;
  final int lastTimestamp; // epoch seconds

  NecklaceDevice({
    required this.deviceId,
    required this.name,
    this.lat = 0.0,
    this.lon = 0.0,
    this.battery = 0.0,
    this.gpsFix = false,
    this.online = false,
    this.lastTimestamp = 0,
  });

  factory NecklaceDevice.fromMap(String id, Map<dynamic, dynamic> map) {
    final loc = map['location'] as Map? ?? {};
    final int ts = (loc['ts'] as int?) ?? 0;
    // Consider "online" if last update was within 2 minutes
    final bool isOnline =
        DateTime.now().millisecondsSinceEpoch ~/ 1000 - ts < 120;

    return NecklaceDevice(
      deviceId: id,
      name: (map['name'] as String?) ?? id,
      lat: (loc['lat'] as num?)?.toDouble() ?? 0.0,
      lon: (loc['lon'] as num?)?.toDouble() ?? 0.0,
      battery: (loc['bat'] as num?)?.toDouble() ?? 0.0,
      gpsFix: (loc['fix'] as bool?) ?? false,
      online: isOnline,
      lastTimestamp: ts,
    );
  }
}

/// Represents a fall-detection or other alert from a device.
class DeviceAlert {
  final String alertId;
  final String deviceId;
  final String deviceName;
  final String type; // "fall", "location", etc.
  final double lat;
  final double lon;
  final int timestamp;
  final bool acknowledged;

  DeviceAlert({
    required this.alertId,
    required this.deviceId,
    required this.deviceName,
    required this.type,
    this.lat = 0.0,
    this.lon = 0.0,
    this.timestamp = 0,
    this.acknowledged = false,
  });

  factory DeviceAlert.fromMap(String id, Map<dynamic, dynamic> map) {
    return DeviceAlert(
      alertId: id,
      deviceId: (map['deviceId'] as String?) ?? '',
      deviceName: (map['deviceName'] as String?) ?? 'Unknown',
      type: (map['type'] as String?) ?? 'unknown',
      lat: (map['lat'] as num?)?.toDouble() ?? 0.0,
      lon: (map['lon'] as num?)?.toDouble() ?? 0.0,
      timestamp: (map['ts'] as int?) ?? 0,
      acknowledged: (map['ack'] as bool?) ?? false,
    );
  }
}

class Data {
  // ─── Profile helpers ──────────────────────────────────────────────

  static String fileToByteString(File file) {
    List<int> fileBytes = file.readAsBytesSync();
    String byteString = fileBytes.join(',');
    return byteString;
  }

  static File byteStringToFile(String byteString) {
    List<int> fileBytes = byteString.split(',').map(int.parse).toList();
    return File.fromRawPath(Uint8List.fromList(fileBytes));
  }

  static void saveProfileImage(File imageFile) {
    String byteString = fileToByteString(imageFile);
    String uid = Auth().currentUser!.uid;
    DatabaseReference ref = FirebaseDatabase.instance.ref(
      'users/$uid/profileImage',
    );
    ref.set(byteString);
  }

  static void saveProfileData({
    required String name,
    required String dob,
    required String mobile,
  }) {
    String uid = Auth().currentUser!.uid;
    DatabaseReference ref = FirebaseDatabase.instance.ref(
      'users/$uid/profileData',
    );
    ref.set({'name': name, 'dob': dob, 'mobile': mobile});
  }

  /// Fetch the current user's profile once.
  static Future<Map<String, dynamic>?> getProfileData() async {
    String uid = Auth().currentUser!.uid;
    DatabaseReference ref = FirebaseDatabase.instance.ref(
      'users/$uid/profileData',
    );
    final snapshot = await ref.get();
    if (snapshot.exists) {
      return Map<String, dynamic>.from(snapshot.value as Map);
    }
    return null;
  }

  // ─── Device / Necklace helpers ────────────────────────────────────

  /// Pair a new device to the current user.
  static Future<void> pairDevice(String deviceId, {String? name}) async {
    String uid = Auth().currentUser!.uid;
    DatabaseReference ref = FirebaseDatabase.instance.ref(
      'users/$uid/devices/$deviceId',
    );
    await ref.set({
      'name': name ?? deviceId,
      'pairedAt': ServerValue.timestamp,
    });
  }

  /// Remove a paired device.
  static Future<void> removeDevice(String deviceId) async {
    String uid = Auth().currentUser!.uid;
    DatabaseReference ref = FirebaseDatabase.instance.ref(
      'users/$uid/devices/$deviceId',
    );
    await ref.remove();
  }

  /// Stream the list of paired devices with their latest location data.
  static Stream<List<NecklaceDevice>> devicesStream() {
    String uid = Auth().currentUser!.uid;
    DatabaseReference ref = FirebaseDatabase.instance.ref('users/$uid/devices');
    return ref.onValue.map((event) {
      final data = event.snapshot.value as Map?;
      if (data == null) return <NecklaceDevice>[];
      return data.entries.map((e) {
        return NecklaceDevice.fromMap(
          e.key as String,
          Map<dynamic, dynamic>.from(e.value as Map),
        );
      }).toList();
    });
  }

  /// Get a single device's data once.
  static Future<NecklaceDevice?> getDevice(String deviceId) async {
    String uid = Auth().currentUser!.uid;
    DatabaseReference ref = FirebaseDatabase.instance.ref(
      'users/$uid/devices/$deviceId',
    );
    final snapshot = await ref.get();
    if (snapshot.exists) {
      return NecklaceDevice.fromMap(
        deviceId,
        Map<dynamic, dynamic>.from(snapshot.value as Map),
      );
    }
    return null;
  }

  /// Stream location updates for a specific device.
  static Stream<NecklaceDevice?> deviceLocationStream(String deviceId) {
    String uid = Auth().currentUser!.uid;
    DatabaseReference ref = FirebaseDatabase.instance.ref(
      'users/$uid/devices/$deviceId',
    );
    return ref.onValue.map((event) {
      final data = event.snapshot.value as Map?;
      if (data == null) return null;
      return NecklaceDevice.fromMap(deviceId, Map<dynamic, dynamic>.from(data));
    });
  }

  // ─── Alerts / Notifications ───────────────────────────────────────

  /// Stream alerts for the current user (newest first).
  static Stream<List<DeviceAlert>> alertsStream() {
    String uid = Auth().currentUser!.uid;
    DatabaseReference ref = FirebaseDatabase.instance.ref('users/$uid/alerts');
    return ref.orderByChild('ts').onValue.map((event) {
      final data = event.snapshot.value as Map?;
      if (data == null) return <DeviceAlert>[];
      final list = data.entries
          .map(
            (e) => DeviceAlert.fromMap(
              e.key as String,
              Map<dynamic, dynamic>.from(e.value as Map),
            ),
          )
          .toList();
      list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return list;
    });
  }

  /// Acknowledge (dismiss) an alert.
  static Future<void> acknowledgeAlert(String alertId) async {
    String uid = Auth().currentUser!.uid;
    DatabaseReference ref = FirebaseDatabase.instance.ref(
      'users/$uid/alerts/$alertId/ack',
    );
    await ref.set(true);
  }

  // ─── Notification preferences ─────────────────────────────────────

  static Future<void> saveNotificationPrefs({
    required bool sound,
    required bool vibration,
  }) async {
    String uid = Auth().currentUser!.uid;
    DatabaseReference ref = FirebaseDatabase.instance.ref(
      'users/$uid/notificationPrefs',
    );
    await ref.set({'sound': sound, 'vibration': vibration});
  }

  static Future<Map<String, bool>> getNotificationPrefs() async {
    String uid = Auth().currentUser!.uid;
    DatabaseReference ref = FirebaseDatabase.instance.ref(
      'users/$uid/notificationPrefs',
    );
    final snapshot = await ref.get();
    if (snapshot.exists) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      return {
        'sound': data['sound'] as bool? ?? true,
        'vibration': data['vibration'] as bool? ?? false,
      };
    }
    return {'sound': true, 'vibration': false};
  }

  // ─── Account deletion ─────────────────────────────────────────────

  /// Delete all user data from the database.
  static Future<void> deleteAllUserData() async {
    String uid = Auth().currentUser!.uid;
    DatabaseReference ref = FirebaseDatabase.instance.ref('users/$uid');
    await ref.remove();
  }
}
