import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:safetynecklaceapp/services/auth.dart';
import 'package:safetynecklaceapp/screens/homescreen.dart';
import 'package:safetynecklaceapp/screens/loginscreen.dart';

class InitialScreen extends StatefulWidget {
  const InitialScreen({super.key});

  @override
  State<InitialScreen> createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen> {
  @override
  Widget build(BuildContext context) {
    User? user = Auth().currentUser;

    if (user != null) {
      return HomeScreen();
    } else {
      return LoginScreen();
    }
  }
}
