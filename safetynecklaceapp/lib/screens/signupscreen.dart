import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:safetynecklaceapp/services/auth.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFEFD2),
      appBar: AppBar(backgroundColor: Color(0xFFFFEFD2)),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
                controller: confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
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
            padding: const EdgeInsets.fromLTRB(0, 50.0, 0, 65),
            child: ElevatedButton(
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
                Auth().signup(email, password).then((user) {
                  if (user != null) {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/',
                      (_) => false,
                    );
                  } else {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Sign Up Failed')));
                  }
                });
              },
              child: Text('Sign Up'),
            ),
          ),
        ],
      ),
    );
  }
}
