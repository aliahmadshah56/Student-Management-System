import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationsPage extends StatefulWidget {
  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  void initState() {
    super.initState();

    // Request notification permissions (for iOS)
    FirebaseMessaging.instance.requestPermission();

    // Listen to incoming messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received a message: ${message.notification?.title}, ${message.notification?.body}');
      // Handle the notification here, e.g., show a dialog or update UI
    });

    // Subscribe to the topic
    FirebaseMessaging.instance.subscribeToTopic('students').then((_) {
      print('Subscribed to students topic');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
        backgroundColor: Colors.teal,
      ),
      body: Center(
        child: Text('Waiting for notifications...'),
      ),
    );
  }
}
