import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_course_screen.dart'; // Import the AddCourseScreen
import 'edit_course_screen.dart';

class ViewCoursesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Courses'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddCourseScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: CoursesList(),
    );
  }
}

class CoursesList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('courses').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No courses available.'));
        }

        final courses = snapshot.data!.docs;
        List<Widget> courseWidgets = [];

        for (var course in courses) {
          final courseName = course['name'];
          final courseId = course.id;
          final courseWidget = Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              title: Text(courseName),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditCourseScreen(
                      courseId: courseId,
                      courseName: courseName,
                    ),
                  ),
                );
              },
            ),
          );
          courseWidgets.add(courseWidget);
        }

        return ListView(
          padding: EdgeInsets.all(8.0),
          children: courseWidgets,
        );
      },
    );
  }
}
