// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class AuthService {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//   Future<String> getUserRole() async {
//     User? user = _auth.currentUser;
//     if (user == null) return 'guest'; // Or handle unauthenticated users
//
//     DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
//     if (userDoc.exists) {
//       return userDoc['role'] ?? 'guest';
//     }
//     return 'guest'; // Default role if not found
//   }
// }
