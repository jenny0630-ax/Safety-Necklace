import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safetynecklaceapp/screens/loginscreen.dart';

void main() {
  testWidgets('Login screen renders core actions', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    expect(find.text('SafeNeck'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Forgot Password?'), findsOneWidget);
    expect(find.text('New Account? Sign Up.'), findsOneWidget);
  });
}
