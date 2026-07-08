import 'package:flutter/material.dart';
import '../core/colors.dart';
import '../core/widgets.dart';
import '../models/locker.dart';

class LockerCard extends StatelessWidget {
  final Locker locker;
  final VoidCallback onToggle;

  const LockerCard(this.locker, this.onToggle, {super.key});

  @override
  Widget build(BuildContext context) {
    final open = locker.status == LS.unlocked;
    final al = locker.status == LS.alert;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kG2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: al
              ? kRed.withOpacity(0.5)
              : open
                  ? kY.withOpacity(0.5)
                  : kG,
        ),
      ),
      child: Column(children: [
        Row(children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: open ? kY.withOpacity(0.1) : kB,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              open ? Icons.lock_open_rounded : Icons.lock_rounded,
              color: open
                  ? kY
                  : al
                      ? kRed
                      : kG3,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(locker.label,
                  style: const TextStyle(
                      color: kW, fontWeight: FontWeight.bold, fontSize: 15)),
              Text(locker.owner ?? 'Unassigned',
                  style: const TextStyle(color: kG3, fontSize: 12)),
            ]),
          ),
          statusBadge(locker.status),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Icon(
            locker.hasItem ? Icons.inventory_2_rounded : Icons.inbox_rounded,
            color: locker.hasItem ? kY : kG3,
            size: 13,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              locker.hasItem ? 'Item detected' : 'Empty',
              style: TextStyle(
                color: locker.hasItem ? kY : kG3,
                fontSize: 11,
              ),
            ),
          ),
          GestureDetector(
            onTap: onToggle,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(color: open ? kG3 : kY),
                borderRadius: BorderRadius.circular(7),
              ),
              child: Text(
                open ? 'Lock' : 'Open',
                style: TextStyle(
                  color: open ? kG3 : kY,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ]),
      ]),
    );
  }
}
