import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';

class FirebaseStorageUploader {
  Future<String?> uploadImage(XFile imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      if (kIsWeb) {
        // Untuk web, return base64
        final base64String = base64Encode(bytes);
        print("Base64 for web: ${base64String.substring(0, 50)}...");
        return 'data:image/jpeg;base64,$base64String'; // Data URL
      } else {
        // Untuk mobile, simpan file lokal
        final dir = await getApplicationDocumentsDirectory();
        final filename = 'products_${DateTime.now().millisecondsSinceEpoch}_${imageFile.name}';
        final file = File('${dir.path}/$filename');
        await file.writeAsBytes(bytes);
        print("Saved locally: ${file.path}");
        return file.path;
      }
    } catch (e) {
      print("Save failed: $e");
      throw e;
    }
  }
}
