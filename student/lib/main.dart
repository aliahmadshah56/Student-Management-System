import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'student_login_screen.dart';
import 'student_registration_screen.dart';
import 'student_home_screen.dart';
import 'student_view_courses_screen.dart';
import 'student_enrollment_form_screen.dart';
import 'student_enrollment_status_screen.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message: ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Student App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        cardTheme: CardTheme(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        buttonTheme: ButtonThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      initialRoute: '/student-login',
      routes: {
        '/student-login': (context) => StudentLoginScreen(),
        '/student-register': (context) => StudentRegistrationScreen(),
        '/student-home': (context) => StudentHomeScreen(),
        '/student-view-courses': (context) => StudentViewCoursesScreen(),
        '/student-enrollment-form': (context) => StudentEnrollmentFormScreen(courseId: ''), // Placeholder value
      },
    );
  }
}
