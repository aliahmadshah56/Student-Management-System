import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddOrUpdateTopicScreen extends StatefulWidget {
  final String courseId;
  final String? topicId; // Optional, for updating existing topics

  AddOrUpdateTopicScreen({required this.courseId, this.topicId});

  @override
  _AddOrUpdateTopicScreenState createState() => _AddOrUpdateTopicScreenState();
}

class _AddOrUpdateTopicScreenState extends State<AddOrUpdateTopicScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _documentationUrlController = TextEditingController();
  final _videoUrlController = TextEditingController();
  bool _isVisibleForStudents = true; // Default visibility

  @override
  void initState() {
    super.initState();
    if (widget.topicId != null) {
      _loadTopicDetails();
    }
  }

  Future<void> _loadTopicDetails() async {
    final topicSnapshot = await FirebaseFirestore.instance
        .collection('courses')
        .doc(widget.courseId)
        .collection('topics')
        .doc(widget.topicId)
        .get();

    if (topicSnapshot.exists) {
      final topicData = topicSnapshot.data() as Map<String, dynamic>;
      _nameController.text = topicData['name'] ?? '';
      _descriptionController.text = topicData['description'] ?? '';
      _documentationUrlController.text = topicData['documentation_url'] ?? '';
      _videoUrlController.text = topicData['video_url'] ?? '';
      _isVisibleForStudents = topicData['isVisibleForStudents'] ?? true;
      setState(() {});
    }
  }

  Future<void> _saveTopic() async {
    final topicData = {
      'name': _nameController.text,
      'description': _descriptionController.text,
      'documentation_url': _documentationUrlController.text,
      'video_url': _videoUrlController.text,
      'isVisibleForStudents': _isVisibleForStudents,
    };

    try {
      final docRef = FirebaseFirestore.instance
          .collection('courses')
          .doc(widget.courseId)
          .collection('topics')
          .doc(widget.topicId ?? DateTime.now().toString()); // Use a new ID if not updating

      await docRef.set(topicData);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Topic saved successfully!')),
      );
      Navigator.pop(context);
    } catch (e) {
      print('Error saving topic: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving topic. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.topicId == null ? 'Add Topic' : 'Update Topic'),
        backgroundColor: theme.primaryColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTextField(_nameController, 'Topic Name'),
            SizedBox(height: 15),
            _buildTextField(_descriptionController, 'Description', maxLines: 3),
            SizedBox(height: 15),
            _buildTextField(_documentationUrlController, 'Documentation URL'),
            SizedBox(height: 15),
            _buildTextField(_videoUrlController, 'Video URL'),
            SizedBox(height: 20),
            SwitchListTile(
              title: Text('Visible for Students'),
              value: _isVisibleForStudents,
              onChanged: (value) {
                setState(() {
                  _isVisibleForStudents = value;
                });
              },
              activeColor: theme.primaryColor,
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: _saveTopic,
              child: Text(
                widget.topicId == null ? 'Add Topic' : 'Update Topic',
                style: theme.textTheme.headlineMedium!.copyWith(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
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
