import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../models/post.dart';
import '../resources/storage_methods.dart';

class FirestoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // upload post
  Future<String> uploadPost(String description, Uint8List file, String uid,
      String username, String profImage) async {
    String res = "Some error occured";
    try {
      String photoUrl =
          await StorageMethods().uploadImagesToStorage("posts", file, true);

      String postId = Uuid().v1();
      Post post = Post(
          description: description,
          uid: uid,
          username: username,
          postId: postId,
          datePublished: DateTime.now(),
          postUrl: photoUrl,
          profImage: profImage,
          likes: []);

      _firestore.collection('posts').doc(postId).set(post.toJson());
      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<void> likePost(String postId, String uid, List likes) async {
    try {
      if (likes.contains(uid)) {
        await _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayRemove([uid]),
        });
      } else {
        await _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayUnion([uid]),
        });
      }
    } catch (err) {
      print(err.toString());
    }
  }

  Future<String> postComment(
    String postId,
    String text,
    String uid,
    String name,
    String profilePic,
  ) async {
    String res = 'success';
    try {
      if (text.isNotEmpty) {
        String commentId = const Uuid().v1();
        await _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .set({
          'profilePic': profilePic,
          'name': name,
          'uid': uid,
          'text': text,
          'commentId': commentId,
          'datePublished': DateTime.now(),
        });
      } else {
        res = 'Text is empty';
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  // deleting the post

  Future<void> deletePost(String postId) async {
    try {
      await _firestore.collection('posts').doc(postId).delete();
    } catch (err) {
      print(err.toString());
    }
  }

  Future<void> followUser(
    String uid,
    String followUid,
  ) async {
    try {
      DocumentSnapshot snap =
          await _firestore.collection('user').doc(uid).get();

      List following = (snap.data() as dynamic)['folowing'];

      if (following.contains(followUid)) {
        await _firestore.collection('user').doc(followUid).update({
          'folowers': FieldValue.arrayRemove([uid])
        });
        await _firestore.collection('user').doc(uid).update({
          'folowing': FieldValue.arrayRemove([followUid])
        });
      } else {
        await _firestore.collection('user').doc(followUid).update({
          'folowers': FieldValue.arrayUnion([uid])
        });
        await _firestore.collection('user').doc(uid).update({
          'folowing': FieldValue.arrayUnion([followUid])
        });
      }
    } catch (err) {
      print(err.toString());
    }
  }
}
