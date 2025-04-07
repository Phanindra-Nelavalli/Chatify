import 'package:cloud_firestore/cloud_firestore.dart';

class DBService {
  static DBService instance = DBService();
  late FirebaseFirestore _db;

  DBService() {
    _db = FirebaseFirestore.instance;
  }

  String _Usercollection = "Users";

  Future<void> createUserInDB(
    String uid,
    String _name,
    String _email,
    String _imageURL,
  ) async {
    try {
      return await _db.collection(_Usercollection).doc(uid).set({
        "name": _name,
        "email": _email,
        "image": _imageURL,
        "lastseen": DateTime.now(),
      });
    } catch (e) {
      print(e);
    }
  }
}
