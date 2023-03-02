import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:image/image.dart' as image;
import 'package:image_picker/image_picker.dart' as image_picker;
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:path_provider/path_provider.dart';

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({Key? key}) : super(key: key);

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController controller;
  late final AndroidWebViewController androidController;
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    controller.runJavaScript('window.changePage($index)');
  }

  void initFilePicker() async {
    if (Platform.isAndroid) {
      androidController = (controller.platform as AndroidWebViewController);
      await androidController.setOnShowFileSelector(_androidFilePicker);
    }
  }

  Future<List<String>> _androidFilePicker(FileSelectorParams params) async {
    // if (params.acceptTypes.any((type) => type == 'image/*')) {
      final picker = image_picker.ImagePicker();
      final photo = await picker.pickImage(source: image_picker.ImageSource.gallery);

      if (photo == null) {
        return [];
      }

      final imageData = await photo.readAsBytes();
      final decodedImage = image.decodeImage(imageData)!;
      final scaledImage = image.copyResize(decodedImage, width: 500);
      final jpg = image.encodeJpg(scaledImage, quality: 90);

      final filePath = (await getTemporaryDirectory()).uri.resolve(
            './image_${DateTime.now().microsecondsSinceEpoch}.jpg',
          );
      final file = await File.fromUri(filePath).create(recursive: true);
      await file.writeAsBytes(jpg, flush: true);

      return [file.uri.toString()];
    // }

    return [];
  }

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
            onProgress: (int progress) {},
            onPageStarted: (String url) {},
            onPageFinished: (String url) {},
            onWebResourceError: (WebResourceError error) {},
            onNavigationRequest: (NavigationRequest request) {
              // if (request.url.startsWith('https://www.youtube.com/')) {
              //   return NavigationDecision.prevent;
              // }
              return NavigationDecision.navigate;
            }),
      )
      ..setUserAgent(Platform.isIOS
          ? 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_1_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.1 Mobile/15E148 Safari/604.1'
          : 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.94 Mobile Safari/537.36')
      ..enableZoom(false)
      ..loadRequest(Uri.parse('https://www.somapeople.kr'));

    initFilePicker();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        var future = Platform.isAndroid
            ? androidController.canGoBack()
            : controller.canGoBack();
        future.then((canGoBack) => {
              if (canGoBack)
                {
                  Platform.isAndroid
                      ? androidController.goBack()
                      : controller.goBack()
                }
              else
                {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('앱 종료'),
                      content: const Text('소마인을 정말 종료하시겠어요? 😥'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            SystemNavigator.pop();
                          },
                          child: const Text('예'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('아니오'),
                        ),
                      ],
                    ),
                  ),
                }
            });
        return Future.value(false);
      },
      child: SafeArea(
        child: Scaffold(
          body: Platform.isAndroid
              ? AndroidWebViewWidget(
                  PlatformWebViewWidgetCreationParams(
                    controller: androidController,
                  ),
                ).build(context)
              : WebViewWidget(controller: controller),
          bottomNavigationBar: BottomNavigationBar(
            backgroundColor: Colors.white,
            selectedItemColor: const Color(0xff374151),
            unselectedItemColor: const Color(0xffE5E7EB),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: '홈',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.article),
                label: '게시판',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: '프로필',
              ),
            ],
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
          ),
        ),
      ),
    );
  }
}
