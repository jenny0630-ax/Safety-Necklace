import 'package:flutter/material.dart';
import 'package:safetynecklaceapp/initial.dart';
import 'package:safetynecklaceapp/screens/loginscreen.dart';
import 'package:safetynecklaceapp/screens/signupscreen.dart';
import 'package:safetynecklaceapp/screens/homescreen.dart';
import 'package:safetynecklaceapp/screens/Settingscreen.dart';
import 'package:safetynecklaceapp/screens/profilescreen.dart';
import 'package:safetynecklaceapp/screens/accountscreen.dart';
import 'package:safetynecklaceapp/screens/notificationsscreen.dart';

final Map<String, WidgetBuilder> routes = {
  '/': (context) => const InitialScreen(),
  '/login': (context) => const LoginScreen(),
  '/signup': (context) => const SignUpScreen(),
  '/home': (context) => const HomeScreen(),
  '/settings': (context) => const Settingscreen(),
  '/profile': (context) => const Profilescreen(),
  '/account': (context) => const Accountscreen(),
  '/notifications': (context) => const NotificationSettingsScreen(),
};
