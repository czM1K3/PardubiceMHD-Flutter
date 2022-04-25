import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:pardumhd/functions/fetch.dart';
import 'package:pardumhd/functions/get_url.dart';
import 'package:pardumhd/models/response.dart';
import 'package:pardumhd/widgets/download_button.dart';
import 'package:pardumhd/widgets/icon.dart';
import 'package:pardumhd/functions/location.dart';
import 'package:pardumhd/functions/modal.dart';
import 'package:pardumhd/models/bus_position.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart';

const String instantName = "instant";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(
    MaterialApp(
      home: HomePage(sharedPreferences: prefs),
      title: "Pardubice MHD",
    ),
  );
}

class HomePage extends StatefulWidget {
  final SharedPreferences sharedPreferences;

  const HomePage({Key? key, required this.sharedPreferences}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late bool _isInstant;
  static const int positionTime = 11, recalculateTime = 100;

  late Timer _positionTimer;
  late MapController _mapController;
  List<BusPosition>? _oldPositions, _newPositions, _currentPosition;
  Position? _position;
  late int _sinceLastFetch;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _sinceLastFetch = 0;
    _isInstant = widget.sharedPreferences.getBool(instantName) ?? false;

    _positionTimer = Timer.periodic(
      const Duration(seconds: positionTime),
      positionTimerTick,
    );
    Timer.periodic(
      const Duration(milliseconds: recalculateTime),
      calculatePositionTimerTick,
    );
    Future.delayed(Duration.zero, () async {
      positionTimerTick(_positionTimer);
      updateBuses(await fetchFromApi());
    });
    Socket socket =
        io(getUrl(), OptionBuilder().setTransports(['websocket']).build());
    socket.on('buses', (data) {
      updateBuses(Response.fromJson(data).data);
    });
  }

  Future<void> positionTimerTick(Timer timer) async {
    final position = await determinePosition();
    setState(() {
      _position = position;
    });
  }

  void updateBuses(List<BusPosition>? newBusses) {
    if (newBusses == null) {
      return;
    }
    _oldPositions = _newPositions;
    _newPositions = newBusses;
    _sinceLastFetch = 0;
  }

  Future<void> calculatePositionTimerTick(Timer timer) async {
    _sinceLastFetch++;
    if (_isInstant || _oldPositions == null || _newPositions == null) {
      if (_currentPosition != _newPositions) {
        _newPositions!.sort(((a, b) => b.latitude.compareTo(a.latitude)));
        setState(() {
          _currentPosition = _newPositions;
        });
      }
      return;
    }
    final percent = _sinceLastFetch * recalculateTime / 10000;
    final currentPositions = _oldPositions!
        .map((oldPos) {
          final newPos = _newPositions!.where(
            (newPos) => newPos.vid == oldPos.vid,
          );
          if (newPos.isEmpty) {
            return null;
          }
          final latChange = newPos.first.latitude - oldPos.latitude;
          final lonChange = newPos.first.longitude - oldPos.longitude;
          final lat = oldPos.latitude + (latChange * percent);
          final lon = oldPos.longitude + (lonChange * percent);

          return BusPosition(
            destination: newPos.first.destination,
            lineName: newPos.first.lineName,
            latitude: lat,
            longitude: lon,
            next: newPos.first.next,
            last: newPos.first.last,
            time: newPos.first.time,
            vid: newPos.first.vid,
          );
        })
        .where((element) => element != null)
        .toList();

    currentPositions.sort(((a, b) => b!.latitude.compareTo(a!.latitude)));

    setState(() {
      _currentPosition = List<BusPosition>.from(currentPositions);
    });
  }

  void setInstant(bool value) {
    setState(() {
      _isInstant = value;
    });
  }

  @override
  void dispose() {
    _positionTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentPosition == null) {
      return SafeArea(
        child: Container(
          color: Colors.red,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                CircularProgressIndicator(color: Colors.white),
              ],
            ),
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: const [
            Image(image: AssetImage("assets/Pardubice_logo.png"), height: 70),
            Text("Pardubice MHD"),
          ],
        ),
        backgroundColor: Colors.red,
        actions: [
          kIsWeb ? const DownloadAppButton() : Container(),
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => StatefulBuilder(
                  builder: (context, setState) {
                    return AlertDialog(
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text("Nastavení",
                              style: TextStyle(fontSize: 20)),
                          CheckboxListTile(
                            activeColor: Colors.red,
                            title: const Text("Instantní mód"),
                            value: _isInstant,
                            onChanged: (value) async {
                              if (value != null) {
                                await widget.sharedPreferences
                                    .setBool(instantName, value);
                                setState(() {
                                  _isInstant = value;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          child: const Text("Zavřít",
                              style: TextStyle(color: Colors.white)),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              );
            },
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          center: LatLng(50.0317826, 15.7760577),
          zoom: 13.0,
          interactiveFlags: InteractiveFlag.pinchMove |
              InteractiveFlag.pinchZoom |
              InteractiveFlag.drag |
              InteractiveFlag.doubleTapZoom,
          maxZoom: 18,
          minZoom: 11,
          nePanBoundary: LatLng(50.1, 15.9),
          swPanBoundary: LatLng(49.988, 15.7),
          slideOnBoundaries: true,
        ),
        layers: [
          TileLayerOptions(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c'],
          ),
          MarkerLayerOptions(
            markers: [
              ...(_currentPosition?.map((p) => Marker(
                        width: 80.0,
                        height: 80.0,
                        point: LatLng(p.latitude, p.longitude),
                        builder: (ctx) => GestureDetector(
                          onTap: () {
                            ShowModal(context, p);
                          },
                          child: TrolleyIcon(
                            name: p.lineName,
                          ),
                        ),
                      )) ??
                  []),
              ...(_position != null
                  ? [
                      Marker(
                        point: LatLng(
                          _position!.latitude,
                          _position!.longitude,
                        ),
                        builder: (ctx) => const Icon(
                          Icons.location_pin,
                          color: Colors.blue,
                          size: 40,
                        ),
                      ),
                    ]
                  : []),
            ],
          ),
        ],
      ),
      floatingActionButton: _position != null
          ? FloatingActionButton(
              onPressed: () {
                _mapController.move(
                  LatLng(_position!.latitude, _position!.longitude),
                  15,
                );
              },
              child: const Icon(Icons.my_location),
              backgroundColor: Colors.red,
            )
          : null,
    );
  }
}
