import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType { Text, Image }

class Message {
  final String senderID;
  final MessageType type;
  final String message;
  final Timestamp timestamp;

  Message({required this.message,required this.senderID,required this.timestamp,required this.type});

  factory Message.fromJSON(Map<String, dynamic> json) {
    return Message(
      message: json['message'] as String,
      senderID: json['senderID'] as String,
      timestamp: json['timestamp'] as Timestamp,
      type: MessageType.values[json['type'] as int],
    );
  }
  Map<String, dynamic> toJSON() {
    return {
      'message': message,
      'senderID': senderID,
      'timestamp': timestamp,
      'type': type.index,
    };
  }
}
