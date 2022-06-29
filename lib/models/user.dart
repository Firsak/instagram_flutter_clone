import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String username;
  final String uid;
  final String email;
  final String bio;
  final List folowers;
  final List folowing;
  final String photoUrl;

  const User({
    required this.username,
    required this.uid,
    required this.email,
    required this.bio,
    required this.folowers,
    required this.folowing,
    required this.photoUrl,
  });

  Map<String, dynamic> toJson() => {
        'username': username,
        'uid': uid,
        'email': email,
        'bio': bio,
        'folowers': folowers,
        'folowing': folowing,
        'photoUrl': photoUrl,
      };

  static User fromSanp(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return User(
      username: snapshot['username'],
      uid: snapshot['uid'],
      email: snapshot['email'],
      bio: snapshot['bio'],
      folowers: snapshot['folowers'],
      folowing: snapshot['folowing'],
      photoUrl: snapshot['photoUrl'],
    );
  }
}
