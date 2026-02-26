import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:safetynecklaceapp/services/auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _login() async {
    FocusScope.of(context).unfocus();

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showMessage('Enter your email and password.');
      return;
    }

    setState(() => _isLoading = true);
    final user = await Auth().login(email, password);
    if (!mounted) return;

    setState(() => _isLoading = false);

    if (user != null) {
      Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
      return;
    }

    _showMessage('Login failed. Please check your credentials and try again.');
  }

  Future<void> _forgotPassword() async {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      _showMessage('Enter your email first to receive a reset link.');
      return;
    }

    final error = await Auth().sendPasswordResetEmail(email);
    if (!mounted) return;

    if (error == null) {
      _showMessage('Password reset email sent.');
    } else {
      _showMessage(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFFFFEFD2);

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'SafeNeck',
                  style: GoogleFonts.judson(
                    fontSize: 45,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _styledField(
                  controller: emailController,
                  labelText: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autocorrect: false,
                  enableSuggestions: false,
                ),
                _styledField(
                  controller: passwordController,
                  labelText: 'Password',
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) {
                    if (!_isLoading) _login();
                  },
                  autocorrect: false,
                  enableSuggestions: false,
                ),
                TextButton(
                  onPressed: _isLoading ? null : _forgotPassword,
                  child: const Text('Forgot Password?'),
                ),
                const SizedBox(height: 4),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF4BF5E),
                    textStyle: const TextStyle(
                      fontSize: 20,
                      color: Color(0xFF3A3A3A),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                  ),
                  onPressed: _isLoading ? null : _login,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Login'),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: _isLoading
                      ? null
                      : () => Navigator.pushNamed(context, '/signup'),
                  child: const Text('New Account? Sign Up.'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _styledField({
    required TextEditingController controller,
    required String labelText,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction? textInputAction,
    bool obscureText = false,
    bool autocorrect = true,
    bool enableSuggestions = true,
    ValueChanged<String>? onSubmitted,
  }) {
    return Padding(
      padding: const EdgeInsets.all(22.0),
      child: Container(
        decoration: ShapeDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFC8B283), Color(0xFFF9DDAA)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.2],
            tileMode: TileMode.clamp,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(7.0),
          ),
        ),
        child: TextField(
          controller: controller,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          obscureText: obscureText,
          autocorrect: autocorrect,
          enableSuggestions: enableSuggestions,
          onSubmitted: onSubmitted,
          decoration: InputDecoration(
            labelText: labelText,
            labelStyle: const TextStyle(color: Color(0xFFC8B283)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }
}
