import 'dart:io';
import 'package:cloudinary_url_gen/cloudinary.dart';
import 'package:cloudinary_api/uploader/cloudinary_uploader.dart';
import 'package:cloudinary_api/src/request/model/uploader_params.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CloudinaryService {
  static final Cloudinary _cloudinary = Cloudinary.fromStringUrl(
    dotenv.env['CLOUDINARY_URL'] ?? '',
  );

  /// Uploads a file to Cloudinary and returns the secure URL
  static Future<String?> uploadImage(File file, {String folder = 'quiz_images'}) async {
    try {
      final response = await _cloudinary.uploader().upload(
        file,
        params: UploadParams(
          folder: folder,
          resourceType: 'image',
        ),
      );

      if (response != null && response.data != null) {
        return response.data?.secureUrl;
      } else {
        throw Exception(response?.error?.message ?? 'Unknown error occurred during upload');
      }
    } catch (e) {
      throw Exception('Upload failed: $e');
    }
  }
}
