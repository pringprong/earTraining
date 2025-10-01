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
    MissionSavedSettings? mss = objectBox.getMissionSavedSettingsByMissionID(
      missionInfo.MissionID,
    );
    if (mss != null) {
      generalProvider.setKeyAndInstrument(mss.key, mss.instrument);
    }
    String campaignTitle = mappingProvider.getCampaignName(
      missionInfo.CampaignID,
    );
    String missionTitle = missionInfo.MissionName;
    String mode = missionInfo.MissionMode;
    final levels = mappingProvider.getLevelsForMission(missionInfo.MissionID);
    LevelInfo lastLevel = levels.last;
    generalProvider.setNoteSelection(
      selectedKeys: lastLevel.Notes,
      notify: false,
    );
    bool status = objectBox.levelPassed(
      lastLevel.LevelID,
      lastLevel.PassingScore,
      lastLevel.NumTests,
    );
    String missionStatus = status ? "Passed" : "Not passed yet";
    objectBox.updateMissionPassed(
      missionInfo.MissionID,
      generalProvider.getSelectedKey,
      generalProvider.getSelectedInstrument,
      status,
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
                statusRow(missionStatus, status),
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
                          rightIndex < levels.length ? levels[rightIndex] : null;

                      Widget buildTile(LevelInfo lvl) {
                        int numPassedTests = objectBox.numPassedTestsForLevel(
                          lvl.LevelID,
                          lvl.PassingScore,
                        );
                        Color tileColor = numPassedTests >= lvl.NumTests
                            ? colorMap["passedColor"] ?? Colors.white
                            : numPassedTests > 0
                                ? colorMap["inProgressColor"] ?? Colors.white
                                : colorMap["notYetStartedColor"] ?? Colors.white;
                        return ListTile(
                          tileColor: tileColor,
                          dense: true,
                          title: Text(
                            lvl.LevelName,
                            style: TextStyle(
                              color: colorMap["buttonForegroundColor"] ?? Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          trailing: Text(
                            "${numPassedTests.toString()} / ${lvl.NumTests.toString()}",
                            style: TextStyle(
                              color: colorMap["buttonForegroundColor"] ?? Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          onTap: () {
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
                              child: rightLvl != null
                                  ? buildTile(rightLvl)
                                  : SizedBox.shrink(),
                            ),
                          ],
                        ),
                      );
                    },
                  ),                ],
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

  Row statusRow(String myText, bool passed) {
    Color myColor =
        passed
            ? colorMap["passedColor"] ?? Colors.white
            : colorMap["notYetStartedColor"] ?? Colors.white;
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
              "Mission status: " + myText,
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
}
