import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_instagram_clone2/data/firebase_service/firebase_auth.dart';
import 'package:flutter_instagram_clone2/widgets/post.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: SizedBox(
          width: 105,
          height: 28,
          child: Image.asset('images/instagram.jpg'),
        ),
        leading: const Icon(Icons.camera_alt_outlined,
            color: Colors.black, size: 25),
        actions: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.0),
            child: Icon(
              Icons.favorite_border_outlined,
              color: Colors.black,
              size: 25,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0),
            child: IconButton(
                onPressed: () {
                  Authentications().signOut();
                },
                icon: const Icon(Icons.send)),
          ),
        ],
        backgroundColor: Colors.white,
      ),
      body: CustomScrollView(
        slivers: [
          StreamBuilder(
            stream: _firebaseFirestore
                .collection('posts')
                .orderBy('time', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return PostWidget(snapshot.data!.docs[index].data());
                  },
                  childCount:
                      snapshot.data == null ? 0 : snapshot.data!.docs.length,
                ),
              );
            },
          )
        ],
      ),
    );
  }
}
