import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_instagram_clone2/data/model/usermodel.dart';
import 'package:uuid/uuid.dart';

class FirestoreMethods {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<bool> createUser(
      {required String email,
      required String username,
      required String bio,
      required String profile}) async {
    await _firebaseFirestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .set({
      'email': email,
      'username': username,
      'bio': bio,
      'profile': profile,
      'followers': [],
      'following': []
    });
    return true;
  }

  Future<UserModel> getUser({String? uidd}) async {
    try {
      final user = await _firebaseFirestore
          .collection('users')
          .doc(uidd ?? _auth.currentUser!.uid)
          .get();
      final snapUser = user.data()!;
      return UserModel(
          email: snapUser['email'] ?? '',
          username: snapUser['username'] ?? '',
          bio: snapUser['bio'] ?? '',
          profile: snapUser['profile'] ?? '',
          followers: List<String>.from(snapUser['followers'] ?? ''),
          following: List<String>.from(
            snapUser['following'] ?? '',
          ));
    } on FirebaseException catch (e) {
      throw Exception(e.message.toString());
    }
  }

  Future<bool> createPost({
    required String postImage,
    required String caption,
    required String location,
  }) async {
    var uid = const Uuid().v4();
    DateTime date = DateTime.now();
    UserModel user = await getUser();
    await _firebaseFirestore.collection('posts').doc(uid).set({
      'postImage': postImage,
      'username': user.username,
      'profileImage': user.profile,
      'caption': caption,
      'location': location,
      'uid': _auth.currentUser!.uid,
      'postId': uid,
      'likes': [],
      'time': date
    });
    return true;
  }

  Future<bool> createReel({
    required String video,
    required String caption,
  }) async {
    var uid = const Uuid().v4();
    DateTime date = DateTime.now();
    UserModel user = await getUser();
    await _firebaseFirestore.collection('reels').doc(uid).set({
      'reel': video,
      'username': user.username,
      'profileImage': user.profile,
      'caption': caption,
      'uid': _auth.currentUser!.uid,
      'postId': uid,
      'likes': [],
      'time': date
    });
    return true;
  }

  Future<String> like({
    required List like,
    required String type,
    required String uid,
    required String postId,
  }) async {
    String result = 'Some error occured';
    try {
      if (like.contains(uid)) {
        _firebaseFirestore.collection(type).doc(postId).update({
          'likes': FieldValue.arrayRemove([uid])
        });
      } else {
        _firebaseFirestore.collection(type).doc(postId).update({
          'likes': FieldValue.arrayUnion([uid])
        });
      }
      result = 'Success';
    } on Exception catch (e) {
      result = e.toString();
    }
    return result;
  }

  Future<String> follow({required String uid}) async {
    String result = 'Some error occured';
    DocumentSnapshot snap = await _firebaseFirestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .get();
    List follow = (snap.data()! as dynamic)['following'];
    try {
      if (follow.contains(uid)) {
        result = await unfollow(uid: uid);
      } else {
        await _firebaseFirestore.collection('users').doc(_auth.currentUser!.uid).update({
          'following': FieldValue.arrayUnion([uid])
        });
        await _firebaseFirestore.collection('users').doc(uid).update({
          'followers': FieldValue.arrayUnion([_auth.currentUser!.uid])
        });
        result = 'Success';
      }
    } on Exception catch (e) {
      result = e.toString();
    }
    return result;
  }

  Future<String> unfollow({required String uid}) async {
    String result = 'Some error occured';
    try {
      await _firebaseFirestore.collection('users').doc(_auth.currentUser!.uid).update({
        'following': FieldValue.arrayRemove([uid])
      });
      await _firebaseFirestore.collection('users').doc(uid).update({
        'followers': FieldValue.arrayRemove([_auth.currentUser!.uid])
      });
      result = 'Success';
    } on Exception catch (e) {
      result = e.toString();
    }
    return result;
  }
}
