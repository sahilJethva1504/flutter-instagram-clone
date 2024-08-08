import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_instagram_clone2/widgets/reel.dart';

class ReelsScreen extends StatefulWidget {
  const ReelsScreen({super.key});

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> {
  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore firebasefirestore = FirebaseFirestore.instance;
    return Scaffold(
      body: SafeArea(
          child: StreamBuilder(
        stream: firebasefirestore
            .collection('reels')
            .orderBy('time', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          return PageView.builder(
              scrollDirection: Axis.vertical,
              controller: PageController(initialPage: 0, viewportFraction: 1),
              itemCount: snapshot.data == null ? 0 : snapshot.data?.docs.length,
              itemBuilder: (context, index) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return ReelWidget(snapshot.data!.docs[index].data());
              });
        },
      )),
    );
  }
}
