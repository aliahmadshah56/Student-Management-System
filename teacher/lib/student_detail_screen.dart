import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'add_or_update_topic_screen.dart'; // Import the teacher's screen

class StudentDetailScreen extends StatefulWidget {
  final Map<String, dynamic> request;

  StudentDetailScreen({required this.request});

  @override
  _StudentDetailScreenState createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends State<StudentDetailScreen> {
  late Map<String, dynamic> courseDetails;
  bool isLoading = true;
  List<Map<String, dynamic>> _selectedTopics = []; // Topics selected by the teacher
  List<Map<String, dynamic>> _allTopics = []; // All topics fetched
  bool _showTopicsSelection = false; // Initially hide topics

  @override
  void initState() {
    super.initState();
    _fetchCourseDetails();
  }

  Future<void> _fetchCourseDetails() async {
    final studentId = widget.request['student_id']; // Unique ID for the student
    final courseId = widget.request['course_id'];

    try {
      // Fetch course document
      final courseSnapshot = await FirebaseFirestore.instance
          .collection('courses')
          .doc(courseId)
          .get();

      if (courseSnapshot.exists) {
        final courseData = courseSnapshot.data() as Map<String, dynamic>? ?? {};

        // Fetch all topics
        final topicsSnapshot = await FirebaseFirestore.instance
            .collection('courses')
            .doc(courseId)
            .collection('topics')
            .get();

        _allTopics = topicsSnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

        // Fetch selected topics for the specific student
        final studentTopicsSnapshot = await FirebaseFirestore.instance
            .collection('students')
            .doc(studentId)
            .collection('selected_topics')
            .get();

        _selectedTopics = studentTopicsSnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

        setState(() {
          courseDetails = {
            'name': courseData['name'] ?? 'Unknown Course',
            'description': courseData['description'] ?? 'No description',
            'topics': _allTopics,
          };
          isLoading = false;
        });
      } else {
        setState(() {
          courseDetails = {
            'name': 'Unknown Course',
            'description': 'No description',
            'topics': [],
          };
          _allTopics = [];
          _selectedTopics = [];
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching course details: $e');
      setState(() {
        courseDetails = {
          'name': 'Unknown Course',
          'description': 'No description',
          'topics': [],
        };
        _allTopics = [];
        _selectedTopics = [];
        isLoading = false;
      });
    }
  }

  Future<void> _saveSelectedTopics() async {
    final studentId = widget.request['student_id']; // Unique ID for the student

    try {
      final batch = FirebaseFirestore.instance.batch();

      // Delete existing selected topics
      final existingTopicsSnapshot = await FirebaseFirestore.instance
          .collection('students')
          .doc(studentId)
          .collection('selected_topics')
          .get();

      for (var doc in existingTopicsSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Add new selected topics
      for (var topic in _selectedTopics) {
        final docRef = FirebaseFirestore.instance
            .collection('students')
            .doc(studentId)
            .collection('selected_topics')
            .doc();

        batch.set(docRef, topic);
      }

      await batch.commit();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Topics saved successfully!')),
      );
    } catch (e) {
      print('Error saving topics: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving topics. Please try again.')),
      );
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

    // Filter topics based on teacher's selection
    final visibleTopics = _allTopics.where((topic) =>
        _selectedTopics.any((selectedTopic) => selectedTopic['name'] == topic['name'])
    ).toList();

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
            _buildDetailRow('Name', studentName),
            _buildDetailRow('Mobile', studentMobile),
            _buildDetailRow('Father\'s Name', fatherName),
            _buildDetailRow('Father\'s Mobile', fatherMobile),
            _buildDetailRow('Course', courseName),
            if (timestamp != null) _buildDetailRow('Requested on', _formatDate(timestamp)),
            SizedBox(height: 16),
            if (!_showTopicsSelection && visibleTopics.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Course Topics:', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                  ..._buildTopicList(visibleTopics), // Show only visible topics
                ],
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_showTopicsSelection) {
            _saveSelectedTopics(); // Save topics when confirming
          }
          setState(() {
            _showTopicsSelection = !_showTopicsSelection;
          });
        },
        child: Icon(_showTopicsSelection ? Icons.check : Icons.edit),
        tooltip: _showTopicsSelection ? 'Confirm Selection' : 'Edit Topics',
      ),
      // Add a floating button to navigate to the AddOrUpdateTopicScreen
      bottomNavigationBar: BottomAppBar(
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddOrUpdateTopicScreen(courseId: widget.request['course_id']),
                  ),
                );
              },
            ),
            Text('Add Topic'),
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

  List<Widget> _buildTopicList(List<Map<String, dynamic>> topics) {
    if (topics.isEmpty) {
      return [Text('No topics available')];
    }

    return topics.map<Widget>((topic) {
      return TopicCard(topic: topic);
    }).toList();
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.toLocal().toIso8601String()}'; // Format date as needed
  }
}

class TopicCard extends StatelessWidget {
  final Map<String, dynamic> topic;

  TopicCard({required this.topic});

  @override
  Widget build(BuildContext context) {
    final topicName = topic['name'] ?? 'No topic name';
    final description = topic['description'] ?? 'No description';
    final documentationUrl = topic['documentation_url'] ?? '';
    final videoUrl = topic['video_url'] ?? '';

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
            Text(
              topicName,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            if (description.isNotEmpty) ...[
              SizedBox(height: 8),
              Text(
                'Description: $description',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black87),
              ),
            ],
            if (documentationUrl.isNotEmpty) ...[
              SizedBox(height: 8),
              GestureDetector(
                onTap: () => _launchURL(documentationUrl),
                child: Text(
                  'Documentation URL: $documentationUrl',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.blue),
                ),
              ),
            ],
            if (videoUrl.isNotEmpty) ...[
              SizedBox(height: 8),
              GestureDetector(
                onTap: () => _launchURL(videoUrl),
                child: Text(
                  'Video URL: $videoUrl',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.blue),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
