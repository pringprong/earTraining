import 'package:flutter/material.dart';
import 'package:melody_ear_trainer/main.dart';
import '../../providers/general_provider.dart';
import '../../providers/mapping_provider.dart';
import 'package:provider/provider.dart';
import '../utils/colors.dart';
import '../utils/helper.dart';
import 'levelMelodyID.dart';
import 'levelMelodyIDhandsfree.dart';
import 'levelMelodyIDtest.dart';
import 'levelMelodySinging.dart';
import 'levelMelodySinginghandsfree.dart';
import 'levelMelodySingingtest.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'dart:math';
//import 'package:intl/intl.dart';
//import 'dart:ui' as ui;
import '../utils/scatterplot.dart';

class Level extends StatefulWidget {
  const Level({super.key});

  static const String routeName = '/level';
  @override
  State<Level> createState() => _LevelState();
}

class _LevelState extends State<Level> {
  LevelInfo? levelInfo;
  List<LevelTestResults> ltrList = [];
  LevelInfo? nextLevel;
  LevelInfo? prevLevel;
  // Prev/next tile chrome, computed once per page (re)entry in
  // didChangeDependencies instead of on every build.
  Color prevLevelColor = Colors.grey;
  Color nextLevelColor = Colors.grey;
  int prevNumPassedTests = 0;
  int prevNumTests = 1;
  int nextNumPassedTests = 0;
  int nextNumTests = 1;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is! LevelInfo) return;
    levelInfo = args;
    final mappingProvider = context.read<MappingProvider>();
    // ObjectBox lookups + next/prev resolution happen here (once per page
    // (re)entry, including when returning after a test) — never in build.
    ltrList = objectBox.getLevelTestResultsByLevelID(args.LevelID);
    nextLevel = mappingProvider.getNextLevelForMission(args);
    prevLevel = mappingProvider.getPrevLevelForMission(args);

    prevLevelColor = Colors.grey;
    prevNumPassedTests = 0;
    prevNumTests = 1;
    if (prevLevel != null) {
      prevLevelColor = missionLevelStatusColor(
        getLevelStatusWithQuery(prevLevel!),
      );
      prevNumPassedTests = objectBox.numPassedTestsForLevel(
        prevLevel!.LevelID,
        prevLevel!.PassingScore,
      );
      prevNumTests = prevLevel!.NumTests;
    }
    nextLevelColor = Colors.grey;
    nextNumPassedTests = 0;
    nextNumTests = 1;
    if (nextLevel != null) {
      nextLevelColor = missionLevelStatusColor(
        getLevelStatusWithQuery(nextLevel!),
      );
      nextNumPassedTests = objectBox.numPassedTestsForLevel(
        nextLevel!.LevelID,
        nextLevel!.PassingScore,
      );
      nextNumTests = nextLevel!.NumTests;
    }
  }

  @override
  Widget build(BuildContext context) {
    final levelInfo = this.levelInfo!;
    final mappingProvider = context.read<MappingProvider>();
    String missionMode = mappingProvider.getMissionMode(levelInfo.MissionID);
    MissionInfo missionInfo = mappingProvider.getMissions[levelInfo.MissionID]!;
    final generalProvider = context.read<MissionSettingsProvider>();
    // ltrList / nextLevel / prevLevel are refreshed in didChangeDependencies.
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(title: Text('Melody ear trainer')),
      body: PopScope(
        canPop: true,
        onPopInvokedWithResult: (bool didPop, Object? result) {
          resetMissionBeforeMissionPage(generalProvider, missionInfo);
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Column(
                children: [
                  CampaignHeaderRow(campaignId: levelInfo.CampaignID),
                  verticalSpacer(),
                  MissionHeaderRow(missionId: levelInfo.MissionID, max: false),
                  verticalSpacer(),
                  LevelHeaderRow(levelId: levelInfo.LevelID),
                  verticalSpacer(),
                  plainText("Notes (colorful text=new):"),
                  verticalSpacer(),
                  buildNotesGrid(
                    generalProvider,
                    mappingProvider,
                    false,
                    mappingProvider.getCampaignOctave(levelInfo.CampaignID),
                    mappingProvider.getCampaignSet(levelInfo.CampaignID),
                    mappingProvider.getCampaignNotesInOctave(
                      levelInfo.CampaignID,
                    ),
                    levelInfo.NewNotes,
                    true,
                    true,
                    levelInfo.Notes.toSet(),
                  ),
                  verticalSpacer(),
                  buildSelectedChordButtonsHelper(
                    generalProvider,
                    mappingProvider,
                    optional: true,
                    selectedNotes: levelInfo.Notes.toSet(),
                    chordFrequencyOverride: levelInfo.ChordFrequency,
                  ),
                  plainText(
                    "Practice & take a test (" +
                        levelInfo.NumTests.toString() +
                        " required):",
                  ),
                  verticalSpacer(),
                  practiceButton(missionMode, levelInfo),
                  verticalSpacer(),
                  handsFreeButton(missionMode, levelInfo),
                  verticalSpacer(),
                  takeTestButton(missionMode, levelInfo),
                  verticalSpacer(),
                  plainText("Navigation:"),
                  verticalSpacer(),
                  prevAndNextLevelButtons(prevLevel, nextLevel),
                  verticalSpacer(),
                  returnToMissionPage(generalProvider, missionMode, missionInfo),
                  verticalSpacer(),
                  plainText("Test history:"),
                  verticalSpacer(),
                  // Scatter plot of test results: x = timestamp, y = score
                  if (ltrList.isEmpty) ...[
                    plainText("No test results for this level."),
                  ] else ...[
                    SizedBox(
                      height: 220,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: ScatterPlot(
                          results: ltrList,
                          levelInfo: levelInfo,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget prevAndNextLevelButtons(LevelInfo? prevLevel, LevelInfo? nextLevel) {
    // Colors / progress values are computed in didChangeDependencies.
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          child: ListTile(
            tileColor: colorMap['darkBackground'] ?? Colors.white,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: prevLevelColor, width: borderWidth),
              borderRadius: BorderRadius.circular(10.0),
            ),
            leading: Icon(
              prevLevelIcon,
              color: colorMap['noteButtonForegroundColor'] ?? Colors.white,
            ),
            title: Text(
              prevLevel?.LevelName ?? "",
              style: TextStyle(
                color: colorMap["noteButtonForegroundColor"] ?? Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            trailing: CircularPercentIndicator(
              radius: 10,
              lineWidth: 10,
              percent: min(prevNumPassedTests, prevNumTests) / prevNumTests,
              progressColor: colorMap['correctGuessIconColor'] ?? Colors.white,
              backgroundColor:
                  colorMap["waitingForGuessIconColor"] ?? Colors.white,
            ),
            onTap: () {
              if (prevLevel != null) {
                // No setLevelDetails — the next page derives its settings from
                // the LevelInfo route argument (LevelConfig).
                Navigator.pushReplacementNamed(
                  context,
                  Level.routeName,
                  arguments: prevLevel,
                );
              }
            },
          ),
        ),
        horizontalSpacer(),
        Expanded(
          child: ListTile(
            tileColor: colorMap['darkBackground'] ?? Colors.white,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: nextLevelColor, width: borderWidth),
              borderRadius: BorderRadius.circular(10.0),
            ),
            trailing: Icon(
              nextLevelIcon,
              color: colorMap['noteButtonForegroundColor'] ?? Colors.white,
            ),
            title: Text(
              nextLevel?.LevelName ?? "",
              style: TextStyle(
                color: colorMap["noteButtonForegroundColor"] ?? Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            leading: CircularPercentIndicator(
              radius: 10,
              lineWidth: 10,
              percent: min(nextNumPassedTests, nextNumTests) / nextNumTests,
              progressColor: colorMap['correctGuessIconColor'] ?? Colors.white,
              backgroundColor:
                  colorMap["waitingForGuessIconColor"] ?? Colors.white,
            ),
            onTap: () {
              if (nextLevel != null) {
                // No setLevelDetails — the next page derives its settings from
                // the LevelInfo route argument (LevelConfig).
                Navigator.pushReplacementNamed(
                  context,
                  Level.routeName,
                  arguments: nextLevel,
                );
              }
            },
          ),
        ),
      ],
    );
  }

  Widget practiceButton(String missionMode, LevelInfo levelInfo) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colorMap['brightBackground'],
              foregroundColor:
                  colorMap["buttonForegroundColor"] ?? Colors.white,
              padding: const EdgeInsets.all(8.0),
              side: BorderSide(
                color: colorMap["practiceButtonColor"] ?? Colors.white,
                width: borderWidth,
              ),
            ),
            onPressed: () {
              if (missionMode == "Melody ID") {
                Navigator.pushNamed(
                  context,
                  LevelMelodyID.routeName,
                  arguments: levelInfo,
                );
              } else if (missionMode == "Melody singing") {
                Navigator.pushNamed(
                  context,
                  LevelMelodySinging.routeName,
                  arguments: levelInfo,
                );
              }
            },
            child: FittedBox(
              fit: BoxFit.fill,
              child: Text("Practice", style: TextStyle(fontSize: 18)),
            ),
          ),
        ),
      ],
    );
  }

  Widget handsFreeButton(String missionMode, LevelInfo levelInfo) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colorMap['brightBackground'] ?? Colors.white,
              foregroundColor:
                  colorMap["buttonForegroundColor"] ?? Colors.white,
              padding: const EdgeInsets.all(8.0),
              side: BorderSide(
                color: colorMap["handsFreePracticeButtonColor"] ?? Colors.white,
                width: borderWidth,
              ),
            ),
            onPressed: () {
              if (missionMode == "Melody ID") {
                Navigator.pushNamed(
                  context,
                  LevelMelodyIDHandsFree.routeName,
                  arguments: levelInfo,
                );
              } else if (missionMode == "Melody singing") {
                Navigator.pushNamed(
                  context,
                  LevelMelodySingingHandsFree.routeName,
                  arguments: levelInfo,
                );
              }
            },
            child: FittedBox(
              fit: BoxFit.fill,
              child: Text(
                "Hands free practice",
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget takeTestButton(String missionMode, LevelInfo levelInfo) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colorMap['brightBackground'] ?? Colors.white,
              foregroundColor:
                  colorMap["buttonForegroundColor"] ?? Colors.white,
              padding: const EdgeInsets.all(12.0),
              side: BorderSide(
                color: colorMap["testButtonColor"] ?? Colors.white,
                width: borderWidth,
              ),
            ),
            onPressed: () {
              if (missionMode == "Melody ID") {
                Navigator.pushNamed(
                  context,
                  LevelMelodyIDTest.routeName,
                  arguments: levelInfo,
                );
              } else if (missionMode == "Melody singing") {
                Navigator.pushNamed(
                  context,
                  LevelMelodySingingTest.routeName,
                  arguments: levelInfo,
                );
              }
            },
            child: FittedBox(
              fit: BoxFit.fill,
              child: Text(
                "Take a test for this level",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget returnToMissionPage(
    GeneralProvider generalProvider,
    String missionMode,
    MissionInfo missionInfo,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colorMap['darkBackground'] ?? Colors.white,
              foregroundColor:
                  colorMap["noteButtonForegroundColor"] ?? Colors.white,
              padding: const EdgeInsets.all(12.0),
              side: BorderSide(
                color: getModeColor(missionMode),
                width: borderWidth,
              ),
            ),
            onPressed: () {
              resetMissionBeforeMissionPage(generalProvider, missionInfo);
              Navigator.pop(context); // pop to mission page
            },
            child: FittedBox(
              fit: BoxFit.fill,
              child: Text(
                "Return to mission main page",
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// // Place this helper widget & painter near the end of the file (before the final closing brace)
// class ScatterPlot extends StatelessWidget {
//   final List<LevelTestResults> results;
//   final LevelInfo levelInfo;

//   const ScatterPlot({
//     required this.results,
//     required this.levelInfo,
//     super.key,
//   });

//   DateTime _parseTimestamp(String s) {
//     // try ISO first, then fallback to common readable format used elsewhere
//     DateTime? dt;
//     try {
//       dt = DateFormat('yyyy-MM-dd HH:mm').parseLoose(s);
//     } catch (_) {
//       dt = DateTime.now();
//     }
//     return dt;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final points =
//         results.map((r) {
//           final dt = _parseTimestamp(r.timestamp);
//           final score = r.score;
//           final color = getTestResultColor(
//             score,
//             levelInfo.NumQuestions,
//             levelInfo.PassingScore,
//           );
//           return _Point(dt, score.toDouble(), color, r.timestamp);
//         }).toList();

//     return CustomPaint(
//       painter: _ScatterPlotPainter(points, levelInfo.NumQuestions),
//       size: Size.infinite,
//     );
//   }
// }

// class _Point {
//   final DateTime dt;
//   final double y;
//   final Color color;
//   final String rawTs;
//   _Point(this.dt, this.y, this.color, this.rawTs);
// }

// class _ScatterPlotPainter extends CustomPainter {
//   final List<_Point> points;
//   final int maxScore;
//   _ScatterPlotPainter(this.points, this.maxScore);

//   final double padding = 28.0;
//   final TextStyle axisLabelStyle = TextStyle(
//     color: Colors.white70,
//     fontSize: 10,
//   );

//   @override
//   void paint(Canvas canvas, Size size) {
//     final paintAxis =
//         Paint()
//           ..color = Colors.white24
//           ..strokeWidth = 1;
//     final paintGrid =
//         Paint()
//           ..color = Colors.white10
//           ..strokeWidth = 1;
//     final width = size.width;
//     final height = size.height;
//     if (points.isEmpty) return;

//     // compute x range
//     points.sort((a, b) => a.dt.compareTo(b.dt));
//     DateTime minX = points.first.dt;
//     DateTime maxX = points.last.dt;
//     if (minX == maxX) {
//       // make a tiny range
//       minX = minX.subtract(Duration(minutes: 1));
//       maxX = maxX.add(Duration(minutes: 1));
//     }
//     final totalSeconds = maxX.difference(minX).inSeconds.toDouble();

//     // compute y range
//     final yMax =
//         (maxScore > 0)
//             ? maxScore.toDouble()
//             : (points.map((p) => p.y).fold(0.0, (a, b) => a > b ? a : b));
//     final yMin = 0.0;

//     // draw axes
//     final left = padding;
//     final right = width - padding;
//     final top = padding;
//     final bottom = height - padding;

//     // X axis
//     canvas.drawLine(Offset(left, bottom), Offset(right, bottom), paintAxis);
//     // Y axis
//     canvas.drawLine(Offset(left, bottom), Offset(left, top), paintAxis);

//     // horizontal grid lines & y labels
//     final int yTicks = (yMax <= 5) ? yMax.toInt().clamp(1, 5) : 5;
//     for (int i = 0; i <= yTicks; i++) {
//       final t = yMin + (yMax - yMin) * (i / yTicks);
//       final dy =
//           bottom -
//           ((t - yMin) / ((yMax - yMin) == 0 ? 1 : (yMax - yMin))) *
//               (bottom - top);
//       canvas.drawLine(Offset(left, dy), Offset(right, dy), paintGrid);
//       final tp = TextPainter(
//         text: TextSpan(text: t.toInt().toString(), style: axisLabelStyle),
//         textDirection: ui.TextDirection.ltr,
//       );
//       tp.layout();
//       tp.paint(canvas, Offset(4, dy - tp.height / 2));
//     }

//     // Precompute point positions
//     final List<Offset> positions = [];
//     for (final p in points) {
//       final xFrac =
//           p.dt.difference(minX).inSeconds.toDouble() /
//           (totalSeconds == 0 ? 1 : totalSeconds);
//       final x = left + xFrac * (right - left);
//       final yFrac = (p.y - yMin) / ((yMax - yMin) == 0 ? 1 : (yMax - yMin));
//       final y = bottom - yFrac * (bottom - top);
//       positions.add(Offset(x, y));
//     }

//     // draw connecting lines: color = color of the second point in the segment
//     for (int i = 0; i < positions.length - 1; i++) {
//       final p1 = positions[i];
//       final p2 = positions[i + 1];
//       final segColor = points[i + 1].color;
//       final linePaint =
//           Paint()
//             ..color = segColor.withValues(alpha: 0.9)
//             ..strokeWidth = 2.5
//             ..style = PaintingStyle.stroke
//             ..isAntiAlias = true;
//       canvas.drawLine(p1, p2, linePaint);
//     }

//     // draw points
//     for (int i = 0; i < points.length; i++) {
//       final p = points[i];
//       final pos = positions[i];
//       final paintPoint = Paint()..color = p.color;
//       canvas.drawCircle(pos, 6.0, paintPoint);
//       // small white border
//       canvas.drawCircle(
//         pos,
//         6.0,
//         Paint()
//           ..style = PaintingStyle.stroke
//           ..color = Colors.white24
//           ..strokeWidth = 1,
//       );
//     }

//     // draw earliest/latest labels
//     final DateFormat df = DateFormat('yyyy-MM-dd HH:mm');
//     final earliest = df.format(points.first.dt.toLocal());
//     final latest = df.format(points.last.dt.toLocal());
//     final tp1 = TextPainter(
//       text: TextSpan(text: earliest, style: axisLabelStyle),
//       textDirection: ui.TextDirection.ltr,
//     );
//     tp1.layout(maxWidth: width / 2);
//     tp1.paint(canvas, Offset(left, bottom + 4));
//     final tp2 = TextPainter(
//       text: TextSpan(text: latest, style: axisLabelStyle),
//       textDirection: ui.TextDirection.ltr,
//     );
//     tp2.layout(maxWidth: width / 2);
//     tp2.paint(canvas, Offset(right - tp2.width, bottom + 4));

//     // Y-axis title
//     final tpY = TextPainter(
//       text: TextSpan(text: 'Score', style: axisLabelStyle),
//       textDirection: ui.TextDirection.ltr,
//     );
//     tpY.layout();
//     tpY.paint(canvas, Offset(left - tpY.width - 6, top));
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
// }
