// lib/controllers/authentication.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../UI/homepage.dart';
import '../UI/login.dart';

class AuthController extends GetxController {
  static AuthController instance = Get.find();
  late Rx<User?> _user;
  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void onReady() {
    super.onReady();
    _user = Rx<User?>(auth.currentUser);
    _user.bindStream(auth.authStateChanges());
    ever(
      _user,
      _initialScreen,
    ); 
  }

  _initialScreen(User? user) {
    if (user == null) {
      Get.offAll(() => LoginScreen()); 
    } else {
      Get.offAll(() => HomePage()); 
    }
  }

  void logout() async {
    await auth.signOut();
  }
}
