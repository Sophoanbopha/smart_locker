import 'package:flutter/material.dart';
import '../core/colors.dart';

// ─── widgets/stat_card.dart ──────────────────────────────────────
class StatCard extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color color;
  const StatCard(this.icon, this.label, this.value, this.color, {super.key});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: kG2,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: kG)),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(9)),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: TextStyle(
                        color: color,
                        fontSize: 22,
                        fontWeight: FontWeight.w900)),
                Text(label, style: const TextStyle(color: kG3, fontSize: 11)),
              ],
            ),
          ],
        ),
      );
}
