import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'student_login_screen.dart';
import 'student_home_screen.dart';
import 'student_registration_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Student App',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: AuthCheck(),
      routes: {
        '/student-login': (context) => StudentLoginScreen(),
        '/student-register': (context) => StudentRegistrationScreen(),
        '/student-home': (context) => StudentHomeScreen(),
      },
    );
  }
}

class AuthCheck extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // Show a loading indicator
        } else if (snapshot.hasData) {
          return StudentHomeScreen(); // User is signed in, go to the home screen
        } else {
          return StudentLoginScreen(); // User is not signed in, show the login screen
        }
      },
    );
  }
}
