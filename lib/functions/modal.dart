import 'package:flutter/material.dart';
import 'package:pardumhd/models/bus_position.dart';

void ShowModal(BuildContext context, BusPosition busPosition) {
  var isLate = busPosition.time == null ? null : busPosition.time?[0] == "-";
  var parsedTime = isLate == null
      ? null
      : isLate
          ? busPosition.time?.substring(1)
          : busPosition.time;
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return ListView(
        shrinkWrap: true,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text("Číslo linky : ", style: leftStyle),
                    Text("Cílová zastávka : ", style: leftStyle),
                    Text("Poslední zastávka : ", style: leftStyle),
                    Text("Další zastávka : ", style: leftStyle),
                    Text(isLate ?? true ? "Zpoždění : " : "Napřed : ",
                        style: leftStyle)
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(busPosition.lineName),
                    Text(busPosition.destination ?? "Není"),
                    Text(busPosition.last ?? "Není"),
                    Text(busPosition.next ?? "Není"),
                    Text(parsedTime ?? "Včas"),
                  ],
                ),
              ],
            ),
          ),
        ],
      );
    },
  );
}

TextStyle leftStyle = const TextStyle(
  fontWeight: FontWeight.bold,
);
