import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewRequestsScreen extends StatelessWidget {
  // Method to accept a request
  void _acceptRequest(BuildContext context, String requestId) async {
    try {
      await FirebaseFirestore.instance
          .collection('requests')
          .doc(requestId)
          .update({'status': 'accepted'});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Request accepted successfully!')),
      );
    } catch (e) {
      print('Error accepting request: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to accept request: $e')),
      );
    }
  }

  // Method to reject a request
  void _rejectRequest(BuildContext context, String requestId) async {
    try {
      await FirebaseFirestore.instance
          .collection('requests')
          .doc(requestId)
          .update({'status': 'rejected'});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Request rejected successfully!')),
      );
    } catch (e) {
      print('Error rejecting request: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to reject request: $e')),
      );
    }
  }

  Future<String> _fetchCourseName(String courseId) async {
    try {
      DocumentSnapshot courseDoc = await FirebaseFirestore.instance
          .collection('courses')
          .doc(courseId)
          .get();

      if (courseDoc.exists) {
        // Cast the data to a Map<String, dynamic>
        final data = courseDoc.data() as Map<String, dynamic>;
        return data['name'] ?? 'Unknown Course';
      } else {
        return 'Course Not Found';
      }
    } catch (e) {
      print('Error fetching course name: $e');
      return 'Error Fetching Course';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Requests'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('requests')
            .where('status', isEqualTo: 'pending')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No pending requests'));
          }

          final requests = snapshot.data!.docs;

          return SingleChildScrollView(
            child: Column(
              children: requests.map((requestDoc) {
                final request = requestDoc.data() as Map<String, dynamic>;
                final requestId = requestDoc.id;

                return FutureBuilder<String>(
                  future: _fetchCourseName(request['course_id']),
                  builder: (context, courseSnapshot) {
                    if (courseSnapshot.connectionState == ConnectionState.waiting) {
                      return ListTile(
                        title: Text('Loading...'),
                      );
                    }

                    if (courseSnapshot.hasError) {
                      return ListTile(
                        title: Text('Error fetching course name'),
                      );
                    }

                    final courseName = courseSnapshot.data ?? 'Unknown Course';

                    return Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      margin: EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text(request['student_name'] ?? 'Unknown'),
                        subtitle: Text('Course: $courseName'),
                        trailing: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Mobile: ${request['student_mobile'] ?? 'N/A'}'),
                            Text('Father: ${request['father_name'] ?? 'N/A'}'),
                            Text('Status: ${request['status'] ?? 'Unknown Status'}'),
                          ],
                        ),
                        isThreeLine: true,
                        contentPadding: EdgeInsets.all(8.0),
                        dense: true,
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Request Actions'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('Student Name: ${request['student_name'] ?? 'Unknown'}'),
                                  Text('Course Name: $courseName'),
                                  Text('Status: ${request['status'] ?? 'Pending'}'),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    _acceptRequest(context, requestId);
                                  },
                                  child: Text('Accept'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    _rejectRequest(context, requestId);
                                  },
                                  child: Text('Reject'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
