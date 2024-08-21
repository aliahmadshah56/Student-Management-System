import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:student/progress_screen.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CourseDetailScreen extends StatelessWidget {
  final String courseId;
  final String studentId;

  CourseDetailScreen({required this.courseId, required this.studentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Course Details'),
        backgroundColor: Colors.teal,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.bar_chart),
            onPressed: () async {
              try {
                final topicSnapshot = await FirebaseFirestore.instance
                    .collection('courses')
                    .doc(courseId)
                    .collection('topics')
                    .get();

                final totalTopics = topicSnapshot.size;

                final completedTopicsList = topicSnapshot.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return data.containsKey('status') &&
                      data['status'] == 'completed';
                }).map((doc) {
                  return (doc.data() as Map<String, dynamic>)['name'] as String;
                }).toList();

                final completedTopics = completedTopicsList.length;
                final pendingTopics = totalTopics - completedTopics;

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProgressPage(
                      totalTopics: totalTopics,
                      completedTopics: completedTopics,
                      pendingTopics: pendingTopics,
                      completedTopicList: completedTopicsList,
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
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Course Topics:',
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('courses')
                      .doc(courseId)
                      .collection('topics')
                      .snapshots(),
                  builder: (context, topicSnapshot) {
                    if (topicSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (topicSnapshot.hasError) {
                      return Center(
                          child: Text(
                              'Error fetching topics: ${topicSnapshot.error}'));
                    }

                    if (!topicSnapshot.hasData ||
                        topicSnapshot.data!.docs.isEmpty) {
                      return Center(child: Text('No topics available'));
                    }

                    final topics = topicSnapshot.data!.docs;

                    return ListView.builder(
                      itemCount: topics.length,
                      itemBuilder: (context, index) {
                        final topic = topics[index];
                        return TopicCard(
                          topic: topic,
                          studentId: studentId,
                          courseId: courseId,
                          topicNumber: index + 1, // Pass the topic number here
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}



class TopicCard extends StatefulWidget {
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
  _TopicCardState createState() => _TopicCardState();
}

class _TopicCardState extends State<TopicCard> {
  late String status;

  @override
  void initState() {
    super.initState();
    status = widget.topic['status'] ?? 'pending';
  }

  @override
  Widget build(BuildContext context) {
    final topicData = widget.topic.data() as Map<String, dynamic>? ?? {};
    final topicName = topicData['name'] ?? 'No topic name';
    final topicNumber = widget.topicNumber;
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
                    'Topic $topicNumber',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              children: [
                if (description.isNotEmpty) ...[
                  ListTile(
                    title: Text('Description'),
                    subtitle: Text(description),
                  ),
                ],
                if (documentationUrl.isNotEmpty) ...[
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
                ],
                if (videoUrl.isNotEmpty) ...[
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
              ],
            ),
            SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: PopupMenuButton<String>(
                onSelected: (value) async {
                  await _updateStatus(value);
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
                      status.toUpperCase(),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateStatus(String newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('courses')
          .doc(widget.courseId)
          .collection('topics')
          .doc(widget.topic.id)
          .update({'status': newStatus});

      await FirebaseFirestore.instance
          .collection('students')
          .doc(widget.studentId)
          .collection('progress')
          .doc(widget.courseId)
          .collection('topics')
          .doc(widget.topic.id)
          .set({
        'status': newStatus,
        'completedAt': newStatus == 'completed' ? FieldValue.serverTimestamp() : null,
      });

      setState(() {
        status = newStatus;
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

  void _showDetailsDialog(
      BuildContext context,
      String topicName,
      int topicNumber,
      String description,
      String documentationUrl,
      String videoUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('$topicName Details'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Topic Number: $topicNumber',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('Description: $description'),
              if (documentationUrl.isNotEmpty) ...[
                SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _launchUrl(context, documentationUrl),
                  child: Text(
                    'Documentation URL: $documentationUrl',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ],
              if (videoUrl.isNotEmpty) ...[
                SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _launchUrl(context, videoUrl),
                  child: Text(
                    'Video URL: $videoUrl',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _launchUrl(BuildContext context, String url) async {
    try {
      if (!url.startsWith('http')) {
        url = 'https://$url';
      }
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening URL: $e')),
      );
    }
  }

  void _showURLDialog(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Open URL'),
          content: Text('Do you want to open this URL?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _launchUrl(context, url);
              },
              child: Text('Open'),
            ),
          ],
        );
      },
    );
  }
}
