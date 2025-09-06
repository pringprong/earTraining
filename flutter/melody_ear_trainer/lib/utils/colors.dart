import 'package:flutter/material.dart';

SizedBox verticalSpacer() {
  return SizedBox(height: 8);
}

SizedBox horizontalSpacer() {
  return SizedBox(width: 8);
}

Row TextRow(String myText) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      Expanded(
        child: Wrap(
          children: [
            Text(
              myText,
              style: TextStyle(fontWeight: FontWeight.bold),
              softWrap: true,
            ),
          ],
        ),
      ),
    ],
  );
}

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

IconData waitingForGuessIcon = Icons.help_outline;
Color waitingForGuessIconColor = Colors.grey;
Color waitingForGuessButtonColor = Colors.grey.shade300;
const Color buttonForegroundColor = Colors.black;
Color waitingForGuessForegroundColor = buttonForegroundColor;

IconData correctGuessIcon = Icons.check_circle;
Color correctGuessIconColor = Colors.green;
Color correctGuessButtonColor = const Color.fromARGB(255, 191, 220, 158);
Color correctGuessForegroundColor = buttonForegroundColor;

IconData incorrectGuessIcon = Icons.cancel;
Color incorrectGuessIconColor = Colors.red;
Color incorrectGuessButtonColor = const Color.fromARGB(255, 240, 128, 128);
Color incorrectGuessForegroundColor = buttonForegroundColor;

const Color borderColor = Colors.grey;
const Color yetAnotherGrey = Color.fromARGB(255, 181, 196, 212);
const Color noteButtonForegroundColor = Colors.white;

const color1 = "#8189d3"; // mauvey blue _R
const color2 = "#89afaa"; // green _1i
const color3 = "#bcae9a"; // greeny beige, tan khaki _2i
const color4 = "#c3b2b7"; // pinky beige _3i
const color5 = "#d0a89b"; // reddish brown _All
const color6 = "#84b6d4"; // grey blue
const factor1 = 0.85;
const factor2 = 1.0;
const factor3 = 1.15;
const factor4 = 1.3;

Color c1f1 = multiplyHexColor(color1, factor1);
Color c1f2 = multiplyHexColor(color1, factor2);
Color c1f3 = multiplyHexColor(color1, factor3);
Color c1f4 = multiplyHexColor(color1, factor4);
Color c2f1 = multiplyHexColor(color2, factor1);
Color c2f2 = multiplyHexColor(color2, factor2);
Color c2f3 = multiplyHexColor(color2, factor3);
Color c2f4 = multiplyHexColor(color2, factor4);
Color c3f1 = multiplyHexColor(color3, factor1);
Color c3f2 = multiplyHexColor(color3, factor2);
Color c3f3 = multiplyHexColor(color3, factor3);
Color c3f4 = multiplyHexColor(color3, factor4);
Color c4f1 = multiplyHexColor(color4, factor1);
Color c4f2 = multiplyHexColor(color4, factor2);
Color c4f3 = multiplyHexColor(color4, factor3);
Color c4f4 = multiplyHexColor(color4, factor4);
Color c5f1 = multiplyHexColor(color5, factor1);
Color c5f2 = multiplyHexColor(color5, factor2);
Color c5f3 = multiplyHexColor(color5, factor3);
Color c5f4 = multiplyHexColor(color5, factor4);
Color c6f1 = multiplyHexColor(color6, factor1);
Color c6f2 = multiplyHexColor(color6, factor2);
Color c6f3 = multiplyHexColor(color6, factor3);
Color c6f4 = multiplyHexColor(color6, factor4);

Color getChordButtonColor(String chordName) {
  String c = chordName;
  if (c.endsWith("00_Rt")) return c1f1;
  else if (c.endsWith("0_Rt")) return c1f2;
  else if (c.endsWith("1_Rt")) return c1f4;
  else if (c.endsWith("_Rt")) return c1f3;

  if (c.endsWith("00_Fir")) return c2f1;
  if (c.endsWith("0_Fir")) return c2f2;
  if (c.endsWith("1_Fir")) return c2f4;
  if (c.endsWith("_Fir")) return c2f3;

  if (c.endsWith("00_Sec")) return c3f1;
  if (c.endsWith("0_Sec")) return c3f2;
  if (c.endsWith("1_Sec")) return c3f4;
  if (c.endsWith("_Sec")) return c3f3;

  if (c.endsWith("00_Thr")) return c4f1;
  if (c.endsWith("0_Thr")) return c4f2;
  if (c.endsWith("1_Thr")) return c4f4;
  if (c.endsWith("_Thr")) return c4f3;

  if (c.endsWith("_All")) return c5f2;

  return c6f2;
}
