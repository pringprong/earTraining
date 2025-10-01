import 'package:flutter/material.dart';
import 'package:melody_ear_trainer/main.dart';
import '../utils/colors.dart';
import '../utils/helper.dart';
import 'level.dart';
import '../providers/mapping_provider.dart';
import '../providers/general_provider.dart';
import 'missionSettings.dart';
import 'package:provider/provider.dart';

class Mission extends StatefulWidget {
  const Mission({super.key});

  static const String routeName = '/mission';
  @override
  State<Mission> createState() => _MissionState();
}

class _MissionState extends State<Mission> {
  @override
  Widget build(BuildContext context) {
    final missionInfo =
        ModalRoute.of(context)!.settings.arguments as MissionInfo;
    final mappingProvider = Provider.of<MappingProvider>(context);
    final generalProvider = Provider.of<missionSettingsProvider>(context);

    String campaignTitle = mappingProvider.getCampaignName(
      missionInfo.CampaignID,
    );
    String missionTitle = missionInfo.MissionName;
    String mode = missionInfo.MissionMode;
    final levels = mappingProvider.getLevelsForMission(missionInfo.MissionID);
    String thisMissionStatus = getThisMissionStatus(levels);
    objectBox.updateMissionPassed(
      missionInfo.MissionID,
      generalProvider.getSelectedKey,
      generalProvider.getSelectedInstrument,
      thisMissionStatus,
    );

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(title: Text('Melody ear trainer')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              children: [
                headingRow(campaignTitle),
                verticalSpacer(),
                TextRow("Mission: " + missionTitle),
                verticalSpacer(),
                subHeadingRow("Mode: " + mode),
                verticalSpacer(),
                TextRow("Mission main page"),
                verticalSpacer(),
                statusRow(thisMissionStatus),
                verticalSpacer(),
                plainText("Completed " + "X" + " / " + "Y" + " levels so far"),
                verticalSpacer(),
                optionalNoteButtons(
                  generalProvider,
                  mappingProvider,
                  false,
                  mappingProvider.getCampaignOctave(missionInfo.CampaignID),
                  mappingProvider.getCampaignSet(missionInfo.CampaignID),
                  mappingProvider.getCampaignNotesInOctave(
                    missionInfo.CampaignID,
                  ),
                  missionInfo.MissionNewNotes,
                ),
                verticalSpacer(),
                optionalChordButtons(generalProvider, mappingProvider, false),
                subHeadingRow("Select a level:"),
                verticalSpacer(),
                // Levels table
                if (levels.isEmpty) ...[
                  TextRow('No levels available'),
                ] else ...[
                  // Constrain list height to avoid overflow
                  ListView.builder(
                    itemCount: (levels.length + 1) ~/ 2, // number of pairs
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, pairIndex) {
                      final int leftIndex = pairIndex * 2;
                      final int rightIndex = leftIndex + 1;
                      final LevelInfo leftLvl = levels[leftIndex];
                      final LevelInfo? rightLvl =
                          rightIndex < levels.length
                              ? levels[rightIndex]
                              : null;

                      Widget buildTile(LevelInfo lvl) {
                        int numPassedTests = objectBox.numPassedTestsForLevel(
                          lvl.LevelID,
                          lvl.PassingScore,
                        );
                        Color tileColor =
                            numPassedTests >= lvl.NumTests
                                ? colorMap["passedColor"] ?? Colors.white
                                : numPassedTests > 0
                                ? colorMap["inProgressColor"] ?? Colors.white
                                : colorMap["notYetStartedColor"] ??
                                    Colors.white;
                        return ListTile(
                          tileColor: tileColor,
                          dense: true,
                          title: Text(
                            lvl.LevelName,
                            style: TextStyle(
                              color:
                                  colorMap["buttonForegroundColor"] ??
                                  Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          trailing: Text(
                            "${numPassedTests.toString()} / ${lvl.NumTests.toString()}",
                            style: TextStyle(
                              color:
                                  colorMap["buttonForegroundColor"] ??
                                  Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          onTap: () {
                            generalProvider.setLevelDetails(
                              lvl.Notes,
                              lvl.NumNotes,
                              lvl.MaxDistance,
                              lvl.AllowRepeatedNotes,
                              lvl.PlaybackSpeed,
                              lvl.StartWithDo,
                              lvl.EndWithDo,
                              lvl.StartingDo,
                              lvl.EndingDo,
                              lvl.ChordFrequency,
                            );
                            setState(() {});
                            Navigator.pushNamed(
                              context,
                              Level.routeName,
                              arguments: lvl,
                            );
                          },
                        );
                      }

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                        child: Row(
                          children: [
                            Expanded(child: buildTile(leftLvl)),
                            SizedBox(width: 8),
                            Expanded(
                              child:
                                  rightLvl != null
                                      ? buildTile(rightLvl)
                                      : SizedBox.shrink(),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
                verticalSpacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorMap["c2f3"] ?? Colors.white,
                          foregroundColor:
                              colorMap["buttonForegroundColor"] ?? Colors.white,
                          padding: const EdgeInsets.all(12.0),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: FittedBox(
                          fit: BoxFit.fill,
                          child: Text(
                            "Return to campaign tree",
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                verticalSpacer(),
                settingsButton(missionInfo),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Row statusRow(String mls) {
    Color myColor = missionLevelStatusColor(mls);
    return Row(
      children: [
        Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.9,
          ),
          color: myColor,
          width: double.infinity,
          padding: EdgeInsets.all(12),
          child: Center(
            child: Text(
              "Mission status: " + mls,
              style: TextStyle(
                fontSize: 22,
                color: colorMap["buttonForegroundColor"] ?? Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  Row settingsButton(MissionInfo missionInfo) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colorMap["c2f3"] ?? Colors.white,
              foregroundColor:
                  colorMap["buttonForegroundColor"] ?? Colors.white,
              padding: const EdgeInsets.all(12.0),
            ),
            onPressed: () {
              Navigator.pushNamed(
                context,
                missionSettingsPage.routeName,
                arguments: missionInfo,
              );
            },
            child: FittedBox(
              fit: BoxFit.fill,
              child: Text("Mission settings", style: TextStyle(fontSize: 20)),
            ),
          ),
        ),
      ],
    );
  }

  String getThisMissionStatus(List<LevelInfo> levels) {
    LevelInfo lastLevel = levels.last;
    String statusOfLastLevel = objectBox.levelStatus(
      lastLevel.LevelID,
      lastLevel.PassingScore,
      lastLevel.NumTests,
    );
    String thisMissionStatus = statusOfLastLevel;

    if (statusOfLastLevel == "Not started yet") {
      // the last level is not started, so the mission is definitey not passed
      // check all the other levels to see whether any of them are started yet
      // if any are started or passed, then the mission is in progress
      // none of them are started or passed, then the mission is Not Started
      for (var level in levels) {
        String currentLevelStatus = objectBox.levelStatus(
          level.LevelID,
          level.PassingScore,
          level.NumTests,
        );
        if (currentLevelStatus == "In progress" ||
            currentLevelStatus == "Passed!") {
          return "In progress";
        }
      }
    }
    // if the last level is passed or in progress then the whole mission is automatically the same
    return thisMissionStatus;
  }
}
