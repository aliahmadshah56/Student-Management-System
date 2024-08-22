import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:teacher/progress_screen.dart';

class CourseDetailScreen extends StatefulWidget {
  final String studentId;
  final String courseId;

  CourseDetailScreen({required this.studentId, required this.courseId});

  @override
  _CourseDetailScreenState createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  List<String> showTopics = [];
  List<Map<String, dynamic>> topics = [];
  bool isLoading = true;
  int totalTopics = 0;
  int completedTopics = 0;
  int pendingTopics = 0;
  List<String> completedTopicList = [];

  @override
  void initState() {
    super.initState();
    fetchStudentDetails(); // Fetch student details and topics
  }

  Future<void> fetchStudentDetails() async {
    try {
      final studentRef = FirebaseFirestore.instance.collection('students').doc(widget.studentId);
      final studentSnapshot = await studentRef.get();

      if (!studentSnapshot.exists) {
        await studentRef.set({
          'name': 'Unknown',
          'showTopics': [],
        });
      }

      final studentData = studentSnapshot.data();
      if (studentData != null) {
        setState(() {
          showTopics = List<String>.from(studentData['showTopics'] ?? []);
        });
      }

      fetchCourseTopics(); // Fetch course topics after fetching student details
      fetchProgressData(); // Fetch progress data for the student
    } catch (e) {
      print("Error fetching student details: $e");
    }
  }

  Future<void> fetchCourseTopics() async {
    try {
      final courseSnapshot = await FirebaseFirestore.instance
          .collection('courses')
          .doc(widget.courseId)
          .collection('topics')
          .get();

      setState(() {
        topics = courseSnapshot.docs.map((doc) => {
          'id': doc.id,
          'name': doc.data()['name'] ?? 'Unknown', // Handle missing 'name' field
        }).toList();
        totalTopics = topics.length;
      });
    } catch (e) {
      print("Error fetching course topics: $e");
    } finally {
      setState(() {
        isLoading = false; // Stop loading once data is fetched
      });
    }
  }

  Future<void> fetchProgressData() async {
    try {
      final progressSnapshot = await FirebaseFirestore.instance
          .collection('students')
          .doc(widget.studentId)
          .collection('progress')
          .doc(widget.courseId)
          .collection('topics')
          .get();

      setState(() {
        completedTopics = progressSnapshot.docs
            .where((doc) => doc.data()['status'] == 'completed')
            .length;

        pendingTopics = progressSnapshot.docs
            .where((doc) => doc.data()['status'] == 'pending')
            .length;

        completedTopicList = progressSnapshot.docs
            .where((doc) => doc.data()['status'] == 'completed')
            .map((doc) => doc.data()['name']?.toString() ?? 'Unknown')
            .toList()
            .cast<String>();  // Explicitly cast the list to List<String>
      });
    } catch (e) {
      print("Error fetching progress data: $e");
    }
  }

  void toggleTopicVisibility(String topicId, bool isVisible) async {
    final studentRef = FirebaseFirestore.instance.collection('students').doc(widget.studentId);

    try {
      bool topicChanged = false;

      setState(() {
        if (isVisible && !showTopics.contains(topicId)) {
          showTopics.add(topicId);
          topicChanged = true;
        } else if (!isVisible && showTopics.contains(topicId)) {
          showTopics.remove(topicId);
          topicChanged = true;
        }
      });

      if (topicChanged) {
        await studentRef.update({
          'showTopics': showTopics,
        });
      }
    } catch (e) {
      print("Error updating topic visibility: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Course Details'),
        actions: [
          IconButton(
            icon: Icon(Icons.show_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProgressPage(
                    totalTopics: totalTopics,
                    completedTopics: completedTopics,
                    pendingTopics: pendingTopics,
                    completedTopicList: completedTopicList,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            child: topics.isEmpty
                ? Center(child: Text('No topics found'))
                : ListView.builder(
              itemCount: topics.length,
              itemBuilder: (context, index) {
                final topic = topics[index];
                final isVisible = showTopics.contains(topic['id']);

                return ListTile(
                  title: Text(topic['name']),
                  trailing: Checkbox(
                    value: isVisible,
                    onChanged: (bool? value) {
                      toggleTopicVisibility(topic['id'], value ?? false);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
