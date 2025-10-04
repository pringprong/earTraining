import 'package:flutter/material.dart';

// SizedBox verticalSpacer() {
//   return SizedBox(height: 8);
// }

// SizedBox horizontalSpacer() {
//   return SizedBox(width: 8);
// }

// Row headingRow(String myText) {
//   return Row(
//     mainAxisAlignment: MainAxisAlignment.start,
//     children: [
//       Expanded(
//         child: Wrap(
//           children: [
//             Text(
//               myText,
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
//             ),
//           ],
//         ),
//       ),
//     ],
//   );
// }

// Row TextRow(String myText) {
//   return Row(
//     mainAxisAlignment: MainAxisAlignment.start,
//     children: [
//       Expanded(
//         child: Wrap(
//           children: [
//             Text(
//               myText,
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
//             ),
//           ],
//         ),
//       ),
//     ],
//   );
// }

// Row subHeadingRow(String myText) {
//   return Row(
//     mainAxisAlignment: MainAxisAlignment.start,
//     children: [
//       Expanded(
//         child: Wrap(
//           children: [
//             Text(
//               myText,
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
//             ),
//           ],
//         ),
//       ),
//     ],
//   );
// }

// Row plainText(String myText) {
//   return Row(
//     mainAxisAlignment: MainAxisAlignment.start,
//     children: [
//       Expanded(
//         child: Wrap(children: [Text(myText, style: TextStyle(fontSize: 16))]),
//       ),
//     ],
//   );
// }

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

const color1 = "#8189d3"; // mauvey blue _Rt
const color2 = "#89afaa"; // green _Fir
const color3 = "#bcae9a"; // greeny beige, tan khaki _Sec
const color4 = "#c3b2b7"; // pinky beige _Thr
const color5 = "#d0a89b"; // reddish brown _All
const color6 = "#84b6d4"; // grey blue
const color7 = "#0664c0"; // royal blue

const factor0 = 0.7;
const factor1 = 0.8;
const factor2 = 0.9;
const factor3 = 1.0;
const factor4 = 1.1;
// #0664c0   HEX:#1c4fa7

Map<String, Color> colorMap = {
  'c1f0': multiplyHexColor(color1, factor0),
  'c1f1': multiplyHexColor(color1, factor1),
  'c1f2': multiplyHexColor(color1, factor2),
  'c1f3': multiplyHexColor(color1, factor3),
  'c1f4': multiplyHexColor(color1, factor4),

  'c2f0': multiplyHexColor(color2, factor0),
  'c2f1': multiplyHexColor(color2, factor1),
  'c2f2': multiplyHexColor(color2, factor2),
  'c2f3': multiplyHexColor(color2, factor3),
  'c2f4': multiplyHexColor(color2, factor4),

  'c3f0': multiplyHexColor(color3, factor0),
  'c3f1': multiplyHexColor(color3, factor1),
  'c3f2': multiplyHexColor(color3, factor2),
  'c3f3': multiplyHexColor(color3, factor3),
  'c3f4': multiplyHexColor(color3, factor4),

  'c4f0': multiplyHexColor(color4, factor0),
  'c4f1': multiplyHexColor(color4, factor1),
  'c4f2': multiplyHexColor(color4, factor2),
  'c4f3': multiplyHexColor(color4, factor3),
  'c4f4': multiplyHexColor(color4, factor4),

  'c5f0': multiplyHexColor(color5, factor0),
  'c5f1': multiplyHexColor(color5, factor1),
  'c5f2': multiplyHexColor(color5, factor2),
  'c5f3': multiplyHexColor(color5, factor3),
  'c5f4': multiplyHexColor(color5, factor4),

  'c6f0': multiplyHexColor(color6, factor0),
  'c6f1': multiplyHexColor(color6, factor1),
  'c6f2': multiplyHexColor(color6, factor2),
  'c6f3': multiplyHexColor(color6, factor3),
  'c6f4': multiplyHexColor(color6, factor4),

  'c7f0': multiplyHexColor(color7, factor0),
  'c7f1': multiplyHexColor(color7, factor1),
  'c7f2': multiplyHexColor(color7, factor2),
  'c7f3': multiplyHexColor(color7, factor3),
  'c7f4': multiplyHexColor(color7, factor4),

  'waitingForGuessIconColor': Colors.grey,
  'waitingForGuessButtonColor': Colors.grey.shade300,
  'buttonForegroundColor': Colors.black,
  'correctGuessIconColor': Colors.green,
  'correctGuessButtonColor': Color.fromARGB(255, 191, 220, 158),
  'incorrectGuessIconColor': Colors.red,
  'incorrectGuessButtonColor': Color.fromARGB(255, 240, 128, 128),

  'passedColor': Color.fromARGB(255, 191, 220, 158),
  'notYetStartedColor': Color.fromARGB(255, 176, 204, 231),
  'inProgressColor': Color.fromARGB(255, 121, 185, 245),

  'borderColor': Colors.grey,
  'yetAnotherGrey': Color.fromARGB(255, 181, 196, 212),
  'noteButtonForegroundColor': Colors.white,
  'newNoteButtonForegroundColor': Colors.black,
  'clearButtonColor': Color.fromARGB(255, 176, 204, 231),

  'practiceButtonColor': multiplyHexColor(color7, factor4),
  'handsFreePracticeButtonColor': multiplyHexColor(color7, factor2),
  'testButtonColor':multiplyHexColor(color7, factor0),
};

