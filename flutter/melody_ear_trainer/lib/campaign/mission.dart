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
                optionalNoteButtons(generalProvider, mappingProvider, false),
                verticalSpacer(),
                optionalChordButtons(generalProvider, mappingProvider, false),
                subHeadingRow("Select a level from the table :"),
                verticalSpacer(),
                // Levels table
                if (levels.isEmpty) ...[
                  TextRow('No levels available'),
                ] else ...[
                  // Constrain table height to avoid overflow
                  SizedBox(
                    height: 500,
                    child: SingleChildScrollView(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          showCheckboxColumn: false,
                          columns: const [
                            DataColumn(label: Text('Levels')),
                            DataColumn(label: Text('Status')),
                            DataColumn(label: Text('# Tests Passed')),
                          ],
                          rows:
                              levels.map((LevelInfo lvl) {
                                int numPassedTests = objectBox
                                    .numPassedTestsForLevel(
                                      lvl.LevelID,
                                      lvl.PassingScore,
                                    );
                                String levelStatus =
                                    numPassedTests >= lvl.NumTests
                                        ? "Passed"
                                        : "Not passed yet";
                                Color rowColor =
                                    numPassedTests >= lvl.NumTests
                                        ? colorMap["passedColor"] ??
                                            Colors.white
                                        : colorMap["notYetPassedColor"] ??
                                            Colors.white;
                                return DataRow(
                                  // make the row selectable/clickable
                                  color: WidgetStateProperty.all(rowColor),
                                  onSelectChanged: (selected) {
                                    if (selected == true) {
                                      Navigator.pushNamed(
                                        context,
                                        Level.routeName,
                                        arguments: lvl,
                                      );
                                    }
                                  },
                                  cells: [
                                    DataCell(
                                      Text(
                                        lvl.LevelName,
                                        style: TextStyle(
                                          color:
                                              colorMap["buttonForegroundColor"] ??
                                              Colors.white,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        levelStatus,
                                        style: TextStyle(
                                          color:
                                              colorMap["buttonForegroundColor"] ??
                                              Colors.white,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        numPassedTests.toString() +
                                            " / " +
                                            lvl.NumTests.toString(),
                                        style: TextStyle(
                                          color:
                                              colorMap["buttonForegroundColor"] ??
                                              Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                        ),
                      ),
                    ),
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

  Row statusRow(String myText, bool passed) {
    Color myColor =
        passed
            ? colorMap["passedColor"] ?? Colors.white
            : colorMap["notYetPassedColor"] ?? Colors.white;
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
