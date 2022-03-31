import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';

Future<List<BusPosition>?> FetchFromApi() async {
  const url = kIsWeb ? "/api/buses" : "https://mhd.madhome.xyz/api/buses";
  try {
    var response = await post(Uri.parse(url));
    var decodedResponse = jsonDecode(utf8.decode(response.bodyBytes));
    var positions = List<BusPosition>.from(
      decodedResponse["data"].map((item) {
        return BusPosition(
          vid: item["vid"],
          lineName: item["line_name"],
          latitude: item["gps_latitude"],
          longitude: item["gps_longitude"],
          time: item["time_difference"],
          last: item["last_stop_name"],
          next: item["current_stop_name"],
          destination: item["destination_name"],
        );
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
}
