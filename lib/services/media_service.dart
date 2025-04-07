import 'dart:io';
import 'package:image_picker/image_picker.dart';

class MediaService {
  static MediaService instance = MediaService();

  Future<File> getImageFromLibrary() {
    return ImagePicker().pickImage(source: ImageSource.gallery).then((xfile) {
      if (xfile != null) {
        return File(xfile.path);
      } else {
        throw Exception("No image selected");
      }
    });
  }
}
