import 'package:cloud_firestore/cloud_firestore.dart';

class ConverstaionSnippet {
  final String id;
  final String conversationID;
  final String name;
  final String image;
  final String lastMessage;
  final int unseenCount;
  final Timestamp timestamp;

  ConverstaionSnippet({
    required this.id,
    required this.conversationID,
    required this.name,
    required this.image,
    required this.lastMessage,
    required this.unseenCount,
    required this.timestamp,
  });

  factory ConverstaionSnippet.fromFirestore(DocumentSnapshot _snapshot) {
    final _data = _snapshot.data() as Map<String, dynamic>;
    return ConverstaionSnippet(
      id: _snapshot.id,
      conversationID: _data['conversationID'] ?? "",
      name: _data['name'] ?? "",
      image: _data['image'],
      lastMessage: _data['lastMessage'] ?? "",
      unseenCount: _data['unseencount'] ?? "",
      timestamp: _data['timestamp'] ?? Timestamp.now(),
    );
  }
}
