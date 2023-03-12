import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:soma_people_flutter/AuthProvider.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  User? userInfo;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Example app: Sign in with Apple'),
        ),
        body: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              child: SignInWithAppleButton(
                onPressed: () async {
                  User user = await signInWithApple();
                  print("displayName : ${user.displayName}");
                  print("user : ${user}");
                  print("refreshToken : ${user.refreshToken}");
                  print("name : ${user.email}");
                },
              ),
            ),
            Text(
              "안녕하세요 ${userInfo?.displayName} 님",
              textAlign: TextAlign.center,
            ),
            Text(
              "email : ${userInfo?.email}",
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
