import 'package:safetynecklaceapp/initial.dart';
import 'package:safetynecklaceapp/screens/loginscreen.dart';
import 'package:safetynecklaceapp/screens/signupscreen.dart';
import 'package:safetynecklaceapp/screens/homescreen.dart';

var routes = {
  '/': (context) => InitialScreen(),
  '/login': (context) => LoginScreen(),
  '/signup': (context) => SignUpScreen(),
  '/home': (context) => HomeScreen(),
};
