import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:khel_milap/presentation/theme/theme.dart';

class AppFonts {
  static TextStyle headline1 = GoogleFonts.montserrat(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppTheme.textColor,
  );

  static TextStyle bodyText = GoogleFonts.roboto(
    fontSize: 16,
    color: AppTheme.textColor,
  );
}
