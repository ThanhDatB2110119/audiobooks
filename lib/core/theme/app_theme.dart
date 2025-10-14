import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    // primaryColor: PrimaryColors.shade600,
    // scaffoldBackgroundColor: NeutralColors.shade50,

    // colorScheme: ColorScheme.fromSeed(
    //   seedColor: PrimaryColors.shade600,
    //   primary: PrimaryColors.shade600,
    //   secondary: SecondaryColors.shade900,
    //   surface: NeutralColors.shade50,
    // ),

    appBarTheme: const AppBarTheme(
      //backgroundColor: NeutralColors.shade50,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
    ),

    textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        // backgroundColor: PrimaryColors.shade600,
        // foregroundColor: NeutralColors.shade900,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),

    useMaterial3: true,
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );
}
