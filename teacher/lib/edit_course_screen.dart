import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_topic_screen.dart';
import 'edit_topic_screen.dart';

class EditCourseScreen extends StatefulWidget {
  final String courseId;
  final String courseName;
  EditCourseScreen({required this.courseId, required this.courseName});

  @override
  _EditCourseScreenState createState() => _EditCourseScreenState();
}

class _EditCourseScreenState extends State<EditCourseScreen> {
  late TextEditingController _courseNameController;

  @override
  void initState() {
    super.initState();
    _courseNameController = TextEditingController(text: widget.courseName);
  }

  void _deleteCourse() async {
    await FirebaseFirestore.instance
        .collection('courses')
        .doc(widget.courseId)
        .delete();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Course deleted successfully!')),
    );
    Navigator.pop(context);
  }

  void _addTopic() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTopicScreen(courseId: widget.courseId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Course'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _deleteCourse,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _courseNameController,
              decoration: InputDecoration(
                labelText: 'Course Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onSubmitted: (value) {
                // Optionally handle course name update here
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addTopic,
              child: Text('Add Topic'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('courses')
                    .doc(widget.courseId)
                    .collection('topics')
                    .orderBy('created_at', descending: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  final topics = snapshot.data!.docs;
                  List<Widget> topicWidgets = [];
                  for (var topic in topics) {
                    final topicData = topic.data() as Map<String, dynamic>?;

                    final topicName = topicData?['name'] ?? 'No name';
                    final topicId = topic.id;
                    final topicDescription = topicData?['description'] ?? 'No description';
                    final topicDocumentationUrl = topicData?['documentation_url'] ?? '';
                    final topicVideoUrl = topicData?['video_url'] ?? '';

                    final topicWidget = ListTile(
                      title: Text(topicName),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (topicDescription.isNotEmpty) ...[
                            Text('Description: $topicDescription'),
                            SizedBox(height: 4),
                          ],
                          if (topicDocumentationUrl.isNotEmpty) ...[
                            Text('Documentation URL: $topicDocumentationUrl'),
                            SizedBox(height: 4),
                          ],
                          if (topicVideoUrl.isNotEmpty) ...[
                            Text('Video URL: $topicVideoUrl'),
                            SizedBox(height: 4),
                          ],
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditTopicScreen(
                                    courseId: widget.courseId,
                                    topicId: topicId,
                                    topicName: topicName,
                                    topicDescription: topicDescription,
                                    topicDocumentationUrl: topicDocumentationUrl,
                                    topicVideoUrl: topicVideoUrl,
                                  ),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              FirebaseFirestore.instance
                                  .collection('courses')
                                  .doc(widget.courseId)
                                  .collection('topics')
                                  .doc(topicId)
                                  .delete();
                            },
                          ),
                        ],
                      ),
                    );
                    topicWidgets.add(topicWidget);
                  }
                  return ListView(
                    children: topicWidgets,
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
