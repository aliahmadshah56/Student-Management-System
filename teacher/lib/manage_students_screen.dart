// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
//
// class ManageStudentsScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final User? user = FirebaseAuth.instance.currentUser;
//
//     if (user == null) {
//       return Scaffold(
//         body: Center(child: Text('You must be signed in to view this page.')),
//       );
//     }
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Manage Students'),
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance
//             .collection('students')
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
//             return Center(child: Text('No students available.'));
//           }
//
//           final students = snapshot.data!.docs;
//
//           return ListView.builder(
//             padding: EdgeInsets.all(8.0),
//             itemCount: students.length,
//             itemBuilder: (context, index) {
//               final student = students[index].data() as Map<String, dynamic>;
//
//               final studentName = student['student_name'] ?? 'Unknown';
//               final studentMobile = student['student_mobile'] ?? 'No mobile number';
//               final fatherName = student['father_name'] ?? 'No father name';
//               final courseId = student['course_id'] ?? 'No course ID';
//
//               return FutureBuilder<DocumentSnapshot>(
//                 future: FirebaseFirestore.instance
//                     .collection('courses')
//                     .doc(courseId)
//                     .get(),
//                 builder: (context, courseSnapshot) {
//                   if (courseSnapshot.connectionState == ConnectionState.waiting) {
//                     return ListTile(
//                       title: Text(studentName),
//                       subtitle: Text('Loading course details...'),
//                     );
//                   }
//
//                   if (courseSnapshot.hasError) {
//                     return ListTile(
//                       title: Text(studentName),
//                       subtitle: Text('Error loading course details'),
//                     );
//                   }
//
//                   final courseData = courseSnapshot.data?.data() as Map<String, dynamic>?;
//
//                   final courseName = courseData?['name'] ?? 'Unknown Course';
//                   final courseDescription = courseData?['description'] ?? 'No description';
//
//                   return Card(
//                     elevation: 5,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: ListTile(
//                       title: Text(studentName),
//                       subtitle: Text('Course: $courseName'),
//                       trailing: Text(courseDescription),
//                       onTap: () {
//                         // Optional: Implement any action on tap
//                       },
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
