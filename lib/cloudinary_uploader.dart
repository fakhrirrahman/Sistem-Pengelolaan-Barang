import 'dart:io';
import 'package:http/http.dart' as http;

class CloudinaryUploader {
  final String cloudName = 'ISI_DENGAN_CLOUD_NAME_ANDA';

  Future<String?> uploadImage(File imageFile) async {
    final url = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");
    final uploadPreset = "unsigned_preset"; // akan dibuat di langkah 5

    var request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    var response = await request.send();

    if (response.statusCode == 200) {
      final res = await http.Response.fromStream(response);
      final data = res.body;
      print("Upload success: $data");
      return data;
    } else {
      print("Upload failed: ${response.statusCode}");
      return null;
    }
  }
}