IconData waitingForGuessIcon = Icons.help_outline;
IconData correctGuessIcon = Icons.check_circle;
IconData incorrectGuessIcon = Icons.cancel;

Color missionLevelStatusColor(String missionStatus) {
  return missionStatus == "Passed!"
      ? colorMap["passedColor"] ?? Colors.white
      : missionStatus == "Not started yet"
      ? colorMap["notYetStartedColor"] ?? Colors.white
      : colorMap["inProgressColor"] ?? Colors.white;
}

Color getCampaignColor(String CampaignID) {
  switch (CampaignID) {
    case "c0":
      return colorMap['c5f4'] ?? Colors.white;
    case "c1":
      return colorMap['c1f4'] ?? Colors.white;
    case "c2":
      return colorMap['c2f4'] ?? Colors.white;
    case "c3":
      return colorMap['c3f4'] ?? Colors.white;
    case "c4":
      return colorMap['c4f4'] ?? Colors.white;
    case "c5":
      return colorMap['c6f4'] ?? Colors.white;
  }
  return Colors.grey;
}

Color getModeColor(String mode) {
  switch (mode) {
    case "Melody ID":
      return colorMap["c2f2"] ?? Colors.white;
    case "Melody singing":
      return colorMap["c2f0"] ?? Colors.white;
    case "Chord ID":
      return colorMap["c4f2"] ?? Colors.white;
    case "Chord singing":
      return colorMap["c4f0"] ?? Colors.white;
    case "Chord melody ID":
      return colorMap["c3f2"] ?? Colors.white;
    case "Chord melody singing":
      return colorMap["c3f0"] ?? Colors.white;
  }
  return Colors.grey;  
}

Color getChordButtonColor(String chordName) {
  String c = chordName;
  if (c.endsWith("00_Rt")) return colorMap["c1f1"] ?? Colors.white;
  if (c.endsWith("0_Rt")) return colorMap["c1f2"] ?? Colors.white;
  if (c.endsWith("1_Rt")) return colorMap["c1f4"] ?? Colors.white;
  if (c.endsWith("_Rt")) return colorMap["c1f3"] ?? Colors.white;

  if (c.endsWith("00_Fir")) return colorMap["c2f1"] ?? Colors.white;
  if (c.endsWith("0_Fir")) return colorMap["c2f2"] ?? Colors.white;
  if (c.endsWith("1_Fir")) return colorMap["c2f4"] ?? Colors.white;
  if (c.endsWith("_Fir")) return colorMap["c2f3"] ?? Colors.white;

  if (c.endsWith("00_Sec")) return colorMap["c3f1"] ?? Colors.white;
  if (c.endsWith("0_Sec")) return colorMap["c3f2"] ?? Colors.white;
  if (c.endsWith("1_Sec")) return colorMap["c3f4"] ?? Colors.white;
  if (c.endsWith("_Sec")) return colorMap["c3f3"] ?? Colors.white;

  if (c.endsWith("00_Thr")) return colorMap["c4f1"] ?? Colors.white;
  if (c.endsWith("0_Thr")) return colorMap["c4f2"] ?? Colors.white;
  if (c.endsWith("1_Thr")) return colorMap["c4f4"] ?? Colors.white;
  if (c.endsWith("_Thr")) return colorMap["c4f3"] ?? Colors.white;

  if (c.endsWith("_All")) return colorMap["c5f2"] ?? Colors.white;

  return colorMap["c6f2"] ?? Colors.white;
}

