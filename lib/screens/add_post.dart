import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_instagram_clone2/screens/add_caption.dart';
import 'package:photo_manager/photo_manager.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final List<Widget> mediaList = [];
  final List<File> path = [];
  File? _file;
  int currentPage = 0;
  int? lastPage;
  int value = 0;

  @override
  void initState() {
    super.initState();
    _requestPermission();
  }

  Future<void> _requestPermission() async {
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    if (ps.isAuth) {
      _fetchNewMedia();
    } else {
      _showPermissionDialog();
    }
  }

  Future<void> _showPermissionDialog() async {
    bool openSettings = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Permission required'),
          content: const Text(
              'This app needs camera and gallery access to add posts. Please grant the permissions in settings.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
    if (openSettings) {
      PhotoManager.openSetting();
    }
  }

  _fetchNewMedia() async {
    lastPage = currentPage;
    final List<AssetPathEntity> album =
        await PhotoManager.getAssetPathList(type: RequestType.image);
    final List<AssetEntity> media =
        await album[0].getAssetListPaged(page: currentPage, size: 60);

    for (var asset in media) {
      if (asset.type == AssetType.image) {
        final file = await asset.file;
        if (file != null) {
          path.add(File(file.path));
          _file = path[0];
        }
      }
    }
    List<Widget> temp = [];
    for (var asset in media) {
      temp.add(FutureBuilder(
          future: asset.thumbnailDataWithSize(const ThumbnailSize(200, 200)),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done &&
                snapshot.data != null) {
              return Stack(
                children: [
                  Positioned.fill(
                      child: Image.memory(
                    snapshot.data!,
                    fit: BoxFit.cover,
                  ))
                ],
              );
            }
            return Container();
          }));
    }
    setState(() {
      mediaList.addAll(temp);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'New Post',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: false,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: TextButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AddCaptionScreen(
                                  file: _file!,
                                )));
                  },
                  child: const Text(
                    'Next',
                    style: TextStyle(fontSize: 15, color: Colors.blue),
                  )),
            ),
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
                height: 375,
                child: mediaList.isNotEmpty
                    ? GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 1,
                                mainAxisSpacing: 1,
                                crossAxisSpacing: 1),
                        itemBuilder: (context, index) {
                          return mediaList[value];
                        })
                    : const Center(child: Text('No Media available'))),
            Container(
              width: double.infinity,
              height: 40,
              color: Colors.white,
              child: const Row(
                children: [
                  SizedBox(width: 10),
                  Text(
                    'Recent',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            Expanded(
              child: GridView.builder(
                  shrinkWrap: true,
                  itemCount: mediaList.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 1,
                      crossAxisSpacing: 2),
                  itemBuilder: (context, index) {
                    return GestureDetector(
                        onTap: () {
                          setState(() {
                            value = index;
                            _file = path[index];
                          });
                        },
                        child: mediaList[index]);
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
