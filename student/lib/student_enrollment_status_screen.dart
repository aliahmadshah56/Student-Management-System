// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
//
// class StudentEnrollmentStatusScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final user = FirebaseAuth.instance.currentUser;
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Enrollment Status'),
//         backgroundColor: Colors.teal,
//         elevation: 0,
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance
//             .collection('requests')
//             .where('student_id', isEqualTo: user?.uid)
//             .snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           }
//
//           if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           }
//
//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//             return Center(child: Text('No enrollment status available'));
//           }
//
//           final requests = snapshot.data!.docs;
//           return ListView.separated(
//             padding: EdgeInsets.all(16.0),
//             itemCount: requests.length,
//             separatorBuilder: (context, index) => SizedBox(height: 12),
//             itemBuilder: (context, index) {
//               final request = requests[index];
//               final courseId = request.get('course_id') as String;
//               final status = request.get('status') as String;
//
//               return FutureBuilder<DocumentSnapshot>(
//                 future: FirebaseFirestore.instance.collection('courses').doc(courseId).get(),
//                 builder: (context, courseSnapshot) {
//                   if (courseSnapshot.connectionState == ConnectionState.waiting) {
//                     return ShimmerEffect(); // Placeholder while loading
//                   }
//
//                   if (courseSnapshot.hasError || !courseSnapshot.hasData) {
//                     return Card(
//                       margin: EdgeInsets.symmetric(vertical: 8.0),
//                       child: ListTile(
//                         contentPadding: EdgeInsets.all(16.0),
//                         title: Text('Error fetching course', style: TextStyle(color: Colors.red)),
//                       ),
//                     );
//                   }
//
//                   final courseData = courseSnapshot.data!.data() as Map<String, dynamic>? ?? {};
//                   return Card(
//                     elevation: 5,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     margin: EdgeInsets.symmetric(vertical: 8.0),
//                     child: ListTile(
//                       contentPadding: EdgeInsets.all(16.0),
//                       title: Text(
//                         courseData['name'] ?? 'No course name',
//                         style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
//                       ),
//                       subtitle: Text('Status: $status', style: TextStyle(color: Colors.grey[600])),
//
//                     ),
//                   );
//                 },
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
//
// class ShimmerEffect extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: EdgeInsets.symmetric(vertical: 8.0),
//       child: ListTile(
//         contentPadding: EdgeInsets.all(16.0),
//         title: Container(
//           height: 20,
//           width: double.infinity,
//           color: Colors.grey[300],
//         ),
//         subtitle: Container(
//           height: 14,
//           width: double.infinity,
//           color: Colors.grey[300],
//         ),
//       ),
//     );
//   }
// }
