import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../UI/homepage.dart';

class Registercontroller extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void register(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      Get.snackbar("Sukses!", "Pendaftaran berhasil!");
      Get.offAll(() => HomePage());
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        "Gagal Daftar",
        e.message ?? "Terjadi kesalahan",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  void login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      Get.snackbar("Sukses!", "Berhasil login!");
      Get.offAll(() => HomePage());
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        "Gagal Login",
        e.message ?? "Terjadi kesalahan",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }
}
