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
    String campaignTitle = mappingProvider.getCampaignName(
      levelInfo.CampaignID,
    );
    String missionTitle = mappingProvider.getMissionName(levelInfo.MissionID);
    String missionMode = mappingProvider.getMissionMode(levelInfo.MissionID);
    String levelTitle = levelInfo.LevelName;
    final GeneralProvider = Provider.of<missionSettingsProvider>(context);
    // update the settings to reflect the details of this level
    GeneralProvider.setLevelDetails(
      levelInfo.Notes,
      levelInfo.NumNotes,
      levelInfo.MaxDistance,
      levelInfo.AllowRepeatedNotes,
      levelInfo.PlaybackSpeed,
      levelInfo.StartWithDo,
      levelInfo.EndWithDo,
      levelInfo.StartingDo,
      levelInfo.EndingDo,
      levelInfo.ChordFrequency,
    );
    List<LevelTestResults> ltrList = objectBox.getLevelTestResultsByLevelID(
      levelInfo.LevelID,
    );
    int numPassedTests = objectBox.numPassedTestsForLevel(
      levelInfo.LevelID,
      levelInfo.PassingScore,
    );
    String levelStatus =
        numPassedTests >= levelInfo.NumTests ? "Passed" : "Not passed yet";

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
                TextRow("Level: " + levelTitle),
                verticalSpacer(),
                TextRow("Level main page"),
                verticalSpacer(),
                statusRow(levelStatus, numPassedTests >= levelInfo.NumTests),
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
                          child: Text(
                            "Practice",
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
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
                ),
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
                ),
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
                            "Return to mission main page",
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                verticalSpacer(),
                TextRow("Level status:"),
                verticalSpacer(),
                plainText(
                  "Number of tests passed so far: " +
                      numPassedTests.toString() +
                      " / " +
                      levelInfo.NumTests.toString(),
                ),
                plainText(
                  "Passing score for each test: " +
                      levelInfo.PassingScore.toString() +
                      " / " +
                      levelInfo.NumQuestions.toString(),
                ),
                //subHeadingRow(levelStatus),
                verticalSpacer(),
                TextRow("Test history"),
                verticalSpacer(),
                ListView.builder(
                  itemCount: ltrList.length,
                  itemBuilder: (context, index) {
                    final ltr = ltrList[index];
                    return ListTile(
                      title: Text("Score: " + ltr.score.toString()),
                      subtitle: Text("Date: " + ltr.timestamp),
                    );
                  },
                  shrinkWrap: true,
                ),
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
              "Level status: " + myText,
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
}
