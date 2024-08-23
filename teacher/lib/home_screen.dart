import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:teacher/profile_screen.dart';
import 'package:teacher/view_courses_screen.dart';
import 'package:teacher/view_requests_screen.dart';

import 'manage_requests_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _auth = FirebaseAuth.instance;
  int _selectedIndex = 0;

  static final List<Widget> _pages = <Widget>[
    ViewCoursesScreen(),
    ViewRequestsScreen(),
    ManageRequestsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _logout() async {
    await _auth.signOut();
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Text('Teacher Dashboard', style: TextStyle(fontWeight: FontWeight.bold,color:Colors.white)),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications,color: Colors.white,),
            onPressed: () {
              Navigator.pushNamed(context, '/send-notification');
            },
          ),
        ],
        elevation: 4,
      ),
      drawer: Drawer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                color: Colors.teal,
              ),
              accountName: Text(_auth.currentUser?.displayName ?? 'No Name',
                  style: TextStyle(color: Colors.white)),
              accountEmail: Text(_auth.currentUser?.email ?? 'No Email', style: TextStyle(color: Colors.white)),
              currentAccountPicture: CircleAvatar(
                backgroundImage: _auth.currentUser?.photoURL != null
                    ? NetworkImage(_auth.currentUser!.photoURL!)
                    : null,
                child: _auth.currentUser?.photoURL == null
                    ? Icon(Icons.person, size: 50, color: Colors.teal)
                    : null,
              ),
            ),
            ListTile(
              leading: Icon(Icons.person, color: Colors.teal),
              title: Text('Profile', style: TextStyle(color: Colors.teal)),
              onTap: () async {
                // Wait for the result when returning from the ProfilePage
                final updated = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(),
                  ),
                );

                // If name was updated, refresh the drawer
                if (updated == true) {
                  setState(() {});
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.teal),
              title: Text('Logout', style: TextStyle(color: Colors.teal)),
              onTap: _logout,
            ),
          ],
        ),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.view_list),
            label: 'View Courses',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.request_page),
            label: 'View Requests',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.manage_accounts),
            label: 'Manage Students',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey[600],
        showUnselectedLabels: true,
        onTap: _onItemTapped,
      ),
    );
  }
}
