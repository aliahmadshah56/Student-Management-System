import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class SendNotificationScreen extends StatefulWidget {
  @override
  _SendNotificationScreenState createState() => _SendNotificationScreenState();
}

class _SendNotificationScreenState extends State<SendNotificationScreen> {
  final TextEditingController _notificationTitleController =
  TextEditingController();
  final TextEditingController _notificationBodyController =
  TextEditingController();

  void _subscribeToTopic() async {
    String title = _notificationTitleController.text;
    String body = _notificationBodyController.text;

    if (title.isNotEmpty && body.isNotEmpty) {
      await FirebaseMessaging.instance.subscribeToTopic('students');

      _notificationTitleController.clear();
      _notificationBodyController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Subscribed to topic and notification sent successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Send Notification'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _notificationTitleController,
                  decoration: InputDecoration(
                    labelText: 'Notification Title',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _notificationBodyController,
                  decoration: InputDecoration(
                    labelText: 'Notification Body',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _subscribeToTopic,
                  child: Text('Send Notification'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
