import 'package:flutter/material.dart';
import 'theme.dart';

class AppStyles {
  static ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: AppTheme.primaryColor,
    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
  );

  static InputDecoration inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      filled: true,
      fillColor: Colors.white,
    );
  }

  static BoxDecoration cardDecoration = BoxDecoration(
    color: AppTheme.cardColor,
    borderRadius: BorderRadius.circular(8),
    boxShadow: [
      BoxShadow(
        color: Colors.grey,
        spreadRadius: 1,
        blurRadius: 4,
        offset: Offset(0, 2),
      ),
    ],
  );
}
