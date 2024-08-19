import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  courseData['description'] ?? 'No course description',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Course Topics:',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('courses')
                      .doc(courseId)
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
            Text(
              topicName,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
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
