import 'package:chatify/models/message.dart';
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

class Conversations {
  final String id;
  final List<String> members;
  final List<Message> messages;
  final String ownerID;

  Conversations({
    required this.id,
    required this.members,
    required this.messages,
    required this.ownerID,
  });

  factory Conversations.fromFirestore(DocumentSnapshot _snapshot) {
    final _data = _snapshot.data() as Map<String, dynamic>;
    List<dynamic> _rawMessages = _data["messages"] ?? [];
    List<Message> _messages =
        _rawMessages.map((dynamic _m) {
          final _msg = _m as Map<String, dynamic>;
          return Message(
            type: _msg["type"] == "text" ? MessageType.Text : MessageType.Image,
            message: _msg["message"] ?? "",
            timestamp: _msg["timestamp"] ?? Timestamp.now(),
            senderID: _msg["senderID"] ?? "",
          );
        }).toList();

    return Conversations(
      id: _snapshot.id,
      members: List<String>.from(_data["members"] ?? []),
      messages: _messages,
      ownerID: _data["ownerID"] ?? "",
    );
  }
}
