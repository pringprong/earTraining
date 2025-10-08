import 'package:flutter/material.dart';
import 'package:melody_ear_trainer/main.dart';
import '../utils/colors.dart';
import '../utils/helper.dart';
import 'level.dart';
import '../providers/mapping_provider.dart';
import '../providers/general_provider.dart';
import 'missionSettings.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'dart:math';

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
    final levels = mappingProvider.getLevelsForMission(missionInfo.MissionID);
    // String thisMissionStatus = getDeepMissionStatus(
    //   mappingProvider,
    //   missionInfo.MissionID,
    // );
    objectBox.createOrUpdateMissionDetails(
      missionInfo.MissionID,
      generalProvider.getSelectedKey,
      generalProvider.getSelectedInstrument,
      //thisMissionStatus,
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
                campaignHeader(
                  mappingProvider.campaigns[missionInfo.CampaignID]!,
                ),
                verticalSpacer(),
                missionHeader(mappingProvider, missionInfo, max: true),
                verticalSpacer(),
                plainText("Notes (colorful text=new):"),
                verticalSpacer(),
                buildNotesGrid(
                  generalProvider,
                  mappingProvider,
                  false,
                  mappingProvider.getCampaignOctave(missionInfo.CampaignID),
                  mappingProvider.getCampaignSet(missionInfo.CampaignID),
                  mappingProvider.getCampaignNotesInOctave(
                    missionInfo.CampaignID,
                  ),
                  missionInfo.MissionNewNotes,
                  true,
                  true,
                ),
                verticalSpacer(),
                buildSelectedChordButtonsHelper(
                  generalProvider,
                  mappingProvider,
                  optional: true,
                ),
                plainText("Select a level:"),
                verticalSpacer(),
                ...levelButtons(levels, generalProvider),
                verticalSpacer(),
                plainText("Navigation:"),
                verticalSpacer(),
                returnToCampaignButton(missionInfo.CampaignID),
                verticalSpacer(),
                settingsButton(missionInfo),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Row settingsButton(MissionInfo missionInfo) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  colorMap["waitingForGuessIconColor"] ?? Colors.white,
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

  List<Widget> levelButtons(
    List<LevelInfo> levels,
    GeneralProvider generalProvider,
  ) {
    if (levels.isEmpty) {
      return [TextRow('No levels available')];
    } else {
      return [
        // Constrain list height to avoid overflow
        ListView.builder(
          itemCount: (levels.length + 2) ~/ 3, // number of pairs
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (context, pairIndex) {
            final int leftIndex = pairIndex * 3;
            final int middleIndex = leftIndex + 1;
            final int rightIndex = leftIndex + 2;
            final LevelInfo leftLvl = levels[leftIndex];
            final LevelInfo? middleLvl =
                middleIndex < levels.length ? levels[middleIndex] : null;
            final LevelInfo? rightLvl =
                rightIndex < levels.length ? levels[rightIndex] : null;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3.0),
              child: Row(
                children: [
                  Expanded(child: buildTile(leftLvl, generalProvider)),
                  horizontalSpacer(),
                  Expanded(
                    child:
                        middleLvl != null
                            ? buildTile(middleLvl, generalProvider)
                            : SizedBox.shrink(),
                  ),
                  horizontalSpacer(),
                  Expanded(
                    child:
                        rightLvl != null
                            ? buildTile(rightLvl, generalProvider)
                            : SizedBox.shrink(),
                  ),
                ],
              ),
            );
          },
        ),
      ];
    }
  }

  Widget buildTile(LevelInfo lvl, GeneralProvider generalProvider) {
    int numPassedTests = objectBox.numPassedTestsForLevel(
      lvl.LevelID,
      lvl.PassingScore,
    );
    Color tileColor =
        numPassedTests >= lvl.NumTests
            ? colorMap["passedColor"] ?? Colors.white
            : numPassedTests > 0
            ? colorMap["inProgressColor"] ?? Colors.white
            : colorMap["notYetStartedColor"] ?? Colors.white;
    return ListTile(
      tileColor: tileColor,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: tileColor, width: 0.0),
        borderRadius: BorderRadius.circular(10.0),
      ),
      title: Text(
        lvl.LevelName,
        style: TextStyle(
          color: colorMap["buttonForegroundColor"] ?? Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: CircularPercentIndicator(
        radius: 10,
        lineWidth: 10,
        percent: min(numPassedTests, lvl.NumTests) / lvl.NumTests,
        progressColor: colorMap['correctGuessIconColor'] ?? Colors.white,
        backgroundColor: colorMap["waitingForGuessIconColor"] ?? Colors.white,
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
        Navigator.pushNamed(context, Level.routeName, arguments: lvl);
      },
    );
  }

  Widget returnToCampaignButton(String campaignID) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: getCampaignColor(campaignID),
              foregroundColor:
                  colorMap["buttonForegroundColor"] ?? Colors.white,
              padding: const EdgeInsets.all(12.0),
            ),
            onPressed: () {
              Navigator.pop(context); // pop to campaign tree
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
    );
  }
}
