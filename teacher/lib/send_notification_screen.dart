import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Function to send notification
Future<void> sendNotification(String title, String body) async {
  const String serverKey = 'YOUR_SERVER_KEY'; // Replace with your server key
  const String fcmUrl = 'https://fcm.googleapis.com/fcm/send';

  final response = await http.post(
    Uri.parse(fcmUrl),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'key=$serverKey',
    },
    body: jsonEncode({
      'notification': {
        'title': title,
        'body': body,
      },
      'priority': 'high',
      'to': '/topics/students', // Topic or specific device token
    }),
  );

  if (response.statusCode == 200) {
    print('Notification sent successfully!');
  } else {
    print('Failed to send notification: ${response.body}');
  }
}

class SendNotificationScreen extends StatefulWidget {
  @override
  _SendNotificationScreenState createState() => _SendNotificationScreenState();
}

class _SendNotificationScreenState extends State<SendNotificationScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();

  void _sendNotification() async {
    final title = _titleController.text;
    final body = _bodyController.text;

    if (title.isNotEmpty && body.isNotEmpty) {
      await sendNotification(title, body); // Call the function correctly
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Notification sent!')),
      );
      _titleController.clear();
      _bodyController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter title and body.')),
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
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Notification Title'),
            ),
            TextField(
              controller: _bodyController,
              decoration: InputDecoration(labelText: 'Notification Body'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _sendNotification,
              child: Text('Send Notification'),
            ),
          ],
        ),
      ),
    );
  }
}
