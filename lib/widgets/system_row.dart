import 'package:flutter/material.dart';
import '../core/colors.dart';

// ─── widgets/system_row.dart ─────────────────────────────────────
class SystemRow extends StatelessWidget {
  final IconData icon;
  final String title, sub;
  final Color color;
  const SystemRow(this.icon, this.title, this.sub, this.color, {super.key});

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
        decoration: BoxDecoration(
            color: kG2,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: kG)),
        child: Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: kW,
                          fontSize: 13,
                          fontWeight: FontWeight.bold)),
                  Text(sub, style: const TextStyle(color: kG3, fontSize: 11)),
                ],
              ),
            ),
            Container(
                width: 8,
                height: 8,
                decoration:
                    BoxDecoration(color: color, shape: BoxShape.circle)),
          ],
        ),
      );
}
