import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:pardumhd/fetch.dart';
import 'package:pardumhd/icon.dart';
import 'package:pardumhd/location.dart';
import 'package:pardumhd/modal.dart';

void main() {
  runApp(
    const MaterialApp(
      home: HomePage(),
      title: "Pardubice MHD",
    ),
  );
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late bool _isInstant;
  static const int fetchTime = 10, recalculateTime = 100;

  late Timer _fetchTimer;
  late MapController _mapController;
  List<BusPosition>? _oldPositions, _newPositions, _currentPosition;
  Position? _position;
  late int _sinceLastFetch;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _sinceLastFetch = 0;
    _isInstant = false;

    _fetchTimer = Timer.periodic(
      const Duration(seconds: fetchTime),
      fetchTimerTick,
    );
    Timer.periodic(
      const Duration(milliseconds: recalculateTime),
      calculatePositionTimerTick,
    );
    Future.delayed(Duration.zero, () async {
      await fetchTimerTick(_fetchTimer);
    });
  }

  Future<void> fetchTimerTick(Timer timer) async {
    final newBusses = await fetchFromApi();
    final position = await determinePosition();
    if (newBusses != null) {
      _oldPositions = _newPositions;
      _newPositions = newBusses;
    }
    _position = position;
    _sinceLastFetch = 0;
  }

  Future<void> calculatePositionTimerTick(Timer timer) async {
    _sinceLastFetch++;
    if (_isInstant || _oldPositions == null || _newPositions == null) {
      if (_currentPosition != _newPositions) {
        setState(() {
          _currentPosition = _newPositions;
        });
      }
      return;
    }
    final percent = _sinceLastFetch * recalculateTime / 10000;
    final currentPositions = _oldPositions!.map((oldPos) {
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
    }).toList();

    setState(() {
      _currentPosition = List<BusPosition>.from(
          currentPositions.where((pos) => pos != null).toList());
    });
  }

  void setInstant(bool value) {
    setState(() {
      _isInstant = value;
    });
  }

  @override
  void dispose() {
    _fetchTimer.cancel();
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
                            onChanged: (value) {
                              if (value != null) {
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
