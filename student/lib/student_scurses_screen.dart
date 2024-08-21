import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'course_detail_screen.dart'; // Ensure this import is correct

class StudentCoursesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // Handle the case where the user is not logged in
      return Scaffold(
        appBar: AppBar(
          title: Text('My Courses'),
          backgroundColor: Colors.teal,
          elevation: 0,
        ),
        body: Center(
          child: Text('Please log in to view your courses.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('My Courses'),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('requests')
            .where('student_id', isEqualTo: user.uid)
            .where('status', isEqualTo: 'accepted')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No enrolled courses'));
          }

          final requests = snapshot.data!.docs;
          return ListView.separated(
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            itemCount: requests.length,
            separatorBuilder: (context, index) => SizedBox(height: 10),
            itemBuilder: (context, index) {
              final request = requests[index];
              final courseId = request['course_id'];
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('courses').doc(courseId).get(),
                builder: (context, courseSnapshot) {
                  if (courseSnapshot.connectionState == ConnectionState.waiting) {
                    return ShimmerEffect(); // Placeholder while loading
                  }

                  if (courseSnapshot.hasError || !courseSnapshot.hasData) {
                    return Card(
                      child: ListTile(
                        title: Text('Error fetching course'),
                      ),
                    );
                  }

                  final courseData = courseSnapshot.data!;
                  return Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(16),
                      title: Text(
                        courseData['name'] ?? 'No course name',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('Tap to view details', style: TextStyle(color: Colors.grey[600])),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CourseDetailScreen(
                              courseId: courseId,
                              studentId: user.uid, // Pass the actual student ID here
                            ),
                          ),
                        );
                      },
                      tileColor: Colors.grey[50],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class ShimmerEffect extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        title: Container(
          height: 20,
          width: double.infinity,
          color: Colors.grey[300],
        ),
        subtitle: Container(
          height: 14,
          width: double.infinity,
          color: Colors.grey[300],
        ),
      ),
    );
  }
}
