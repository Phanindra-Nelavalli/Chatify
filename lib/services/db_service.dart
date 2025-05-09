import 'package:chatify/models/contact.dart';
import 'package:chatify/models/converstaion.dart';
import 'package:chatify/models/message.dart';
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

  Future<void> updateProfileImage(String uid, String _imageURL) async {
    return await _db.collection(_Usercollection).doc(uid).update({
      "image": _imageURL,
    });
  }

  Future<void> updateUserLastSeen(String _userID) {
    var _ref = _db.collection(_Usercollection).doc(_userID);
    return _ref.update({"lastseen": Timestamp.now()});
  }

  Future<void> sendMessage(String _conversationID, Message _message) async {
    var _ref = _db.collection(_ConversationsCollection).doc(_conversationID);
    var _messageType = "";
    switch (_message.type) {
      case MessageType.Text:
        _messageType = "text";
        break;
      case MessageType.Image:
        _messageType = "image";
        break;
    }

    try {
      await _ref.update({
        "messages": FieldValue.arrayUnion([
          {
            "senderID": _message.senderID,
            "timestamp": _message.timestamp,
            "message": _message.message,
            "type": _messageType,
          },
        ]),
      });

      // After sending the message
    } catch (e) {
      print("Error sending message or offline: $e");
    }
  }

  Future<void> createOrGetConversation(
    String _currentUserId,
    String _recepientId,
    Future<void> onSuccess(String _conversationId),
  ) async {
    var _ref = _db.collection(_ConversationsCollection);
    var _userConversationCollectionRef = _db
        .collection(_Usercollection)
        .doc(_currentUserId)
        .collection(_ConversationsCollection);
    try {
      var conversation =
          await _userConversationCollectionRef.doc(_recepientId).get();
      if (conversation.exists) {
        return onSuccess(conversation.data()?["conversationID"]);
      } else {
        var _conversationRef = _ref.doc();
        await _conversationRef.set({
          "members": [_currentUserId, _recepientId],
          "ownerID": _currentUserId,
          "messages": [],
        });
        return onSuccess(_conversationRef.id);
      }
    } catch (e) {
      print(e);
    }
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
