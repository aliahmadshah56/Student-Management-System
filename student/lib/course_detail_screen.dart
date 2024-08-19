import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class CourseDetailScreen extends StatelessWidget {
  final String courseId;

  CourseDetailScreen({required this.courseId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Course Details'),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('courses')
            .doc(courseId)
            .get(),
        builder: (context, courseSnapshot) {
          if (courseSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (courseSnapshot.hasError) {
            return Center(child: Text('Error fetching course details: ${courseSnapshot.error}'));
          }

          if (!courseSnapshot.hasData || !courseSnapshot.data!.exists) {
            return Center(child: Text('Course not found'));
          }

          final courseData = courseSnapshot.data!.data() as Map<String, dynamic>? ?? {};
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  courseData['name'] ?? 'No course name',
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
                      .where('visible', isEqualTo: true) // Filter based on visibility
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
                    return ListView.builder(
                      itemCount: topics.length,
                      itemBuilder: (context, index) {
                        final topic = topics[index];
                        return TopicCard(topic: topic);
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class TopicCard extends StatelessWidget {
  final DocumentSnapshot topic;

  TopicCard({required this.topic});

  @override
  Widget build(BuildContext context) {
    final topicData = topic.data() as Map<String, dynamic>? ?? {};

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: EdgeInsets.all(16),
            title: Text(
              topicData['name'] ?? 'No topic name',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            trailing: IconButton(
              icon: Icon(Icons.expand_more),
              onPressed: () {
                // Logic to expand/collapse content
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (topicData.containsKey('description') && (topicData['description'] as String?)?.isNotEmpty == true) ...[
                  Text(
                    'Description:',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    topicData['description']!,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.black87),
                  ),
                  SizedBox(height: 8),
                ],
                if (topicData.containsKey('documentation_url') && (topicData['documentation_url'] as String?)?.isNotEmpty == true) ...[
                  GestureDetector(
                    onTap: () => _launchURL(topicData['documentation_url']!),
                    child: Text(
                      'Documentation URL:',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 4),
                  GestureDetector(
                    onTap: () => _launchURL(topicData['documentation_url']!),
                    child: Text(
                      topicData['documentation_url']!,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Colors.blue),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(height: 8),
                ],
                if (topicData.containsKey('video_url') && (topicData['video_url'] as String?)?.isNotEmpty == true) ...[
                  GestureDetector(
                    onTap: () => _launchURL(topicData['video_url']!),
                    child: Text(
                      'Video URL:',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 4),
                  GestureDetector(
                    onTap: () => _launchURL(topicData['video_url']!),
                    child: Text(
                      topicData['video_url']!,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Colors.blue),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(height: 8),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
