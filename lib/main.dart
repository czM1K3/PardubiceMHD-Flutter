import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:pardumhd/fetch.dart';
import 'package:pardumhd/icon.dart';
import 'package:pardumhd/modal.dart';

void main() {
  runApp(
    const MaterialApp(
      home: HomePage(),
    ),
  );
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Timer _timer;
  List<BusPosition>? _positions;

  @override
  void initState() {
    super.initState();
    const Duration _duration = Duration(seconds: 5);
    _timer = Timer.periodic(_duration, timerTick);
    Future.delayed(Duration.zero, () async {
      await timerTick(_timer);
    });
  }

  Future<void> timerTick(Timer timer) async {
    var busses = await FetchFromApi();
    setState(() {
      _positions = busses;
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_positions == null) {
      return SafeArea(
        child: Container(
          color: Colors.red,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                CircularProgressIndicator(),
              ],
            ),
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pardubice MHD"),
        backgroundColor: Colors.red,
      ),
      body: FlutterMap(
        options: MapOptions(
          center: LatLng(50.0317826, 15.7760577),
          zoom: 13.0,
          interactiveFlags: InteractiveFlag.pinchMove |
              InteractiveFlag.pinchZoom |
              InteractiveFlag.drag |
              InteractiveFlag.doubleTapZoom,
        ),
        layers: [
          TileLayerOptions(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c'],
          ),
          MarkerLayerOptions(
            markers: [
              ...(_positions?.map((p) => Marker(
                        width: 80.0,
                        height: 80.0,
                        point: LatLng(p.latitude, p.longitude),
                        builder: (ctx) => Container(
                          child: GestureDetector(
                            onTap: () {
                              ShowModal(context, p);
                            },
                            child: TrolleyIcon(
                              name: p.lineName,
                            ),
                          ),
                        ),
                      )) ??
                  []),
            ],
          ),
        ],
      ),
    );
  }
}
