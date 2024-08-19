import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'student_detail_screen.dart'; // Import the student detail screen

class ManageRequestsScreen extends StatefulWidget {
  @override
  _ManageRequestsScreenState createState() => _ManageRequestsScreenState();
}

class _ManageRequestsScreenState extends State<ManageRequestsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        body: Center(child: Text('You must be signed in to view this page.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Requests'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search by student name or course',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('requests')
                  .where('status', isEqualTo: 'accepted') // Show only accepted requests
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No requests available.'));
                }

                final requests = snapshot.data!.docs.toList();

                return FutureBuilder<List<Map<String, dynamic>>>(
                  future: _fetchCoursesDetails(requests),
                  builder: (context, courseSnapshot) {
                    if (courseSnapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (courseSnapshot.hasError) {
                      return Center(child: Text('Error loading course details'));
                    }

                    final courseDetailsList = courseSnapshot.data ?? [];

                    final filteredRequests = requests.where((doc) {
                      final request = doc.data() as Map<String, dynamic>;
                      final studentName = request['student_name']?.toLowerCase() ?? '';
                      final courseId = request['course_id'];
                      final courseName = courseDetailsList.firstWhere(
                            (courseDetail) => courseDetail['courseId'] == courseId,
                        orElse: () => {'name': ''},
                      )['name']?.toLowerCase() ?? '';

                      return studentName.contains(_searchQuery.toLowerCase()) ||
                          courseName.contains(_searchQuery.toLowerCase());
                    }).toList();

                    return ListView.builder(
                      padding: EdgeInsets.all(8.0),
                      itemCount: filteredRequests.length,
                      itemBuilder: (context, index) {
                        final request = filteredRequests[index].data() as Map<String, dynamic>;
                        final courseId = request['course_id'];

                        final courseDetails = courseDetailsList.firstWhere(
                              (courseDetail) => courseDetail['courseId'] == courseId,
                          orElse: () => {'name': 'Unknown Course'},
                        );

                        return Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            title: Text(request['student_name'] ?? 'Unknown'),
                            subtitle: Text('Course: ${courseDetails['name'] ?? 'Unknown Course'}'),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => StudentDetailScreen(request: request),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchCoursesDetails(List<QueryDocumentSnapshot> requests) async {
    try {
      final courseIds = requests.map((doc) => (doc.data() as Map<String, dynamic>)['course_id']).toSet().toList();
      final coursesSnapshot = await FirebaseFirestore.instance
          .collection('courses')
          .where(FieldPath.documentId, whereIn: courseIds)
          .get();

      return coursesSnapshot.docs.map((doc) {
        final courseData = doc.data() as Map<String, dynamic>;
        return {
          'courseId': doc.id,
          'name': courseData['name'] ?? 'Unknown Course',
        };
      }).toList();
    } catch (e) {
      print('Error fetching course details: $e');
      return [];
    }
  }

}
