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

  void _confirmDeleteCourse() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Deletion'),
        content: Text('Are you sure you want to delete this course?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(), // Close the dialog
            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              _deleteCourse();
              Navigator.of(context).pop(); // Close the dialog
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
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

  void _confirmDeleteTopic(String topicId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Deletion'),
        content: Text('Are you sure you want to delete this topic?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(), // Close the dialog
            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              _deleteTopic(topicId);
              Navigator.of(context).pop(); // Close the dialog
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _deleteTopic(String topicId) async {
    await FirebaseFirestore.instance
        .collection('courses')
        .doc(widget.courseId)
        .collection('topics')
        .doc(topicId)
        .delete();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Topic deleted successfully!')),
    );
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
        title: Text('Edit Course', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: Icon(Icons.delete, color: Colors.white),
            onPressed: _confirmDeleteCourse,
            tooltip: 'Delete Course',
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
                labelStyle: TextStyle(color: Colors.deepPurple),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.deepPurple, width: 2.0),
                ),
              ),
              style: TextStyle(fontSize: 18),
              onSubmitted: (value) {
                // Optionally handle course name update here
              },
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _addTopic,
              icon: Icon(Icons.add, color: Colors.white),
              label: Text('Add Topic', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                textStyle: TextStyle(fontSize: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
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
                  if (topics.isEmpty) {
                    return Center(
                      child: Text('No topics found',
                          style: TextStyle(fontSize: 18, color: Colors.grey)),
                    );
                  }
                  return ListView.builder(
                    itemCount: topics.length,
                    itemBuilder: (context, index) {
                      final topicData = topics[index].data() as Map<String, dynamic>?;
                      final topicName = topicData?['name'] ?? 'No name';
                      final topicId = topics[index].id;
                      final topicDescription = topicData?['description'] ?? 'No description';
                      final topicDocumentationUrl = topicData?['documentation_url'] ?? '';
                      final topicVideoUrl = topicData?['video_url'] ?? '';

                      return Card(
                        elevation: 4,
                        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          title: Text(topicName, style: TextStyle(fontWeight: FontWeight.bold)),
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
                                icon: Icon(Icons.edit, color: Colors.blue),
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
                                tooltip: 'Edit Topic',
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  _confirmDeleteTopic(topicId);
                                },
                                tooltip: 'Delete Topic',
                              ),
                            ],
                          ),
                        ),
                      );
                    },
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
