import 'package:flutter/material.dart';
import 'package:flutter_instagram_clone2/data/firebase_service/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback show;
  const LoginScreen(this.show, {super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final email = TextEditingController();
  FocusNode emailF = FocusNode();
  final password = TextEditingController();
  FocusNode passwordF = FocusNode();
  @override
  void dispose() {
    super.dispose();
    email.dispose();
    password.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(width: 96, height: 100),
            Center(
              child: Image.asset('images/logo.jpg'),
            ),
            const SizedBox(height: 120),
            textField(email, emailF, 'Email', Icons.email),
            const SizedBox(height: 15),
            textField(password, passwordF, 'Password', Icons.lock),
            const SizedBox(height: 15),
            forget(),
            const SizedBox(height: 15),
            login(),
            const SizedBox(height: 15),
            have()
          ],
        ),
      ),
    );
  }

  Widget have() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const Text(
            "Don't have account?  ",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          GestureDetector(
            onTap: widget.show,
            child: const Text(
              "Sign up ",
              style: TextStyle(
                  fontSize: 15,
                  color: Colors.blue,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget login() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: InkWell(
        onTap: () async {
          await Authentications()
              .login(email: email.text, password: password.text);
        },
        child: Container(
          alignment: Alignment.center,
          width: double.infinity,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Text(
            'Login',
            style: TextStyle(
              fontSize: 23,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Padding forget() {
    return Padding(
      padding: const EdgeInsets.only(left: 230),
      child: GestureDetector(
        onTap: () {},
        child: const Text(
          'Forgot password?',
          style: TextStyle(
            fontSize: 13,
            color: Colors.blue,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Padding textField(TextEditingController controll, FocusNode focusNode,
      String typename, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
        ),
        child: TextField(
          style: const TextStyle(fontSize: 18, color: Colors.black),
          controller: controll,
          focusNode: focusNode,
          decoration: InputDecoration(
            hintText: typename,
            prefixIcon: Icon(
              icon,
              color: focusNode.hasFocus ? Colors.black : Colors.grey[600],
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: const BorderSide(
                width: 2,
                color: Colors.grey,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: const BorderSide(
                width: 2,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
