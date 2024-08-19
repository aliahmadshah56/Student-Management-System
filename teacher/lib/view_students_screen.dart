// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class ViewStudentsScreen extends StatelessWidget {
//   // Method to activate a student
//   void _activateStudent(BuildContext context, String studentId) async {
//     try {
//       await FirebaseFirestore.instance
//           .collection('students')
//           .doc(studentId)
//           .update({'status': 'active'});
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Student activated successfully!')),
//       );
//     } catch (e) {
//       print('Error activating student: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to activate student: $e')),
//       );
//     }
//   }
//
//   // Method to deactivate a student
//   void _deactivateStudent(BuildContext context, String studentId) async {
//     try {
//       await FirebaseFirestore.instance
//           .collection('students')
//           .doc(studentId)
//           .update({'status': 'inactive'});
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Student deactivated successfully!')),
//       );
//     } catch (e) {
//       print('Error deactivating student: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to deactivate student: $e')),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('View Students'),
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
//             return Center(child: Text('No students available'));
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
//               // Safely access fields with default values
//               final studentName = student['name'] ?? 'Unknown';
//               final studentEmail = student['email'] ?? 'No email';
//
//               return Card(
//                 elevation: 5,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: ListTile(
//                   title: Text(studentName),
//                   subtitle: Text(studentEmail),
//                   trailing: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       IconButton(
//                         icon: Icon(Icons.check),
//                         onPressed: () => _activateStudent(context, students[index].id),
//                       ),
//                       IconButton(
//                         icon: Icon(Icons.close),
//                         onPressed: () => _deactivateStudent(context, students[index].id),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
