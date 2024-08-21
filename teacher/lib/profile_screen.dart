import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatelessWidget {
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
              child: user?.photoURL == null ? Icon(Icons.person, size: 50, color: Colors.teal) : null,
            ),
            SizedBox(height: 10),
            Text('Name: ${user?.displayName ?? 'No Name'}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Email: ${user?.email ?? 'No Email'}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _showEditNameDialog(context);
              },
              child: Text('Edit ',style: TextStyle(color: Colors.white),),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditNameDialog(BuildContext context) {
    String newName = user?.displayName ?? '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Name',),
          content: TextField(
            onChanged: (value) {
              newName = value;
            },
            controller: TextEditingController(text: newName),
            decoration: InputDecoration(labelText: 'Enter new name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (newName.isNotEmpty) {
                  await user?.updateDisplayName(newName);
                  await user?.reload();
                  Navigator.of(context).pop();
                  // Rebuild the ProfilePage to show the updated name
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => ProfilePage()),
                  );
                }
              },
              child: Text('Save'),

            ),
          ],
        );
      },
    );
  }
}
