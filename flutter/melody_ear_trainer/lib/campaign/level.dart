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
                  ),
                  verticalSpacer(),
                  levelHeader(levelInfo),
                  verticalSpacer(),
                  subHeadingRow(
                    "Notes you will learn in this level (black=new):",
                  ),
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
                  ),
                  verticalSpacer(),
                  buildSelectedChordButtonsHelper(
                    generalProvider,
                    mappingProvider,
                    optional: true,
                  ),
                  verticalSpacer(),
                  subHeadingRow(
                    "Practice and then take a test when you are ready:",
                  ),
                  verticalSpacer(),
                  practiceButton(missionMode, levelInfo),
                  verticalSpacer(),
                  handsFreeButton(missionMode, levelInfo),
                  verticalSpacer(),
                  takeTestButton(missionMode, levelInfo),
                  verticalSpacer(),
                  subHeadingRow("Navigation:"),
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
                    missionInfo
                  ),
                  verticalSpacer(),
                  TextRow("Test history:"),
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
    if (prevLevel != null) {
      String levelStatus = getLevelStatusWithQuery(prevLevel);
      prevLevelColor = missionLevelStatusColor(levelStatus);
    }
    Color nextLevelColor = Colors.grey;
    if (nextLevel != null) {
      String levelStatus = getLevelStatusWithQuery(nextLevel);
      nextLevelColor = missionLevelStatusColor(levelStatus);
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: prevLevelColor,
              foregroundColor:
                  colorMap["buttonForegroundColor"] ?? Colors.white,
            ),
            onPressed: () {
              if (prevLevel != null) {
                Navigator.pop(context); // pop to mission main page
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
                Navigator.pushNamed(
                  context,
                  Level.routeName,
                  arguments: prevLevel,
                );
              }
            },
            child: FittedBox(
              fit: BoxFit.fill,
              child: Text("Previous level", style: TextStyle(fontSize: 20)),
            ),
          ),
        ),
        horizontalSpacer(),
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: nextLevelColor,
              foregroundColor:
                  colorMap["buttonForegroundColor"] ?? Colors.white,
            ),
            onPressed: () {
              if (nextLevel != null) {
                Navigator.pop(context); // pop to mission main page
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
                Navigator.pushNamed(
                  context,
                  Level.routeName,
                  arguments: nextLevel,
                );
              }
            },
            child: FittedBox(
              fit: BoxFit.fill,
              child: Text("Next level", style: TextStyle(fontSize: 20)),
            ),
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
              foregroundColor: colorMap["yetAnotherGrey"] ?? Colors.white,
              padding: const EdgeInsets.all(12.0),
            ),
            onPressed: () {
              if (missionMode == "Melody ID") {
                Navigator.pushNamed(
                  context,
                  LevelMelodyID.routeName,
                  arguments: levelInfo,
                );
              }
            },
            child: FittedBox(
              fit: BoxFit.fill,
              child: Text("Practice", style: TextStyle(fontSize: 20)),
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
              foregroundColor: colorMap["yetAnotherGrey"] ?? Colors.white,
              padding: const EdgeInsets.all(12.0),
            ),
            onPressed: () {
              if (missionMode == "Melody ID") {
                Navigator.pushNamed(
                  context,
                  LevelMelodyIDHandsFree.routeName,
                  arguments: levelInfo,
                );
              }
            },
            child: FittedBox(
              fit: BoxFit.fill,
              child: Text(
                "Hands free practice",
                style: TextStyle(fontSize: 20),
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
              foregroundColor: colorMap["yetAnotherGrey"] ?? Colors.white,
              padding: const EdgeInsets.all(12.0),
            ),
            onPressed: () {
              if (missionMode == "Melody ID") {
                Navigator.pushNamed(
                  context,
                  LevelMelodyIDTest.routeName,
                  arguments: levelInfo,
                );
              }
            },
            child: FittedBox(
              fit: BoxFit.fill,
              child: Text(
                "Take a test for this level",
                style: TextStyle(fontSize: 20),
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
    MissionInfo missionInfo
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: getModeColor(missionMode),
              foregroundColor:
                  colorMap["buttonForegroundColor"] ?? Colors.white,
              padding: const EdgeInsets.all(12.0),
            ),
            onPressed: () {
              resetMissionBeforeMissionPage(
                generalProvider,
                mappingProvider,
                missionInfo,
              );
              Navigator.pop(context); // pop to level page
            },
            child: FittedBox(
              fit: BoxFit.fill,
              child: Text(
                "Return to mission main page",
                style: TextStyle(fontSize: 20),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
