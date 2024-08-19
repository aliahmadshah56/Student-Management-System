import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'student_enrollment_form_screen.dart';

class StudentViewCoursesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Available Courses'),
        backgroundColor: Colors.teal,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('courses').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No courses available'));
          }

          final courses = snapshot.data!.docs;
          return ListView(
            padding: EdgeInsets.all(8.0),
            children: courses.map((course) {
              final courseName = course['name'] ?? 'No Name';
              final courseId = course.id;

              return StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('requests')
                    .doc('${user?.uid}_$courseId')
                    .snapshots(),
                builder: (context, requestSnapshot) {
                  if (requestSnapshot.connectionState == ConnectionState.waiting) {
                    return ShimmerEffect();
                  }

                  if (requestSnapshot.hasError) {
                    return Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        title: Text(courseName),
                        trailing: Text('Error fetching status'),
                      ),
                    );
                  }

                  final requestData = requestSnapshot.data?.data() as Map<String, dynamic>?;
                  final status = requestData?['status'] as String?;

                  return Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    color: _getCardColor(status),
                    child: ListTile(
                      title: Text(courseName),
                      trailing: _buildTrailingWidget(context, status, user, courseId),
                      subtitle: Text('Status: ${status ?? 'N/A'}', style: TextStyle(color: Colors.grey[600])),
                    ),
                  );
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Color _getCardColor(String? status) {
    if (status == 'accepted') {
      return Colors.green.shade100;
    } else if (status == 'rejected') {
      return Colors.red.shade100;
    } else if (status == 'pending') {
      return Colors.yellow.shade100;
    } else {
      return Colors.white; // Color for 'N/A'
    }
  }

  Widget _buildTrailingWidget(BuildContext context, String? status, User? user, String courseId) {
    if (status == 'accepted' ) {
      return Text(status == 'accepted' ? 'Enrolled' : 'Rejected');
    } else if (status == 'pending') {
      return Text('Pending');
    } else {
      return ElevatedButton(
        onPressed: () async {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StudentEnrollmentFormScreen(courseId: courseId),
            ),
          );
        },
        child: Text('Enroll'),
      );
    }
  }
}

class ShimmerEffect extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        contentPadding: EdgeInsets.all(16.0),
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
