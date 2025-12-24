import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import '../UI/homepage.dart'; // not used when navigating via named route

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<void> login(String email, String password, BuildContext context) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      String uid = userCredential.user!.uid;

      String role = 'user'; // Default role

      // Hardcode role berdasarkan email untuk test
      if (email == 'admin@admin.com') {
        role = 'admin';
      } else if (email == 'user@user.com') {
        role = 'user';
      } else {
        // Jika email lain, coba ambil dari Firestore
        try {
          DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
          if (userDoc.exists) {
            role = userDoc['role'] ?? 'user';
          }
        } catch (e) {
          print('Gagal ambil role: $e, default ke user');
        }
      }

      print('Login sebagai: $email, Role: $role'); // Debug

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Login berhasil!'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate berdasarkan role
      if (role == 'admin') {
        Navigator.pushReplacementNamed(context, '/dashboard');
      } else {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error: ${e.message}'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error umum: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  static Future<void> register(String email, String password, BuildContext context) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Registrasi berhasil!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error: ${e.message}'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error umum: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  static Future<void> logout(BuildContext context) async {
    await _auth.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }
}
