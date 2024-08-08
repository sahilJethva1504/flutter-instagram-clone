import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_instagram_clone2/data/firebase_service/firebase_firestore.dart';
import 'package:flutter_instagram_clone2/utils/cached_image.dart';
import 'package:flutter_instagram_clone2/widgets/like_animation.dart';
import 'package:flutter_instagram_clone2/widgets/post_comment.dart';

class PostWidget extends StatefulWidget {
  final Map<String, dynamic> snapshot;
  const PostWidget(this.snapshot, {super.key});

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  bool isAnimating = false;
  String user = '';
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser?.uid ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final likes = widget.snapshot['likes'] ?? [];
    final postImage = widget.snapshot['postImage'] ?? '';
    final profileImage = widget.snapshot['profileImage'] ?? '';
    final username = widget.snapshot['username'] ?? '';
    final location = widget.snapshot['location'] ?? '';
    final caption = widget.snapshot['caption'] ?? '';
    final postId = widget.snapshot['postId'] ?? '';
    final time = widget.snapshot['time'] != null ? widget.snapshot['time'].toDate() : DateTime.now();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 54,
            color: Colors.white,
            child: ListTile(
              leading: ClipOval(
                child: SizedBox(
                  width: 35,
                  height: 35,
                  child: CachedImage(profileImage),
                ),
              ),
              title: Text(
                username,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              subtitle: Text(
                location,
                style: const TextStyle(fontSize: 13),
              ),
              trailing: const Icon(Icons.more_vert),
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onDoubleTap: () {
              setState(() {
                FirestoreMethods().like(
                    like: likes,
                    type: 'posts',
                    uid: user,
                    postId: postId);
                isAnimating = true;
              });
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 375,
                  child: CachedImage(postImage),
                ),
                AnimatedOpacity(
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
              ],
            ),
          ),
          Container(
            width: double.infinity,
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Row(
                  children: [
                    LikeAnimation(
                        isAnimating: likes.contains(user),
                        child: IconButton(
                            onPressed: () {
                              setState(() {
                                FirestoreMethods().like(
                                    like: likes,
                                    type: 'posts',
                                    uid: user,
                                    postId: postId);
                              });
                            },
                            icon: likes.contains(user)
                                ? const Icon(
                                    Icons.favorite,
                                    color: Colors.red,
                                    size: 30,
                                  )
                                : const Icon(
                                    Icons.favorite_border_outlined,
                                    color: Colors.black,
                                    size: 30,
                                  ))),
                    const SizedBox(width: 10),
                    IconButton(
                      onPressed: () {
                        showBottomSheet(
                          enableDrag: true,
                          backgroundColor: Colors.transparent,
                          context: context,
                          builder: (context) {
                            return Padding(
                              padding: EdgeInsets.only(
                                  bottom:
                                      MediaQuery.of(context).viewInsets.bottom),
                              child: DraggableScrollableSheet(
                                  maxChildSize: 0.5,
                                  initialChildSize: 0.5,
                                  minChildSize: 0.2,
                                  builder: (context, scrollController) {
                                    return PostCommentWidget(postId);
                                  }),
                            );
                          },
                        );
                      },
                      icon: const Icon(
                        Icons.mode_comment_outlined,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.send,
                        size: 30,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.bookmark_border,
                        size: 30,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 15,
                    top: 4,
                    bottom: 8,
                  ),
                  child: Text(
                    '${likes.length} likes',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    children: [
                      Text(
                        username,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 7),
                      Text(
                        caption,
                        style: const TextStyle(fontSize: 16),
                      )
                    ],
                  ),
                ),
                StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('posts')
                      .doc(postId)
                      .collection('comments')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Text('0');
                    }
                    final commentCount = snapshot.data!.docs.length;
                    if (commentCount != 0) {
                      return Padding(
                        padding:
                            const EdgeInsets.only(left: 15, top: 12, bottom: 8),
                        child: GestureDetector(
                          onTap: () {
                            showBottomSheet(
                              enableDrag: true,
                              backgroundColor: Colors.transparent,
                              context: context,
                              builder: (context) {
                                return Padding(
                                  padding: EdgeInsets.only(
                                      bottom: MediaQuery.of(context)
                                          .viewInsets
                                          .bottom),
                                  child: DraggableScrollableSheet(
                                      maxChildSize: 0.5,
                                      initialChildSize: 0.5,
                                      minChildSize: 0.2,
                                      builder: (context, scrollController) {
                                        return PostCommentWidget(postId);
                                      }),
                                );
                              },
                            );
                          },
                          child: Text(
                            'View all $commentCount Comments',
                            style: const TextStyle(
                                fontSize: 16, color: Colors.grey),
                          ),
                        ),
                      );
                    }
                    return const SizedBox(
                      height: 0,
                      width: 0,
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 15, top: 12, bottom: 8),
                  child: Text(
                    formatDate(time, [yyyy, '-', mm, '-', dd]),
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
