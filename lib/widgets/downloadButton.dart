import 'package:flutter/material.dart';
import 'package:pardumhd/functions/getUrl.dart';
import 'package:url_launcher/url_launcher.dart';

class DownloadAppButton extends StatelessWidget {
  const DownloadAppButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () async {
        Uri _url = Uri.parse(getUrl() + "app.apk");
        if (!await launchUrl(_url)) throw 'Could not launch $_url';
      },
      icon: const Icon(Icons.android),
    );
  }
}
