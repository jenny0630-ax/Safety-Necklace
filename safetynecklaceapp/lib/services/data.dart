import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_database/firebase_database.dart';
import 'package:safetynecklaceapp/services/auth.dart';

class Data {
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
    // required String email,
  }) {
    String uid = Auth().currentUser!.uid;
    DatabaseReference ref = FirebaseDatabase.instance.ref(
      'users/$uid/profileData',
    );
    ref.set({
      'name': name,
      'dob': dob,
      'mobile': mobile,
      // 'email': email
    });
  }
}
