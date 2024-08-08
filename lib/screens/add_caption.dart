import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_instagram_clone2/data/firebase_service/firebase_firestore.dart';
import 'package:flutter_instagram_clone2/data/firebase_service/firebase_storage.dart';

class AddCaptionScreen extends StatefulWidget {
  const AddCaptionScreen({
    super.key,
    required this.file,
  });
  final File file;

  @override
  State<AddCaptionScreen> createState() => _AddCaptionScreenState();
}

class _AddCaptionScreenState extends State<AddCaptionScreen> {
  final captionController = TextEditingController();
  final locationController = TextEditingController();
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'New Post',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: TextButton(
                onPressed: () async {
                  setState(() {
                    isLoading = true;
                  });
                  String postUrl =
                      await StorageMethods().uploadImage('posts', widget.file);
                  await FirestoreMethods().createPost(
                      postImage: postUrl,
                      caption: captionController.text,
                      location: locationController.text);
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Share',
                  style: TextStyle(color: Colors.blue, fontSize: 15),
                )),
          )
        ],
      ),
      body: SafeArea(
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                ))
              : Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 5.0),
                        child: Row(
                          children: [
                            Container(
                              width: 65,
                              height: 65,
                              decoration: BoxDecoration(
                                  color: Colors.grey,
                                  image: DecorationImage(
                                      image: FileImage(widget.file),
                                      fit: BoxFit.cover)),
                            ),
                            const SizedBox(width: 10),
                            SizedBox(
                              width: 280,
                              height: 60,
                              child: TextField(
                                controller: captionController,
                                decoration: const InputDecoration(
                                    hintText: 'Write a caption...',
                                    border: InputBorder.none),
                              ),
                            )
                          ],
                        ),
                      ),
                      const Divider(),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: SizedBox(
                          width: 280,
                          height: 60,
                          child: TextField(
                            controller: locationController,
                            decoration: const InputDecoration(
                                hintText: 'Location', border: InputBorder.none),
                          ),
                        ),
                      )
                    ],
                  ),
                )),
    );
  }
}
