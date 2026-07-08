import 'package:flutter/material.dart';
import 'colors.dart';
import '../models/locker.dart';

Widget yellowBtn(String label, IconData icon, VoidCallback onTap) => SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: kB, size: 18),
        label: Text(
          label,
          style: const TextStyle(
              color: kB, fontWeight: FontWeight.bold, fontSize: 15),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: kY,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 0,
        ),
      ),
    );

Widget itemBadge(bool hasItem) {
  final c = hasItem ? kY : kGrn;
  final t = hasItem ? 'ITEM INSIDE' : 'EMPTY';
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: c.withOpacity(0.13),
      border: Border.all(color: c),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      t,
      style: TextStyle(
          color: c,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2),
    ),
  );
}

Widget statusBadge(LS s) {
  Color c;
  String t;
  switch (s) {
    case LS.locked:
      c = kG3;
      t = 'LOCKED';
      break;
    case LS.unlocked:
      c = kY;
      t = 'OPEN';
      break;
    case LS.alert:
      c = kRed;
      t = 'ALERT';
      break;
  }
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: c.withOpacity(0.13),
      border: Border.all(color: c),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      t,
      style: TextStyle(
          color: c,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2),
    ),
  );
}
