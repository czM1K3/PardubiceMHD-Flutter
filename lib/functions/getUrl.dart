import 'package:flutter/foundation.dart';

String getUrl() {
  return kIsWeb && !kDebugMode ? "/" : "https://mhd.madhome.xyz/";
}
