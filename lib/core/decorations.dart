import 'package:flutter/material.dart';
import 'colors.dart';

InputDecoration inputDec(String hint, IconData icon) => InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: kG3),
      prefixIcon: Icon(icon, color: kY, size: 20),
      filled: true,
      fillColor: kG,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: kY, width: 1.5),
      ),
    );
