import 'package:flutter/material.dart';

class TrolleyIcon extends StatelessWidget {
  final String name;

  const TrolleyIcon({required this.name, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const double size = 40;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Image(
            image: AssetImage("assets/trolley.png"),
            width: size,
            height: size,
          ),
          Container(
            alignment: Alignment.center,
            child: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
