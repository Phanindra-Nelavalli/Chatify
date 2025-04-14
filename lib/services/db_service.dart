import 'package:chatify/models/contact.dart';
import 'package:chatify/models/converstaion.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DBService {
  static DBService instance = DBService();
  late FirebaseFirestore _db;

  DBService() {
    _db = FirebaseFirestore.instance;
  }

  String _Usercollection = "Users";
  String _ConversationsCollection = "Conversations";

  Future<void> createUserInDB(
    String uid,
    String _name,
    String _email,
    String _imageURL,
  ) async {
    try {
      return await _db.collection(_Usercollection).doc(uid).set({
        "name": _name,
        "searchName": _name.toLowerCase(),
        "email": _email,
        "image": _imageURL,
        "lastseen": DateTime.now(),
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> updateUserLastSeen(String _userID) {
    var _ref = _db.collection(_Usercollection).doc(_userID);
    return _ref.update({"lastseen": Timestamp.now()});
  }

  Stream<Contact> getUserDetails(String _userID) {
    var _ref = _db.collection(_Usercollection).doc(_userID);
    return _ref.get().asStream().map((_snapshot) {
      return Contact.fromFirestore(_snapshot);
    });
  }

  Stream<List<ConverstaionSnippet>> getUserConversation(String _userID) {
    var _ref = _db
        .collection(_Usercollection)
        .doc(_userID)
        .collection(_ConversationsCollection);
    return _ref.snapshots().map((_querySnapshot) {
      return _querySnapshot.docs.map((_doc) {
        return ConverstaionSnippet.fromFirestore(_doc);
      }).toList();
    });
  }

  Stream<List<Contact>> getUsersInDB(String _searchName) {
    var _ref = _db
        .collection(_Usercollection)
        .where("searchName", isGreaterThanOrEqualTo: _searchName.toLowerCase())
        .where("searchName", isLessThan: _searchName.toLowerCase() + 'z');
    return _ref.snapshots().map((_snapshot) {
      return _snapshot.docs.map((_doc) {
        return Contact.fromFirestore(_doc);
      }).toList();
    });
  }

  Stream<Conversations> getConversation(String _conversationID) {
    var _ref = _db.collection(_ConversationsCollection).doc(_conversationID);
    return _ref.snapshots().map((_snapshot) {
      return Conversations.fromFirestore(_snapshot);
    });
  }
}
