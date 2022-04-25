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
