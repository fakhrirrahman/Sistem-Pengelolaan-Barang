import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseSeeder {
  static final _auth = FirebaseAuth.instance;
  static final _firestore = FirebaseFirestore.instance;

  // BUAT ADMIN DEFAULT
  static Future<void> createAdmin() async {
    try {
      final email = "admin@admin.com";
      final password = "admin123";

      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firestore.collection("users").doc(cred.user!.uid).set({
        "uid": cred.user!.uid,
        "email": email,
        "role": "admin",
        "name": "Default Admin",
        "createdAt": DateTime.now(),
      });

      print("Admin berhasil dibuat!");
    } catch (e) {
      print("Admin sudah ada / error: $e");
    }
  }

  // BUAT USER DEFAULT
  static Future<void> createUser() async {
    try {
      final email = "user@user.com";
      final password = "user123";

      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firestore.collection("users").doc(cred.user!.uid).set({
        "uid": cred.user!.uid,
        "email": email,
        "role": "user",
        "name": "Default User",
        "createdAt": DateTime.now(),
      });

      print("User berhasil dibuat!");
    } catch (e) {
      print("User sudah ada / error: $e");
    }
  }
}