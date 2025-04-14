import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType { Text, Image }

class Message {
  final String senderID;
  final MessageType type;
  final String message;
  final Timestamp timestamp;

  Message({required this.message,required this.senderID,required this.timestamp,required this.type});
}
