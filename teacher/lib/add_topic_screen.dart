import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddTopicScreen extends StatefulWidget {
  final String courseId;
  AddTopicScreen({required this.courseId});

  @override
  _AddTopicScreenState createState() => _AddTopicScreenState();
}

class _AddTopicScreenState extends State<AddTopicScreen> {
  final TextEditingController _topicNameController = TextEditingController();
  final TextEditingController _documentationUrlController = TextEditingController();
  final TextEditingController _videoUrlController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  void _addTopic() async {
    if (_topicNameController.text.isNotEmpty) {
      try {
        // Add the new topic to the 'topics' collection
        DocumentReference topicRef = await FirebaseFirestore.instance
            .collection('courses')
            .doc(widget.courseId)
            .collection('topics')
            .add({
          'name': _topicNameController.text,
          'created_at': Timestamp.now(),
          'documentation_url': _documentationUrlController.text,
          'video_url': _videoUrlController.text,
          'description': _descriptionController.text,
        });

        // Update the 'showTopics' array in the 'courses' collection
        await FirebaseFirestore.instance
            .collection('courses')
            .doc(widget.courseId)
            .update({
          'showTopics': FieldValue.arrayUnion([topicRef.id]),
        });

        // Clear text fields and show a success message
        _topicNameController.clear();
        _documentationUrlController.clear();
        _videoUrlController.clear();
        _descriptionController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Topic added and updated successfully!')),
        );
        Navigator.pop(context); // Go back to previous screen
      } catch (e) {
        print("Error adding topic: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add topic.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Topic'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _topicNameController,
              decoration: InputDecoration(
                labelText: 'Topic Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _documentationUrlController,
              decoration: InputDecoration(
                labelText: 'Documentation URL',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _videoUrlController,
              decoration: InputDecoration(
                labelText: 'Video URL',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addTopic,
              child: Text('Add Topic'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
