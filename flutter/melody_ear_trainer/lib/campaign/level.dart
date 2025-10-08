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

class Level extends StatefulWidget {
  const Level({super.key});

  static const String routeName = '/level';
  @override
  State<Level> createState() => _LevelState();
}

class _LevelState extends State<Level> {
  @override
  Widget build(BuildContext context) {
    final levelInfo = ModalRoute.of(context)!.settings.arguments as LevelInfo;
    final mappingProvider = Provider.of<MappingProvider>(context);
    String missionMode = mappingProvider.getMissionMode(levelInfo.MissionID);
    MissionInfo missionInfo = mappingProvider.getMissions[levelInfo.MissionID]!;
    final generalProvider = Provider.of<missionSettingsProvider>(context);
    List<LevelTestResults> ltrList = objectBox.getLevelTestResultsByLevelID(
      levelInfo.LevelID,
    );
    LevelInfo? nextLevel = mappingProvider.getNextLevelForMission(levelInfo);
    LevelInfo? prevLevel = mappingProvider.getPrevLevelForMission(levelInfo);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(title: Text('Melody ear trainer')),
      body: PopScope(
        canPop: true,
        onPopInvokedWithResult: (bool didPop, Object? result) {
          resetMissionBeforeMissionPage(
            generalProvider,
            mappingProvider,
            missionInfo,
          );
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Column(
                children: [
                  campaignHeader(
                    mappingProvider.campaigns[levelInfo.CampaignID]!,
                  ),
                  verticalSpacer(),
                  missionHeader(
                    mappingProvider,
                    mappingProvider.missions[levelInfo.MissionID]!,
                    max: false,
                  ),
                  verticalSpacer(),
                  levelHeader(levelInfo),
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
                  ),
                  verticalSpacer(),
                  buildSelectedChordButtonsHelper(
                    generalProvider,
                    mappingProvider,
                    optional: true,
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
                  prevAndNextLevelButtons(
                    generalProvider,
                    prevLevel,
                    nextLevel,
                  ),
                  verticalSpacer(),
                  returnToMissionPage(
                    generalProvider,
                    mappingProvider,
                    missionMode,
                    missionInfo,
                  ),
                  verticalSpacer(),
                  plainText("Test history:"),
                  verticalSpacer(),
                  ListView.builder(
                    itemCount: ltrList.length,
                    itemBuilder: (context, index) {
                      final ltr = ltrList[index];
                      return ListTile(
                        title: Text(
                          "Score: " +
                              ltr.score.toString() +
                              " / " +
                              levelInfo.NumQuestions.toString(),
                        ),
                        trailing: Text("Date: " + ltr.timestamp),
                        dense: true,
                      );
                    },
                    shrinkWrap: true,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget prevAndNextLevelButtons(
    GeneralProvider generalProvider,
    LevelInfo? prevLevel,
    LevelInfo? nextLevel,
  ) {
    Color prevLevelColor = Colors.grey;
    int prevNumPassedTests = 0;
    int prevNumTests = 1;
    int nextNumPassedTests = 0;
    int nextNumTests = 1;
    if (prevLevel != null) {
      String levelStatus = getLevelStatusWithQuery(prevLevel);
      prevLevelColor = missionLevelStatusColor(levelStatus);
      prevNumPassedTests = objectBox.numPassedTestsForLevel(
        prevLevel.LevelID,
        prevLevel.PassingScore,
      );
      prevNumTests = prevLevel.NumTests;
    }
    Color nextLevelColor = Colors.grey;
    if (nextLevel != null) {
      String levelStatus = getLevelStatusWithQuery(nextLevel);
      nextLevelColor = missionLevelStatusColor(levelStatus);
      nextNumPassedTests = objectBox.numPassedTestsForLevel(
        nextLevel.LevelID,
        nextLevel.PassingScore,
      );
      nextNumTests = nextLevel.NumTests;
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          child: ListTile(
            tileColor: prevLevelColor,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: prevLevelColor, width: 0.0),
              borderRadius: BorderRadius.circular(10.0),
            ),
            leading: Icon(
              prevLevelIcon,
              color: colorMap['buttonForegroundColor'] ?? Colors.white,
            ),
            title: Text(
              prevLevel?.LevelName ?? "",
              style: TextStyle(
                color: colorMap["buttonForegroundColor"] ?? Colors.white,
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
                generalProvider.setLevelDetails(
                  prevLevel.Notes,
                  prevLevel.NumNotes,
                  prevLevel.MaxDistance,
                  prevLevel.AllowRepeatedNotes,
                  prevLevel.PlaybackSpeed,
                  prevLevel.StartWithDo,
                  prevLevel.EndWithDo,
                  prevLevel.StartingDo,
                  prevLevel.EndingDo,
                  prevLevel.ChordFrequency,
                );
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
            tileColor: nextLevelColor,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: nextLevelColor, width: 0.0),
              borderRadius: BorderRadius.circular(10.0),
            ),
            trailing: Icon(
              nextLevelIcon,
              color: colorMap['buttonForegroundColor'] ?? Colors.white,
            ),
            title: Text(
              nextLevel?.LevelName ?? "",
              style: TextStyle(
                color: colorMap["buttonForegroundColor"] ?? Colors.white,
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
                generalProvider.setLevelDetails(
                  nextLevel.Notes,
                  nextLevel.NumNotes,
                  nextLevel.MaxDistance,
                  nextLevel.AllowRepeatedNotes,
                  nextLevel.PlaybackSpeed,
                  nextLevel.StartWithDo,
                  nextLevel.EndWithDo,
                  nextLevel.StartingDo,
                  nextLevel.EndingDo,
                  nextLevel.ChordFrequency,
                );
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
              backgroundColor: colorMap['practiceButtonColor'],
              foregroundColor: colorMap["buttonForegroundColor"] ?? Colors.white,
              padding: const EdgeInsets.all(8.0),
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
              backgroundColor:
                  colorMap['handsFreePracticeButtonColor'] ?? Colors.white,
              foregroundColor: colorMap["buttonForegroundColor"] ?? Colors.white,
              padding: const EdgeInsets.all(8.0),
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
              backgroundColor: colorMap['testButtonColor'] ?? Colors.white,
              foregroundColor: colorMap["buttonForegroundColor"] ?? Colors.white,
              padding: const EdgeInsets.all(12.0),
                          side: BorderSide(
              color: colorMap["buttonForegroundColor"] ?? Colors.white,
              width: 3.0,
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
    MappingProvider mappingProvider,
    String missionMode,
    MissionInfo missionInfo,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: getModeColor(missionMode),
              foregroundColor:
                  colorMap["noteButtonForegroundColor"] ?? Colors.white,
              padding: const EdgeInsets.all(12.0),
            ),
            onPressed: () {
              resetMissionBeforeMissionPage(
                generalProvider,
                mappingProvider,
                missionInfo,
              );
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
