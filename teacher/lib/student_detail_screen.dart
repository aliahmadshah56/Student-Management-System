import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'course_detail_screen.dart';

class StudentDetailScreen extends StatefulWidget {
  final Map<String, dynamic> request;

  StudentDetailScreen({required this.request});

  @override
  _StudentDetailScreenState createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends State<StudentDetailScreen> {
  late Map<String, dynamic> courseDetails;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCourseDetails();
  }

  Future<void> _fetchCourseDetails() async {
    final courseId = widget.request['course_id'];

    try {
      final courseSnapshot = await FirebaseFirestore.instance
          .collection('courses')
          .doc(courseId)
          .get();

      if (courseSnapshot.exists) {
        final courseData = courseSnapshot.data() as Map<String, dynamic>? ?? {};

        setState(() {
          courseDetails = {
            'name': courseData['name'] ?? 'Unknown Course',
            'description': courseData['description'] ?? 'No description',
            'course_id': courseId,
          };
          isLoading = false;
        });
      } else {
        setState(() {
          courseDetails = {
            'name': 'Unknown Course',
            'description': 'No description',
            'course_id': courseId,
          };
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching course details: $e');
      setState(() {
        courseDetails = {
          'name': 'Unknown Course',
          'description': 'No description',
          'course_id': widget.request['course_id'],
        };
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final studentName = widget.request['student_name'] ?? 'Unknown';
    final studentMobile = widget.request['student_mobile'] ?? 'No mobile number';
    final fatherName = widget.request['father_name'] ?? 'No father name';
    final fatherMobile = widget.request['father_mobile'] ?? 'No father mobile';
    final timestamp = widget.request['timestamp']?.toDate();
    final courseName = widget.request['course_name'] ?? 'Unknown Course';
    final studentId = widget.request['student_id'] ?? 'No ID'; // Retrieve student ID

    return Scaffold(
      appBar: AppBar(
        title: Text('Student Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Student ID', studentId), // Display student ID
            _buildDetailRow('Name', studentName),
            _buildDetailRow('Mobile', studentMobile),
            _buildDetailRow('Father\'s Name', fatherName),
            _buildDetailRow('Father\'s Mobile', fatherMobile),
            _buildDetailRow('Course', courseName),
            if (timestamp != null) _buildDetailRow('Requested on', _formatDate(timestamp)),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CourseDetailScreen(
                      studentId: studentId,
                      courseId: widget.request['course_id'], // Pass the course ID
                    ),
                  ),
                );
              },
              child: Text('View Course Topics'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text('$label:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
          Expanded(child: Text(value, style: TextStyle(fontSize: 16))),
        ],
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.toLocal().toIso8601String()}'; // Format date as needed
  }
}
