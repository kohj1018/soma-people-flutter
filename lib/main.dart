import 'package:flutter/material.dart';
import 'package:soma_people_flutter/notification/fcmSetting.dart';
import 'package:soma_people_flutter/screen/webview_screen.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // notification 설정
  String? firebaseToken = await fcmSetting();

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WebViewScreen(
        firebaseToken: firebaseToken,
      ),
    ),
  );
}
