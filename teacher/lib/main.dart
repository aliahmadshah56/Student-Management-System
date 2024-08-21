import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:teacher/registration_screen.dart';
import 'package:teacher/send_notification_screen.dart';
import 'package:teacher/view_requests_screen.dart';
import 'add_course_screen.dart';
import 'add_topic_screen.dart';
import 'edit_course_screen.dart';
import 'edit_topic_screen.dart';
import 'home_screen.dart';
import 'login_screen.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message: ${message.messageId}');
}

void main() async {
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
      title: 'Teacher App',
      theme: _buildAppTheme(),
      home: _buildHomeScreen(),
      routes: _buildAppRoutes(),
    );
  }

  ThemeData _buildAppTheme() {
    return ThemeData(
      primarySwatch: Colors.blue,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      cardTheme: CardTheme(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        hintStyle: TextStyle(color: Colors.grey[600]),
      ),
      buttonTheme: ButtonThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        buttonColor: Colors.blue,
        textTheme: ButtonTextTheme.primary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          textStyle: TextStyle(fontSize: 16),
        ),
      ),
      textTheme: TextTheme(
        headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        bodyMedium: TextStyle(fontSize: 16),
      ),
    );
  }

  Widget _buildHomeScreen() {
    // Check if user is logged in
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // If the user is logged in, show the HomeScreen
        if (snapshot.hasData && snapshot.data != null) {
          return HomeScreen();
        }
        // If the user is not logged in, show the LoginScreen
        else {
          return LoginScreen();
        }
      },
    );
  }

  Map<String, WidgetBuilder> _buildAppRoutes() {
    return {
      '/register': (context) => RegistrationScreen(),
      '/home': (context) => HomeScreen(),
      '/add-course': (context) => AddCourseScreen(),
      '/edit-course': (context) => EditCourseScreen(courseId: '', courseName: ''),
      '/add-topic': (context) => AddTopicScreen(courseId: ''),
      '/edit-topic': (context) => EditTopicScreen(
        courseId: '',
        topicId: '',
        topicName: '',
        topicDescription: '',
        topicDocumentationUrl: '',
        topicVideoUrl: '',
      ),
      '/view-requests': (context) => ViewRequestsScreen(),
      '/send-notification': (context) => SendNotificationScreen(),
    };
  }
}
