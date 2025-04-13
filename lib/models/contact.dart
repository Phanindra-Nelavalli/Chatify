import 'package:cloud_firestore/cloud_firestore.dart';

class Contact {
  final String name;
  final String email;
  final String image;
  final String id;
  final Timestamp timestamp;

  Contact({
    required this.name,
    required this.email,
    required this.image,
    required this.id,
    required this.timestamp,
  });

  factory Contact.fromFirestore(DocumentSnapshot _snapshot) {
    var _data = _snapshot.data() as Map<String, dynamic>?;
    return Contact(
      name: _data?["name"] ?? "",
      email: _data?["email"] ?? "",
      image: _data?["image"] ?? "",
      id: _data?["id"] ?? "",
      timestamp: _data?["timestamp"] ?? Timestamp.now(),
    );
  }
}
