import 'package:safetynecklaceapp/initial.dart';
import 'package:safetynecklaceapp/screens/loginscreen.dart';
import 'package:safetynecklaceapp/screens/signupscreen.dart';
import 'package:safetynecklaceapp/screens/homescreen.dart';
import 'package:safetynecklaceapp/screens/Settingscreen.dart';
import 'package:safetynecklaceapp/screens/profilescreen.dart';
import 'package:safetynecklaceapp/screens/accountscreen.dart';

var routes = {
  '/': (context) => InitialScreen(),
  '/login': (context) => LoginScreen(),
  '/signup': (context) => SignUpScreen(),
  '/home': (context) => HomeScreen(),
  '/settings': (context) => Settingscreen(),
  '/profile': (context) => Profilescreen(),
  '/account': (context) => Accountscreen(),
};
