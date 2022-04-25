import 'package:pardumhd/models/busPosition.dart';

class Response {
  Response({required this.success, required this.data});

  bool success;
  List<BusPosition> data;

  Response.fromJson(Map<String, dynamic> json)
      : success = json['success'],
        data = (json['data'] as List<dynamic>)
            .map((e) => BusPosition.fromJson(e))
            .toList();
}
