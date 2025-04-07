import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class CloudStorageService {
  static CloudStorageService instance = CloudStorageService();

  late FirebaseStorage _storage;
  late Reference _reference;

  String _profileImages = "profile_images";

  CloudStorageService() {
    _storage = FirebaseStorage.instance;
    _reference = _storage.ref();
  }

  Future<UploadTask> uploadProfileImage(String _uid, String _image) async {
    try{
      return _reference.child(_profileImages).child(_uid).putFile(File(_image));
    } catch (e) {
      throw Exception('Failed to upload profile image: $e');
    }
  }
}
