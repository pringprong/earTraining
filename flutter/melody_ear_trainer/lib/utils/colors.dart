import 'package:flutter/material.dart';

Color multiplyHexColor(String hexColor, double factor) {
  hexColor = hexColor.replaceAll('#', '');
  if (hexColor.length == 6) {
    int r = int.parse(hexColor.substring(0, 2), radix: 16);
    int g = int.parse(hexColor.substring(2, 4), radix: 16);
    int b = int.parse(hexColor.substring(4, 6), radix: 16);

    r = (r * factor).clamp(0, 255).toInt();
    g = (g * factor).clamp(0, 255).toInt();
    b = (b * factor).clamp(0, 255).toInt();

    return Color.fromARGB(255, r, g, b);
  }
  return Colors.grey;
}

Color getChordButtonColor(String chordName) {
  const color1 = "#8189d3";
  const color2 = "#89afaa";
  const color3 = "#bcae9a";
  const color4 = "#c3b2b7";
  const color5 = "#d0a89b";
  const buttonColor = "#84b6d4";
  const factor1 = 0.85;
  const factor2 = 1.0;
  const factor3 = 1.15;
  const factor4 = 1.3;
  //const FACTOR5 = 1.45;

  String c = chordName;
  if (c.endsWith("_VL_R")) return multiplyHexColor(color1, factor1);
  if (c.endsWith("_L_R")) return multiplyHexColor(color1, factor2);
  if (c.endsWith("_M_R")) return multiplyHexColor(color1, factor3);
  if (c.endsWith("_H_R")) return multiplyHexColor(color1, factor4);

  if (c.endsWith("_VL_1i")) return multiplyHexColor(color2, factor1);
  if (c.endsWith("_L_1i")) return multiplyHexColor(color2, factor2);
  if (c.endsWith("_M_1i")) return multiplyHexColor(color2, factor3);
  if (c.endsWith("_H_1i")) return multiplyHexColor(color2, factor4);

  if (c.endsWith("_VL_2i")) return multiplyHexColor(color3, factor1);
  if (c.endsWith("_L_2i")) return multiplyHexColor(color3, factor2);
  if (c.endsWith("_M_2i")) return multiplyHexColor(color3, factor3);
  if (c.endsWith("_H_2i")) return multiplyHexColor(color3, factor4);

  if (c.endsWith("_VL_3i")) return multiplyHexColor(color4, factor1);
  if (c.endsWith("_L_3i")) return multiplyHexColor(color4, factor2);
  if (c.endsWith("_M_3i")) return multiplyHexColor(color4, factor3);
  if (c.endsWith("_H_3i")) return multiplyHexColor(color4, factor4);

  if (c.endsWith("_All")) return multiplyHexColor(color5, factor2);

  return multiplyHexColor(buttonColor, 1.0);
}