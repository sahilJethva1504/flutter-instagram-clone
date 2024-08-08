// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_instagram_clone2/data/firebase_service/firebase_firestore.dart';
import 'package:flutter_instagram_clone2/utils/cached_image.dart';
import 'package:flutter_instagram_clone2/widgets/like_animation.dart';
import 'package:flutter_instagram_clone2/widgets/reel_comment.dart';
import 'package:video_player/video_player.dart';

class ReelWidget extends StatefulWidget {
  final snapshot;
  const ReelWidget(this.snapshot, {super.key});

  @override
  State<ReelWidget> createState() => _ReelWidgetState();
}

class _ReelWidgetState extends State<ReelWidget> with WidgetsBindingObserver {
  late VideoPlayerController controller;
  bool play = true;
  int commentLength = 0;
  bool isAnimating = false;
  String user = '';
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    controller =
        VideoPlayerController.networkUrl(Uri.parse(widget.snapshot['reel']))
          ..initialize().then((value) {
            setState(() {
              controller.setLooping(true);
              controller.setVolume(1);
              controller.play();
            });
          });
    user = _auth.currentUser?.uid ?? '';
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      controller.pause();
    } else if (state == AppLifecycleState.resumed && play) {
      controller.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        GestureDetector(
          onDoubleTap: () {
            setState(() {
              FirestoreMethods().like(
                  like: widget.snapshot['likes'],
                  type: 'reels',
                  uid: user,
                  postId: widget.snapshot['postId']);
              isAnimating = true;
            });
          },
          onTap: () {
            setState(() {
              play = !play;
            });
            if (play) {
              controller.play();
            } else {
              controller.pause();
            }
          },
          child: SizedBox(
            width: double.infinity,
            height: 812,
            child: VideoPlayer(controller),
          ),
        ),
        if (!play)
          const Center(
            child: CircleAvatar(
              backgroundColor: Colors.white24,
              radius: 35,
              child: Icon(
                Icons.play_arrow_rounded,
                size: 35,
                color: Colors.white,
              ),
            ),
          ),
        Center(
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: isAnimating ? 1 : 0,
            child: LikeAnimation(
              isAnimating: isAnimating,
              duration: const Duration(milliseconds: 400),
              child: const Icon(
                Icons.favorite,
                size: 100,
                color: Colors.white,
              ),
              end: () {
                setState(() {
                  isAnimating = false;
                });
              },
            ),
          ),
        ),
        Positioned(
          top: 430,
          right: 15,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 5.0),
                child: LikeAnimation(
                    isAnimating: widget.snapshot['likes'].contains(user),
                    child: IconButton(
                        onPressed: () {
                          FirestoreMethods().like(
                              like: widget.snapshot['likes'],
                              type: 'reels',
                              uid: user,
                              postId: widget.snapshot['postId']);
                        },
                        icon: Icon(
                          widget.snapshot['likes'].contains(user)
                              ? Icons.favorite
                              : Icons.favorite_border_outlined,
                          color: widget.snapshot['likes'].contains(user)
                              ? Colors.red
                              : Colors.white,
                          size: 30,
                        ))),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Text(
                  widget.snapshot['likes'].length.toString(),
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 5.0),
                child: IconButton(
                  onPressed: () {
                    showBottomSheet(
                      enableDrag: true,
                      backgroundColor: Colors.transparent,
                      context: context,
                      builder: (context) {
                        return Padding(
                          padding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).viewInsets.bottom),
                          child: DraggableScrollableSheet(
                              maxChildSize: 0.5,
                              initialChildSize: 0.5,
                              minChildSize: 0.2,
                              builder: (context, scrollController) {
                                return ReelCommentWidget(
                                    widget.snapshot['postId']);
                              }),
                        );
                      },
                    );
                  },
                  icon: const Icon(Icons.mode_comment_outlined,
                      color: Colors.white, size: 30),
                ),
              ),
              Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('reels')
                        .doc(widget.snapshot['postId'])
                        .collection('comments')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Text('0');
                      }
                      final commentCount = snapshot.data!.docs.length;
                      return Text(
                        commentCount.toString(),
                        style:
                            const TextStyle(fontSize: 18, color: Colors.white),
                      );
                    },
                  )),
              const Padding(
                padding: EdgeInsets.only(bottom: 5.0),
                child: Icon(
                  Icons.send,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 20.0),
                child: Text(
                  '0',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 40,
          left: 20,
          right: 0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ClipOval(
                    child: SizedBox(
                      height: 35,
                      width: 35,
                      child: CachedImage(widget.snapshot['profileImage']),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    widget.snapshot['username'],
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 60,
                    height: 25,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 1),
                        borderRadius: BorderRadius.circular(5)),
                    child: const Text(
                      'Follow',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Text(
                  widget.snapshot['caption'],
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
