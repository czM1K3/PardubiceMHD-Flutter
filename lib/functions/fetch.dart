import 'dart:convert';
import 'package:http/http.dart';
import 'package:pardumhd/functions/get_url.dart';
import 'package:pardumhd/models/bus_position.dart';
import 'package:pardumhd/models/response.dart' as response_model;

Future<List<BusPosition>?> fetchFromApi() async {
  var url = getUrl() + "api/buses";
  try {
    var response = await post(Uri.parse(url));
    var decodedResponse = jsonDecode(utf8.decode(response.bodyBytes));
    var positions = response_model.Response.fromJson(decodedResponse).data;
    return positions.where((element) => element.lineName != "MAN").toList();
  } catch (e) {
    return null;
  }
}