Color getChordButtonColor2(String chordName) {
  String c = chordName;
  if (c.toLowerCase().startsWith("vii") & c.endsWith("_Rt"))
    return colorMap["c5f0"] ?? Colors.white;
  if (c.toLowerCase().startsWith("vii") & c.endsWith("_Fir"))
    return colorMap["c5f1"] ?? Colors.white;
  if (c.toLowerCase().startsWith("vii") & c.endsWith("_Sec"))
    return colorMap["c5f2"] ?? Colors.white;
  if (c.toLowerCase().startsWith("vii") & c.endsWith("_Thr"))
    return colorMap["c5f3"] ?? Colors.white;
  if (c.toLowerCase().startsWith("vii") & c.endsWith("_All"))
    return colorMap["c5f4"] ?? Colors.white;

  if (c.toLowerCase().startsWith("vi") & c.endsWith("_Rt"))
    return colorMap["c2f0"] ?? Colors.white;
  if (c.toLowerCase().startsWith("vi") & c.endsWith("_Fir"))
    return colorMap["c2f1"] ?? Colors.white;
  if (c.toLowerCase().startsWith("vi") & c.endsWith("_Sec"))
    return colorMap["c2f2"] ?? Colors.white;
  if (c.toLowerCase().startsWith("vi") & c.endsWith("_Thr"))
    return colorMap["c2f3"] ?? Colors.white;
  if (c.toLowerCase().startsWith("vi") & c.endsWith("_All"))
    return colorMap["c2f4"] ?? Colors.white;

  if (c.toLowerCase().startsWith("v") & c.endsWith("_Rt"))
    return colorMap["c3f0"] ?? Colors.white;
  if (c.toLowerCase().startsWith("v") & c.endsWith("_Fir"))
    return colorMap["c3f1"] ?? Colors.white;
  if (c.toLowerCase().startsWith("v") & c.endsWith("_Sec"))
    return colorMap["c3f2"] ?? Colors.white;
  if (c.toLowerCase().startsWith("v") & c.endsWith("_Thr"))
    return colorMap["c3f3"] ?? Colors.white;
  if (c.toLowerCase().startsWith("v") & c.endsWith("_All"))
    return colorMap["c3f4"] ?? Colors.white;

  if (c.toLowerCase().startsWith("iv") & c.endsWith("_Rt"))
    return colorMap["c6f0"] ?? Colors.white;
  colorMap["c6f1"] ?? Colors.white;
  colorMap["c6f2"] ?? Colors.white;
  if (c.toLowerCase().startsWith("iv") & c.endsWith("_Fir"))
    return colorMap["c6f1"] ?? Colors.white;
  if (c.toLowerCase().startsWith("iv") & c.endsWith("_Sec"))
    return colorMap["c6f2"] ?? Colors.white;
  if (c.toLowerCase().startsWith("iv") & c.endsWith("_Thr"))
    return colorMap["c6f3"] ?? Colors.white;
  if (c.toLowerCase().startsWith("iv") & c.endsWith("_All"))
    return colorMap["c6f4"] ?? Colors.white;

  if (c.toLowerCase().startsWith("iii") & c.endsWith("_Rt"))
    return colorMap["c1f0"] ?? Colors.white;
  if (c.toLowerCase().startsWith("iii") & c.endsWith("_Fir"))
    return colorMap["c1f1"] ?? Colors.white;
  if (c.toLowerCase().startsWith("iii") & c.endsWith("_Sec"))
    return colorMap["c1f2"] ?? Colors.white;
  if (c.toLowerCase().startsWith("iii") & c.endsWith("_Thr"))
    return colorMap["c1f3"] ?? Colors.white;
  if (c.toLowerCase().startsWith("iii") & c.endsWith("_All"))
    return colorMap["c1f4"] ?? Colors.white;

  if (c.toLowerCase().startsWith("ii") & c.endsWith("_Rt"))
    return colorMap["c4f0"] ?? Colors.white;
  if (c.toLowerCase().startsWith("ii") & c.endsWith("_Fir"))
    return colorMap["c4f1"] ?? Colors.white;
  if (c.toLowerCase().startsWith("ii") & c.endsWith("_Sec"))
    return colorMap["c4f2"] ?? Colors.white;
  if (c.toLowerCase().startsWith("ii") & c.endsWith("_Thr"))
    return colorMap["c4f3"] ?? Colors.white;
  if (c.toLowerCase().startsWith("ii") & c.endsWith("_All"))
    return colorMap["c4f4"] ?? Colors.white;

  if (c.toLowerCase().startsWith("i") & c.endsWith("_Rt"))
    return colorMap["c7f0"] ?? Colors.white;
  if (c.toLowerCase().startsWith("i") & c.endsWith("_Fir"))
    return colorMap["c7f1"] ?? Colors.white;
  if (c.toLowerCase().startsWith("i") & c.endsWith("_Sec"))
    return colorMap["c7f2"] ?? Colors.white;
  if (c.toLowerCase().startsWith("i") & c.endsWith("_Thr"))
    return colorMap["c7f3"] ?? Colors.white;
  if (c.toLowerCase().startsWith("i") & c.endsWith("_All"))
    return colorMap["c7f4"] ?? Colors.white;

  return colorMap["yetAnotherGrey"] ?? Colors.white;
}