import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_instagram_clone2/screens/add.dart';
import 'package:flutter_instagram_clone2/screens/explore.dart';

import 'package:flutter_instagram_clone2/screens/home.dart';
import 'package:flutter_instagram_clone2/screens/profile.dart';
import 'package:flutter_instagram_clone2/screens/reels.dart';


class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

int _currentIndex = 0;

class _NavigationScreenState extends State<NavigationScreen> {
  late PageController pageController;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  void initState() {
    super.initState();
    pageController = PageController();
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  onPageChanged(int page) {
    setState(() {
      _currentIndex = page;
    });
  }

  navigationTapped(int page) {
    pageController.jumpToPage(page);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        currentIndex: _currentIndex,
        onTap: navigationTapped,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: '',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.camera),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'images/instagram-reels-icon.png',
              height: 20,
            ),
            label: '',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '',
          ),
        ],
      ),
      body: PageView(
        controller: pageController,
        onPageChanged: onPageChanged,
        children:  [
          const HomeScreen(),
          const ExploreScreen(),
          const AddScreen(),
          const ReelsScreen(),
          ProfileScreen(uid:_auth.currentUser!.uid,)
        ],
      ),
    );
  }
}