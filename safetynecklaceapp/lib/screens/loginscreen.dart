import 'package:flutter/material.dart';
import 'package:safetynecklaceapp/services/auth.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFEFD2),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(),
          Column(
            children: [
              Text(
                "App Name",
                style: GoogleFonts.judson(
                  fontSize: 45,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(22.0),
                child: Container(
                  decoration: ShapeDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFC8B283), Color(0xFFF9DDAA)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: [0.0, 0.2],
                      tileMode: TileMode.clamp,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(7.0)),
                    ),
                  ),
                  child: TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(color: Color(0xFFC8B283)),
                      // fillColor: Color(0xFFF9DDAA),
                      // filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(22.0),
                child: Container(
                  decoration: ShapeDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFC8B283), Color(0xFFF9DDAA)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: [0.0, 0.2],
                      tileMode: TileMode.clamp,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(7.0)),
                    ),
                  ),
                  child: TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(color: Color(0xFFC8B283)),
                      // fillColor: Color(0xFFF9DDAA),
                      // filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),
              TextButton(child: Text("Forgot Password?"), onPressed: () {}),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFF4BF5E),
                  textStyle: TextStyle(fontSize: 20, color: Color(0xFF3A3A3A)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                ),
                onPressed: () {
                  // Handle login logic here
                  String email = emailController.text.trim();
                  String password = passwordController.text.trim();
                  Auth().login(email, password);
                },
                child: Text('Login'),
              ),
            ],
          ),
          TextButton(
            onPressed: () {
              // Navigate to registration screen
              Navigator.pushNamed(context, "/signup");
            },
            child: Text('New Account? Sign Up.'),
          ),
        ],
      ),
    );
  }
}
