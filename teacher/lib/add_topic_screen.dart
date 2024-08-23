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

        await FirebaseFirestore.instance
            .collection('courses')
            .doc(widget.courseId)
            .update({
          'showTopics': FieldValue.arrayUnion([topicRef.id]),
        });

        _topicNameController.clear();
        _documentationUrlController.clear();
        _videoUrlController.clear();
        _descriptionController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Topic added successfully!')),
        );
        Navigator.pop(context);
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
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Topic'),
        elevation: 0,
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTextField(_topicNameController, 'Topic Name'),
            SizedBox(height: 15),
            _buildTextField(_documentationUrlController, 'Documentation URL'),
            SizedBox(height: 15),
            _buildTextField(_videoUrlController, 'Video URL'),
            SizedBox(height: 15),
            _buildTextField(_descriptionController, 'Description', maxLines: 4),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: _addTopic,
              child: Text(
                'Add Topic',
                style: theme.textTheme.headlineMedium!.copyWith(color: Colors.teal),
              ),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 60, vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.grey[600]),
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
      maxLines: maxLines,
    );
  }
}
