import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_instagram_clone2/data/firebase_service/firebase_firestore.dart';
import 'package:flutter_instagram_clone2/data/firebase_service/firebase_storage.dart';
import 'package:video_player/video_player.dart';

class EditingScreen extends StatefulWidget {
  final File videoFile;
  const EditingScreen(this.videoFile, {super.key});

  @override
  State<EditingScreen> createState() => _EditingScreenState();
}

class _EditingScreenState extends State<EditingScreen> {
  final captionController = TextEditingController();
  late VideoPlayerController controller;
  bool isLoading = false;

  @override
  void initState() {
    controller = VideoPlayerController.file(widget.videoFile)
      ..initialize().then((_) {
        setState(() {
          controller.setLooping(true);
          controller.setVolume(1.0);
          controller.play();
        });
      });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text(
          'New Reel',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                ))
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40.0),
                          child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.8,
                              height: MediaQuery.of(context).size.height * 0.65,
                              child: controller.value.isInitialized
                                  ? AspectRatio(
                                      aspectRatio: controller.value.aspectRatio,
                                      child: VideoPlayer(controller),
                                    )
                                  : const Center(
                                      child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.black),
                                    ))),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 60,
                          width: 280,
                          child: TextField(
                            controller: captionController,
                            maxLines: 10,
                            decoration: const InputDecoration(
                                hintText: 'Write a caption...',
                                border: InputBorder.none),
                          ),
                        ),
                        const Divider(),
                        const SizedBox(height: 7),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                              alignment: Alignment.center,
                              height: 45,
                              width: 150,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  border:
                                      Border.all(color: Colors.black, width: 2),
                                  borderRadius: BorderRadius.circular(10)),
                              child: const Text(
                                'Save Draft',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                setState(() {
                                  isLoading = true;
                                  controller.pause();
                                });
                                String reelUrl = await StorageMethods()
                                    .uploadImage('Reels', widget.videoFile);
                                await FirestoreMethods().createReel(
                                    video: reelUrl,
                                    caption: captionController.text);
                                Navigator.of(context).pop();
                              },
                              child: Container(
                                alignment: Alignment.center,
                                height: 45,
                                width: 150,
                                decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(10)),
                                child: const Text(
                                  'Share',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                )),
    );
  }
}
