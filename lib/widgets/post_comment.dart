import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_instagram_clone2/data/model/usermodel.dart';
import 'package:flutter_instagram_clone2/utils/cached_image.dart';
import 'package:uuid/uuid.dart';

class PostCommentWidget extends StatefulWidget {
  final String uid;

  const PostCommentWidget(this.uid, {super.key});

  @override
  State<PostCommentWidget> createState() => _PostCommentWidgetState();
}

class _PostCommentWidgetState extends State<PostCommentWidget> {
  final commentController = TextEditingController();
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
   final FirebaseAuth _auth = FirebaseAuth.instance;
     final CollectionReference reelsCollectionReference = FirebaseFirestore.instance.collection('posts');

  Future<UserModel> getUser() async {
    try {
      final user = await _firebaseFirestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
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

    Future<bool> comment({
    required String comment,
    required String uidd,
  }) async {
    var commentId = const Uuid().v4();
    UserModel user = await getUser();
    await reelsCollectionReference
        .doc(uidd)
        .collection('comments')
        .doc(commentId)
        .set({
      'comment': comment,
      'username': user.username,
      'profileImage': user.profile,
      'commentId': commentId
    });
    return true;
  }
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25), topRight: Radius.circular(25)),
      child: Container(
        color: Colors.white,
        height: 300,
        child: Stack(
          children: [
            Positioned(
              top: 10,
              left: 160,
              child: Container(
                width: 100,
                height: 5,
                decoration: BoxDecoration(
                    color: Colors.grey.shade500,
                    borderRadius: BorderRadius.circular(50)),
              ),
            ),
            StreamBuilder<QuerySnapshot>(
              stream: reelsCollectionReference
                  .doc(widget.uid)
                  .collection('comments')
                  .snapshots(),
              builder: (context, snapshot) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: ListView.builder(
                    itemCount:
                        snapshot.data == null ? 0 : snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      if (!snapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      return commentTile(snapshot.data!.docs[index].data());
                    },
                  ),
                );
              },
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 60,
                width: double.infinity,
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      height: 45,
                      width: 260,
                      child: TextField(
                        controller: commentController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                            hintText: 'Add a comment',
                            border: InputBorder.none),
                      ),
                    ),
                    IconButton(
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          if (commentController.text.isNotEmpty) {
                            comment(
                                comment: commentController.text,
                                uidd: widget.uid);
                          }
                          setState(() {
                            commentController.clear();
                          });
                        },
                        icon: const Icon(Icons.send))
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget commentTile(final snapshot) {
    return ListTile(
      leading: ClipOval(
        child: SizedBox(
            height: 25,
            width: 25,
            child: CachedImage(snapshot['profileImage'])),
      ),
      title: Text(
        snapshot['username'],
        style:
            const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
      ),
      subtitle: Text(
        snapshot['comment'],
        style: const TextStyle(color: Colors.black),
      ),
    );
  }
}
