import 'package:flutter/material.dart';

class CustomColors {
  static Color primaryTextColor =
      const Color.fromARGB(255, 255, 65, 179).withOpacity(0.5);
  static Color dividerColor = Color.fromARGB(136, 255, 65, 179);
  static Color pageBackgroundColor =
      Color.fromARGB(255, 255, 255, 255).withOpacity(0);
  static Color menuBackgroundColor = Color(0xFF242634).withOpacity(0.5);

  static Color clockBG = Color.fromARGB(75, 255, 255, 255);
  static Color clockOutline = Color.fromARGB(255, 255, 65, 179).withOpacity(1);
  static Color? secHandColor = const Color.fromARGB(255, 182, 129, 155);
  static Color minHandStatColor = Color(0xFF748EF6);
  static Color minHandEndColor = Color(0xFF77DDFF);
  static Color hourHandStatColor = Color(0xFFC279FB);
  static Color hourHandEndColor = Color(0xFFEA74AB);
}

class GradientColors {
  final List<Color> colors;
  GradientColors(this.colors);

  static List<Color> sky = [
    Color.fromARGB(255, 254, 72, 254).withOpacity(0.5),
    Color(0xFF5FC6FF).withOpacity(0.5)
  ];
  static List<Color> sunset = [
    Color(0xFFFE6197).withOpacity(0.5),
    Color(0xFFFFB463).withOpacity(0.5)
  ];
  static List<Color> sea = [
    Color.fromARGB(255, 189, 254, 97).withOpacity(0.5),
    Color(0xFF63FFD5).withOpacity(0.5)
  ];
  static List<Color> mango = [
    Color(0xFFFFA738).withOpacity(0.5),
    Color(0xFFFFE130).withOpacity(0.5)
  ];
  static List<Color> fire = [
    Color(0xFFFF5DCD).withOpacity(0.5),
    Color(0xFFFF8484).withOpacity(0.5)
  ];
}

class GradientTemplate {
  static List<GradientColors> gradientTemplate = [
    GradientColors(GradientColors.sky),
    GradientColors(GradientColors.sunset),
    GradientColors(GradientColors.sea),
    GradientColors(GradientColors.mango),
    GradientColors(GradientColors.fire),
  ];
}
