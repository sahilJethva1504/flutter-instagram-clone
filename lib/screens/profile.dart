import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_instagram_clone2/data/firebase_service/firebase_auth.dart';
import 'package:flutter_instagram_clone2/data/firebase_service/firebase_firestore.dart';
import 'package:flutter_instagram_clone2/data/model/usermodel.dart';
import 'package:flutter_instagram_clone2/screens/login.dart';
import 'package:flutter_instagram_clone2/screens/posts.dart';
import 'package:flutter_instagram_clone2/utils/cached_image.dart';

class ProfileScreen extends StatefulWidget {
  final String uid;
  const ProfileScreen({
    super.key,
    required this.uid,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  int postLength = 0;
  bool yours = false;
  List following = [];
  bool follow = false;

  @override
  void initState() {
    getData();
    if (widget.uid == _auth.currentUser!.uid) {
      setState(() {
        yours = true;
      });
    }

    super.initState();
  }

  getData() async {
    DocumentSnapshot snap = await _firebaseFirestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .get();
    following = (snap.data()! as dynamic)['following'];
    if (following.contains(widget.uid)) {
      setState(() {
        follow = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
          backgroundColor: Colors.grey.shade100,
          appBar: AppBar(
            title: const Text('Profile'),
            centerTitle: false,
            backgroundColor: Colors.white,
          ),
          body: SafeArea(
              child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: FutureBuilder(
                    future: FirestoreMethods().getUser(uidd: widget.uid),
                    builder: ((context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.black),
                          ),
                        );
                      }
                      return head(snapshot.data!);
                    })),
              ),
              StreamBuilder(
                  stream: _firebaseFirestore
                      .collection('posts')
                      .where('uid', isEqualTo: widget.uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const SliverToBoxAdapter(
                        child: Center(
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.black),
                          ),
                        ),
                      );
                    }
                    postLength = snapshot.data!.docs.length;
                    return SliverGrid(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final snap = snapshot.data!.docs[index];
                        return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          PostScreen(snap.data())));
                            },
                            child: CachedImage(snap['postImage']));
                      }, childCount: postLength),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 2,
                              mainAxisSpacing: 2),
                    );
                  })
            ],
          ))),
    );
  }

  Widget head(UserModel user) {
    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 13.0, vertical: 13.0),
                child: ClipOval(
                  child: SizedBox(
                      width: 80, height: 80, child: CachedImage(user.profile)),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const SizedBox(width: 40),
                      Text(
                        postLength.toString(),
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 57),
                      StreamBuilder<DocumentSnapshot>(
                        stream: _firebaseFirestore
                            .collection('users')
                            .doc(widget.uid)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Text('0',
                                style: TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold));
                          }
                          return Text(
                            (snapshot.data!['followers'] as List)
                                .length
                                .toString(),
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          );
                        },
                      ),
                      const SizedBox(width: 62),
                      StreamBuilder<DocumentSnapshot>(
                        stream: _firebaseFirestore
                            .collection('users')
                            .doc(widget.uid)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Text('0',
                                style: TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold));
                          }
                          return Text(
                            (snapshot.data!['following'] as List)
                                .length
                                .toString(),
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          );
                        },
                      ),
                    ],
                  ),
                  const Row(
                    children: [
                      SizedBox(width: 30),
                      Text(
                        'Posts',
                        style: TextStyle(
                          fontSize: 13,
                        ),
                      ),
                      SizedBox(width: 25),
                      Text(
                        'Followers',
                        style: TextStyle(
                          fontSize: 13,
                        ),
                      ),
                      SizedBox(width: 19),
                      Text(
                        'Following',
                        style: TextStyle(
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.username,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 5),
                Text(
                  user.bio,
                  style: const TextStyle(fontWeight: FontWeight.w300),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Visibility(
            visible: !follow,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 15.0, vertical: 4),
              child: GestureDetector(
                onTap: () {
                  if (yours == false) {
                    FirestoreMethods().follow(uid: widget.uid);
                    setState(() {
                      follow = true;
                    });
                  }
                },
                child: Container(
                  alignment: Alignment.center,
                  height: 35,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: yours ? Colors.white : Colors.blue,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                          color: yours ? Colors.grey.shade400 : Colors.blue)),
                  child: yours
                      ? const Text('Edit Profile')
                      : const Text(
                          'Follow',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ),
            ),
          ),
          Visibility(
            visible: follow,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 15.0, vertical: 4),
              child: GestureDetector(
                onTap: () {
                  if (yours == false) {
                    FirestoreMethods().unfollow(uid: widget.uid);
                    setState(() {
                      follow = false;
                    });
                  }
                },
                child: Container(
                  alignment: Alignment.center,
                  height: 35,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: Colors.grey.shade400)),
                  child: const Text('Unfollow'),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 4),
            child: GestureDetector(
              onTap: () {
                Authentications().signOut();
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => LoginScreen(() {})));
              },
              child: Container(
                alignment: Alignment.center,
                height: 35,
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: Colors.grey.shade400)),
                child: const Text('Sign Out'),
              ),
            ),
          ),
          const SizedBox(height: 10),
          const SizedBox(
            width: double.infinity,
            height: 40,
            child: TabBar(
              indicatorColor: Colors.black,
              dividerHeight: 0,
              indicatorSize: TabBarIndicatorSize.tab,
              unselectedLabelColor: Colors.grey,
              labelColor: Colors.black,
              tabs: [
                Icon(Icons.grid_on_sharp),
                Icon(Icons.video_collection_rounded),
                Icon(Icons.person),
              ],
            ),
          ),
          const SizedBox(height: 5)
        ],
      ),
    );
  }
}
