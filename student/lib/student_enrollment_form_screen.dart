import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StudentEnrollmentFormScreen extends StatefulWidget {
  final String courseId;

  StudentEnrollmentFormScreen({required this.courseId});

  @override
  _StudentEnrollmentFormScreenState createState() => _StudentEnrollmentFormScreenState();
}

class _StudentEnrollmentFormScreenState extends State<StudentEnrollmentFormScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  final _formKey = GlobalKey<FormState>();
  String studentName = '';
  String studentMobile = '';
  String fatherName = '';
  String fatherMobile = '';
  bool currentlyStudying = false;
  String universityName = '';
  String semester = '';

  void _submitRequest() async {
    if (_formKey.currentState!.validate()) {
      final user = _auth.currentUser;
      if (user != null) {
        try {
          await _firestore.collection('requests').doc('${user.uid}_${widget.courseId}').set({
            'student_id': user.uid,
            'course_id': widget.courseId,
            'student_name': studentName,
            'student_mobile': studentMobile,
            'father_name': fatherName,
            'father_mobile': fatherMobile,
            'currently_studying': currentlyStudying,
            'university_name': universityName,
            'semester': semester,
            'status': 'pending',
            'timestamp': Timestamp.now(),
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Enrollment request submitted!')),
          );
          Navigator.pop(context);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to submit request: $e')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('You need to be logged in to submit a request')),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enrollment Form'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildTextField(
                  label: 'Student Name',
                  onChanged: (value) => studentName = value,
                  validator: (value) => value!.isEmpty ? 'Please enter your name' : null,
                ),
                SizedBox(height: 16),
                _buildTextField(
                  label: 'Student Mobile',
                  keyboardType: TextInputType.phone,
                  onChanged: (value) => studentMobile = value,
                  validator: (value) => value!.isEmpty ? 'Please enter your mobile number' : null,
                ),
                SizedBox(height: 16),
                _buildTextField(
                  label: 'Father Name',
                  onChanged: (value) => fatherName = value,
                  validator: (value) => value!.isEmpty ? 'Please enter your father\'s name' : null,
                ),
                SizedBox(height: 16),
                _buildTextField(
                  label: 'Father Mobile',
                  keyboardType: TextInputType.phone,
                  onChanged: (value) => fatherMobile = value,
                  validator: (value) => value!.isEmpty ? 'Please enter your father\'s mobile number' : null,
                ),
                SizedBox(height: 16),
                CheckboxListTile(
                  title: Text('Currently Studying'),
                  value: currentlyStudying,
                  onChanged: (newValue) {
                    setState(() {
                      currentlyStudying = newValue!;
                    });
                  },
                ),
                if (currentlyStudying) ...[
                  SizedBox(height: 16),
                  _buildTextField(
                    label: 'University/College Name',
                    onChanged: (value) => universityName = value,
                  ),
                  SizedBox(height: 16),
                  _buildTextField(
                    label: 'Semester/Year',
                    onChanged: (value) => semester = value,
                  ),
                ],
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submitRequest,
                  child: Text('Submit Request', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    backgroundColor: Colors.teal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required ValueChanged<String> onChanged,
    TextInputType keyboardType = TextInputType.text,
    FormFieldValidator<String>? validator,
  }) {
    return TextFormField(
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      onChanged: onChanged,
      validator: validator,
    );
  }
}
