import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_instagram_clone2/screens/posts.dart';
import 'package:flutter_instagram_clone2/screens/profile.dart';
import 'package:flutter_instagram_clone2/utils/cached_image.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final searchController = TextEditingController();
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  bool show = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
          child: CustomScrollView(
        shrinkWrap: true,
        slivers: [
          searchBox(),
          if (!show)
            StreamBuilder(
              stream: _firebaseFirestore.collection('posts').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SliverToBoxAdapter(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                return SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final snap = snapshot.data!.docs[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PostScreen(snap.data()),
                                ));
                          },
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.grey,
                            ),
                            child: CachedImage(snap['postImage']),
                          ),
                        );
                      },
                      childCount: snapshot.data!.docs.length,
                    ),
                    gridDelegate: SliverQuiltedGridDelegate(
                        crossAxisCount: 3,
                        mainAxisSpacing: 3,
                        crossAxisSpacing: 3,
                        pattern: const [
                          QuiltedGridTile(2, 1),
                          QuiltedGridTile(2, 2),
                          QuiltedGridTile(1, 1),
                          QuiltedGridTile(1, 1),
                          QuiltedGridTile(1, 1),
                        ]));
              },
            ),
          if (show)
            StreamBuilder(
                stream: _firebaseFirestore
                    .collection('users')
                    .where('username',
                        isGreaterThanOrEqualTo: searchController.text)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const SliverToBoxAdapter(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  return SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                    final snap = snapshot.data!.docs[index];
                    return Column(
                      children: [
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ProfileScreen(uid: snap.id),
                                ));
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                ClipOval(
                                  child: SizedBox(
                                    height: 50,
                                    width: 50,
                                    child: CachedImage(snap['profile']),
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Text(
                                  snap['username'],
                                  style: const TextStyle(fontSize: 18),
                                )
                              ],
                            ),
                          ),
                        ),
                        const Divider()
                      ],
                    );
                  }, childCount: snapshot.data!.docs.length));
                })
        ],
      )),
    );
  }

  SliverToBoxAdapter searchBox() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
        child: Container(
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey.shade300),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const SizedBox(width: 10),
                    const Icon(
                      Icons.search,
                      color: Colors.black,
                      size: 25,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            if (value.isNotEmpty) {
                              show = true;
                            } else {
                              show = false;
                            }
                          });
                        },
                        controller: searchController,
                        decoration: const InputDecoration(
                            hintText: 'Search',
                            hintStyle:
                                TextStyle(fontSize: 17, color: Colors.black),
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
