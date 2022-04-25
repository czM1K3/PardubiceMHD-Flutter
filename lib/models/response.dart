import 'package:pardumhd/models/busPosition.dart';

class Response {
  Response({required this.success, required this.data});

  bool success;
  List<BusPosition> data;
}
