import 'package:flutter/material.dart';
import 'dart:html' as html;

class DownloadAppButton extends StatelessWidget {
  const DownloadAppButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        html.window.open("/app.apk", "App");
      },
      icon: const Icon(Icons.android),
    );
  }
}
