import 'package:flutter/material.dart';
import 'package:flutter_instagram_clone2/widgets/post.dart';

class PostScreen extends StatelessWidget {
  // ignore: prefer_typing_uninitialized_variables
  final snapshot;
  const PostScreen(this.snapshot, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(),
      body: SafeArea(child: PostWidget(snapshot)),
    );
  }
}
