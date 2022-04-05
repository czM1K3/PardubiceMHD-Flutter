import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';

Future<List<BusPosition>?> fetchFromApi() async {
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
    positions.sort(((a, b) => b.latitude.compareTo(a.latitude)));
    return positions.where((element) => element.lineName != "MAN").toList();
  } catch (e) {
    return null;
  }
}

class Response {
  Response({required this.success, required this.data});

  bool success;
  List<BusPosition> data;
}

class BusPosition {
  BusPosition({
    required this.vid,
    required this.lineName,
    required this.latitude,
    required this.longitude,
    required this.time,
    required this.last,
    required this.next,
    required this.destination,
  });

  String vid;
  String lineName;
  double latitude;
  double longitude;
  String? time;
  String? last;
  String? next;
  String? destination;

  BusPosition.fromJson(Map<String, dynamic> json)
      : vid = json['vid'],
        lineName = json['line_name'],
        latitude = json['gps_latitude'],
        longitude = json['gps_longitude'],
        time = json['time_difference'],
        last = json['last_stop_name'],
        next = json['current_stop_name'],
        destination = json['destination_name'];
}
