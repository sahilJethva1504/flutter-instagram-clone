import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_instagram_clone2/screens/editing.dart';
import 'package:photo_manager/photo_manager.dart';

class AddReelScreen extends StatefulWidget {
  const AddReelScreen({super.key});

  @override
  State<AddReelScreen> createState() => _AddReelScreenState();
}

class _AddReelScreenState extends State<AddReelScreen> {
  final List<Widget> mediaList = [];
  final List<File> path = [];
  File? _file;
  int currentPage = 0;
  int? lastPage;
  int value = 0;

  @override
  void initState() {
    _fetchNewMedia();
    super.initState();
  }

  _fetchNewMedia() async {
    lastPage = currentPage;
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    if (ps.isAuth) {
      List<AssetPathEntity> album =
          await PhotoManager.getAssetPathList(type: RequestType.video);

      if (album.isNotEmpty) {
        List<AssetEntity> media =
            await album[0].getAssetListPaged(page: currentPage, size: 60);

        for (var asset in media) {
          if (asset.type == AssetType.video) {
            final file = await asset.file;
            if (file != null) {
              path.add(File(file.path));
              _file = path.isNotEmpty ? path[0] : null;
            }
          }
        }
        List<Widget> temp = [];
        for (var asset in media) {
          temp.add(FutureBuilder(
              future:
                  asset.thumbnailDataWithSize(const ThumbnailSize(200, 200)),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.data != null) {
                  return Stack(
                    children: [
                      Positioned.fill(
                          child: Image.memory(
                        snapshot.data!,
                        fit: BoxFit.cover,
                      )),
                      if (asset.type == AssetType.video)
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Container(
                            alignment: Alignment.center,
                            width: 35,
                            height: 15,
                            child: Row(
                              children: [
                                Text(
                                  asset.videoDuration.inMinutes.toString(),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white),
                                ),
                                const Text(
                                  ':',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white),
                                ),
                                Text(
                                  asset.videoDuration.inSeconds.toString(),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white),
                                )
                              ],
                            ),
                          ),
                        )
                    ],
                  );
                }
                return Container();
              }));
        }
        setState(() {
          mediaList.addAll(temp);
        });
      } else {
        debugPrint("No albums found containing videos.");
        // Optionally, you can show a message or handle the case when there are no videos
      }
    } else {
      debugPrint("Permission denied.");
      // Handle the case when permission is denied
    }
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
          child: GridView.builder(
        shrinkWrap: true,
        itemCount: mediaList.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisExtent: 250,
            crossAxisSpacing: 3,
            mainAxisSpacing: 5),
        itemBuilder: (context, index) {
          return GestureDetector(
              onTap: () {
                setState(() {
                  value = index;
                  _file = path[index];
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditingScreen(_file!),
                      ));
                });
              },
              child: mediaList[index]);
        },
      )),
    );
  }
}
