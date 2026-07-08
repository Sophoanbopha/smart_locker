import 'package:flutter/material.dart';
import '../core/colors.dart';

class InfoTile extends StatelessWidget {
  final IconData icon;
  final String title, value;
  final Color iconColor;

  const InfoTile(this.icon, this.title, this.value, this.iconColor,
      {super.key});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: kG2,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: kG),
        ),
        child: Row(children: [
          Icon(icon, color: iconColor, size: 19),
          const SizedBox(width: 9),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(title, style: const TextStyle(color: kG3, fontSize: 10)),
              Text(value,
                  style: const TextStyle(
                      color: kW, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
        ]),
      );
}
