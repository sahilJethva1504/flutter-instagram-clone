import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_instagram_clone2/data/firebase_service/firebase_firestore.dart';
import 'package:flutter_instagram_clone2/data/firebase_service/firebase_storage.dart';

class Authentications {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
          email: email.trim(), password: password.trim());
    } on FirebaseException catch (e) {
      throw Exception(e.message.toString());
    }
  }

  Future<void> signUp({
    required String email,
    required String username,
    required String bio,
    required String password,
    required String confirmPassword,
    required File profile,
  }) async {
    String url;
    try {
      if (email.isNotEmpty &&
          password.isNotEmpty &&
          username.isNotEmpty &&
          bio.isNotEmpty) {
        if (password == confirmPassword) {
          await _auth.createUserWithEmailAndPassword(
              email: email.trim(), password: password.trim());

          if (profile != File('')) {
            url = await StorageMethods().uploadImage('Profile Image', profile);
          } else {
            url = '';
          }

          await FirestoreMethods().createUser(
            email: email,
            username: username,
            bio: bio,
            profile: url == ''
                ? 'https://firebasestorage.googleapis.com/v0/b/instagram-8a227.appspot.com/o/person.png?alt=media&token=c6fcbe9d-f502-4aa1-8b4b-ec37339e78ab'
                : url,
          );
        } else {
          throw Exception('Password and Confirm Password should be same!');
        }
      } else {
        throw Exception('Enter all the Fields!');
      }
    } on FirebaseException catch (e) {
      throw Exception(e.message.toString());
    }
  }

  signOut() {
    try {
      _auth.signOut();
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
