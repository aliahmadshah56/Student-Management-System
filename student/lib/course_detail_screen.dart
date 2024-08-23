import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:student/progress_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class CourseDetailScreen extends StatefulWidget {
  final String courseId;
  final String studentId;

  CourseDetailScreen({required this.courseId, required this.studentId});

  @override
  _CourseDetailScreenState createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  late Future<void> _refreshFuture;

  @override
  void initState() {
    super.initState();
    _refreshFuture = Future.value(); // Initialize with a completed Future
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _refreshFuture = Future.delayed(Duration(seconds: 1)); // Simulate data fetch
    });
  }

  Future<Map<String, dynamic>?> _fetchCourseData() async {
    try {
      final studentCourseRef = FirebaseFirestore.instance
          .collection('students')
          .doc(widget.studentId)
          .collection('enrolledCourses')
          .doc(widget.courseId);

      final courseSnapshot = await studentCourseRef.get();
      if (!courseSnapshot.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Course not found for this student.')),
        );
        return null;
      }

      return courseSnapshot.data() as Map<String, dynamic>?;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching course data: $e')),
      );
      return null;
    }
  }

  Future<List<DocumentSnapshot>> _fetchTopicSnapshots(List<String> showTopics) async {
    try {
      return await Future.wait(
        showTopics.map((topicId) => FirebaseFirestore.instance
            .collection('courses')
            .doc(widget.courseId)
            .collection('topics')
            .doc(topicId)
            .get()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching topics: $e')),
      );
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Course Details'),
        actions: [
          IconButton(
            icon: Icon(Icons.bar_chart),
            onPressed: () async {
              try {
                final courseData = await _fetchCourseData();
                if (courseData == null) return;

                final showTopics = List<String>.from(courseData['showTopics'] ?? []);
                if (showTopics.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('No topics found for this student.')),
                  );
                  return;
                }

                final topicSnapshots = await _fetchTopicSnapshots(showTopics);

                final completedTopicList = topicSnapshots
                    .where((snapshot) =>
                (snapshot.data() as Map<String, dynamic>?)?['status']?.toString() == 'completed')
                    .map((snapshot) => (snapshot.data() as Map<String, dynamic>?)?['name'] as String? ?? 'Unknown')
                    .toList();

                final totalTopics = showTopics.length;
                final completedTopics = completedTopicList.length;
                final pendingTopics = totalTopics - completedTopics;

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProgressPage(
                  studentId: widget.studentId,
                      courseId: widget.courseId,

                    ),
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error fetching data: $e')),
                );
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('students')
              .doc(widget.studentId)
              .collection('enrolledCourses')
              .doc(widget.courseId)
              .get(),
          builder: (context, courseSnapshot) {
            if (courseSnapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (courseSnapshot.hasError) {
              return Center(child: Text('Error fetching course data: ${courseSnapshot.error}'));
            }

            if (!courseSnapshot.hasData || courseSnapshot.data?.data() == null) {
              return Center(child: Text('No data available for this course'));
            }

            final courseData = courseSnapshot.data!.data() as Map<String, dynamic>? ?? {};
            final showTopics = List<String>.from(courseData['showTopics'] ?? []);

            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('courses')
                  .doc(widget.courseId)
                  .collection('topics')
                  .snapshots(),
              builder: (context, topicSnapshot) {
                if (topicSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (topicSnapshot.hasError) {
                  return Center(child: Text('Error fetching topics: ${topicSnapshot.error}'));
                }

                if (!topicSnapshot.hasData || topicSnapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No topics available'));
                }

                final topics = topicSnapshot.data!.docs;
                final filteredTopics = topics
                    .where((topic) => showTopics.contains(topic.id))
                    .toList();

                return ListView.builder(
                  itemCount: filteredTopics.length,
                  itemBuilder: (context, index) {
                    final topic = filteredTopics[index];
                    return TopicCard(
                      topic: topic,
                      studentId: widget.studentId,
                      courseId: widget.courseId,
                      topicNumber: index + 1,
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class TopicCard extends StatelessWidget {
  final DocumentSnapshot topic;
  final String studentId;
  final String courseId;
  final int topicNumber;

  TopicCard({
    required this.topic,
    required this.studentId,
    required this.courseId,
    required this.topicNumber,
  });

  @override
  Widget build(BuildContext context) {
    final topicData = topic.data() as Map<String, dynamic>? ?? {};
    final topicName = topicData['name'] ?? 'No topic name';
    final description = topicData['description'] ?? 'No description';
    final documentationUrl = topicData['documentation_url'] ?? '';
    final videoUrl = topicData['video_url'] ?? '';

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExpansionTile(
              title: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      topicName,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontWeight: FontWeight.bold, fontSize: 20),
                      overflow: TextOverflow.visible,
                    ),
                  ),
                  SizedBox(width: 16),
                  Text(
                    'Topic ${topicNumber}',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              children: [
                if (description.isNotEmpty)
                  ListTile(
                    title: Text('Description'),
                    subtitle: Text(description),
                  ),
                if (documentationUrl.isNotEmpty)
                  ListTile(
                    title: Text('Documentation URL'),
                    subtitle: GestureDetector(
                      onTap: () => _showURLDialog(context, documentationUrl),
                      child: Text(
                        documentationUrl,
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ),
                if (videoUrl.isNotEmpty)
                  ListTile(
                    title: Text('Video URL'),
                    subtitle: GestureDetector(
                      onTap: () => _showURLDialog(context, videoUrl),
                      child: Text(
                        videoUrl,
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('students')
                    .doc(studentId)
                    .collection('enrolledCourses')
                    .doc(courseId)
                    .collection('topics')
                    .doc(topic.id)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return CircularProgressIndicator();
                  }

                  final topicStatus = snapshot.data?.get('status') ?? 'pending';

                  return PopupMenuButton<String>(
                    onSelected: (value) async {
                      await _updateStatus(context, value);
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'pending',
                        child: Text('Mark as Pending'),
                      ),
                      PopupMenuItem(
                        value: 'completed',
                        child: Text('Mark as Completed'),
                      ),
                    ],
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          topicStatus.toUpperCase(),
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_drop_down),
                      ],
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

  Future<void> _updateStatus(BuildContext context, String newStatus) async {
    try {
      final topicRef = FirebaseFirestore.instance
          .collection('students')
          .doc(studentId)
          .collection('enrolledCourses')
          .doc(courseId)
          .collection('topics')
          .doc(topic.id);

      await topicRef.update({
        'status': newStatus,
        'completedAt': newStatus == 'completed' ? Timestamp.now() : FieldValue.delete(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status updated to $newStatus')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating status: $e')),
      );
    }
  }

  void _showURLDialog(BuildContext context, String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cannot open URL')),
      );
    }
  }
}
