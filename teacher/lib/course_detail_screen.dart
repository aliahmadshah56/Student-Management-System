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
    fetchCourseDetails();
  }

  Future<void> fetchCourseDetails() async {
    try {
      final studentRef = FirebaseFirestore.instance
          .collection('students')
          .doc(widget.studentId)
          .collection('enrolledCourses')
          .doc(widget.courseId);

      final courseSnapshot = await studentRef.get();

      if (courseSnapshot.exists) {
        final courseData = courseSnapshot.data();
        if (courseData != null) {
          setState(() {
            showTopics = List<String>.from(courseData['showTopics'] ?? []);
          });
        }
      } else {
        await studentRef.set({
          'courseName': 'Unknown Course',
          'showTopics': [],
        });
        setState(() {
          showTopics = [];
        });
      }

      fetchCourseTopics();
      fetchProgressData();
    } catch (e) {
      print("Error fetching course details: $e");
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
          'name': doc.data()['name'] ?? 'Unknown',
        }).toList();
        totalTopics = topics.length;
      });
    } catch (e) {
      print("Error fetching course topics: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchProgressData() async {
    try {
      final progressSnapshot = await FirebaseFirestore.instance
          .collection('students')
          .doc(widget.studentId)
          .collection('enrolledCourses')
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
            .cast<String>();
      });
    } catch (e) {
      print("Error fetching progress data: $e");
    }
  }

  void toggleTopicVisibility(String topicId, bool isVisible) async {
    final studentRef = FirebaseFirestore.instance
        .collection('students')
        .doc(widget.studentId)
        .collection('enrolledCourses')
        .doc(widget.courseId);

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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Course Details',style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.teal,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.show_chart, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProgressPage(
                    totalTopics: totalTopics,
                    completedTopics: completedTopics,
                    pendingTopics: pendingTopics,
                    completedTopicList: completedTopicList,
                   showTopics: showTopics,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Topics',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: topics.isEmpty
                  ? Center(child: Text('No topics found'))
                  : ListView.builder(
                itemCount: topics.length,
                itemBuilder: (context, index) {
                  final topic = topics[index];
                  final isVisible = showTopics.contains(topic['id']);

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    margin: EdgeInsets.symmetric(vertical: 8),
                    elevation: 3,
                    child: ListTile(
                      title: Text(
                        topic['name'],
                        style: theme.textTheme.headlineMedium,
                      ),
                      trailing: Switch(
                        value: isVisible,
                        onChanged: (value) {
                          toggleTopicVisibility(topic['id'], value);
                        },
                        activeColor: Colors.teal,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
