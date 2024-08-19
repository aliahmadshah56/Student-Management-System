import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditTopicScreen extends StatefulWidget {
  final String courseId;
  final String topicId;
  final String topicName;
  final String topicDescription;
  final String topicDocumentationUrl;
  final String topicVideoUrl;

  EditTopicScreen({
    required this.courseId,
    required this.topicId,
    required this.topicName,
    required this.topicDescription,
    required this.topicDocumentationUrl,
    required this.topicVideoUrl,
  });

  @override
  _EditTopicScreenState createState() => _EditTopicScreenState();
}

class _EditTopicScreenState extends State<EditTopicScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _documentationUrlController;
  late TextEditingController _videoUrlController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.topicName);
    _descriptionController = TextEditingController(text: widget.topicDescription);
    _documentationUrlController = TextEditingController(text: widget.topicDocumentationUrl);
    _videoUrlController = TextEditingController(text: widget.topicVideoUrl);
  }

  void _saveTopic() async {
    await FirebaseFirestore.instance
        .collection('courses')
        .doc(widget.courseId)
        .collection('topics')
        .doc(widget.topicId)
        .update({
      'name': _nameController.text,
      'description': _descriptionController.text,
      'documentation_url': _documentationUrlController.text,
      'video_url': _videoUrlController.text,
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Topic updated successfully!')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Topic'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveTopic,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Topic Name',
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
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveTopic,
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
