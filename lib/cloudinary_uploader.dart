import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class FirebaseStorageUploader {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String?> uploadImage(XFile imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final filename = 'products/${DateTime.now().millisecondsSinceEpoch}_${imageFile.name}';
      final ref = _storage.ref().child(filename);

      final uploadTask = ref.putData(bytes);
      final snapshot = await uploadTask.whenComplete(() => null);

      final downloadUrl = await snapshot.ref.getDownloadURL();
      print("Upload success: $downloadUrl");
      return downloadUrl;
    } catch (e) {
      print("Upload failed: $e");
      return null;
    }
  }
}
