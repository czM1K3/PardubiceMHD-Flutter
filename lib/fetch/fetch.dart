import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:pardumhd/models/busPosition.dart';

Future<List<BusPosition>?> fetchFromApi() async {
  // const url = "http://185.8.164.5/api/buses";
  const url = kIsWeb && !kDebugMode
      ? "/api/buses"
      : "https://mhd.madhome.xyz/api/buses";
  try {
    var response = await post(Uri.parse(url));
    var decodedResponse = jsonDecode(utf8.decode(response.bodyBytes));
    var positions = List<BusPosition>.from(
      decodedResponse["data"].map((item) {
        return BusPosition.fromJson(item);
      }).toList(),
    );
    return positions.where((element) => element.lineName != "MAN").toList();
  } catch (e) {
    return null;
  }
}
