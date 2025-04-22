import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';
import 'dart:io';

class CloudStorageService {
  static CloudStorageService instance = CloudStorageService();

  late FirebaseStorage _storage;
  late Reference _reference;

  String _profileImages = "profile_images";
  String _messages = "messages";
  String _images = "images";

  CloudStorageService() {
    _storage = FirebaseStorage.instance;
    _reference = _storage.ref();
  }

  Future<UploadTask> uploadProfileImage(String _uid, String _image) async {
    try {
      return _reference.child(_profileImages).child(_uid).putFile(File(_image));
    } catch (e) {
      throw Exception('Failed to upload profile image: $e');
    }
  }

  Future<String> uploadMediaMessage(String _uid, File _image) async {
    var _timeStamp = DateTime.now();
    var _fileName = basename(_image.path);
    _fileName += "_${_timeStamp.toString()}";
    try {
      UploadTask _uploadTask = _reference
          .child(_messages)
          .child(_uid)
          .child(_images)
          .child(_fileName)
          .putFile(_image);
      TaskSnapshot _snapshot = await _uploadTask;
      return _snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }
}
