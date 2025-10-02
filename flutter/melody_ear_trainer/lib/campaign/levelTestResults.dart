import 'package:flutter/material.dart';
import 'package:melody_ear_trainer/providers/general_provider.dart';
import 'levelMelodyIDtest.dart';
import '../../main.dart';
import '../../providers/mapping_provider.dart';
import 'package:provider/provider.dart';
import '../utils/colors.dart';
import '../utils/helper.dart';
import 'level.dart';

class LevelTestResultsPage extends StatefulWidget {
  const LevelTestResultsPage({super.key});

  static const String routeName = '/leveltestresults';
  @override
  State<LevelTestResultsPage> createState() => _LevelTestResultsPageState();
}

class _LevelTestResultsPageState extends State<LevelTestResultsPage> {
  @override
  Widget build(BuildContext context) {
    final levelTestResults =
        ModalRoute.of(context)!.settings.arguments as LevelTestResults;
    final generalProvider = Provider.of<missionSettingsProvider>(context);
    final mappingProvider = Provider.of<MappingProvider>(context);
    LevelInfo levelInfo = mappingProvider.getLevelInfo(
      levelTestResults.LevelID,
    );
    bool redoTest = true;
    bool returnToLevelPage = true;
    bool goToNextLevel = false;
    bool returnToMissionPage = false;
    bool returnToCampaignTree = false;
    String passOrFail = "";
    Color myColor = Colors.white;
    int numPassedTests = objectBox.numPassedTestsForLevel(
      levelInfo.LevelID,
      levelInfo.PassingScore,
    );
    String levelStatus = getLevelStatus(numPassedTests, levelInfo);
    String missionStatus = getMissionStatus(
      mappingProvider,
      mappingProvider.getMissions[levelTestResults.MissionID]!,
    );
    String missionMode = mappingProvider.getMissionMode(
      levelTestResults.MissionID,
    );
    if (levelTestResults.score >= levelInfo.NumQuestions) {
      passOrFail = "PERFECT!";
      myColor = colorMap['correctGuessIconColor'] ?? Colors.white;
    } else if (levelTestResults.score >= levelInfo.PassingScore) {
      passOrFail = "Passed!";
      myColor = colorMap['correctGuessButtonColor'] ?? Colors.white;
    } else if (levelInfo.PassingScore - levelTestResults.score <= 1) {
      passOrFail = "Almost, keep trying!";
      myColor = colorMap['incorrectGuessButtonColor'] ?? Colors.white;
    } else {
      passOrFail = "More practice needed";
      myColor = colorMap['incorrectGuessIconColor'] ?? Colors.white;
    }

    String assessment = "";
    if (missionStatus == "Passed!") {
      assessment = "Mission passed! Suggest you return to campaign tree";
      redoTest = false;
      goToNextLevel = false;
      returnToLevelPage = false;
      returnToMissionPage = true;
      returnToCampaignTree = true;
    } else if (levelStatus == "Passed!") {
      assessment = "Level passed! Go to the next level";
      redoTest = false;
      returnToLevelPage = false;
      goToNextLevel = true;
      returnToMissionPage = true;
      returnToCampaignTree = true;
    } else if (numPassedTests > 0) {
      int remainingTests = levelInfo.NumTests - numPassedTests;
      assessment =
          "Level in progress!\nYou need to pass " +
          remainingTests.toString() +
          " more test" +
          (remainingTests > 1 ? "s" : "") +
          " to pass this level.\nDo another test!";
      redoTest = true;
      goToNextLevel = false;
      returnToLevelPage = true;
      returnToMissionPage = true;
      returnToCampaignTree = true;
    } else if (passOrFail != "More practice needed") {
      assessment =
          "You can get more practice from the Level Main Page or you can try the test again";
      redoTest = true;
      goToNextLevel = false;
      returnToLevelPage = true;
      returnToMissionPage = true;
      returnToCampaignTree = true;
    } else {
      assessment =
          "Recommend you get more practice from the Level Main Page or try an easier level";
      redoTest = false;
      goToNextLevel = false;
      returnToLevelPage = true;
      returnToMissionPage = true;
      returnToCampaignTree = true;
    }
    LevelInfo? nextLevel = null;
    if (goToNextLevel) {
      // need to determine what the next level even is
      nextLevel = mappingProvider.getNextLevelForMission(levelInfo);
      if (nextLevel == null) {
        // this shouldn't happen because we should have caught it at Mission Passed above
        goToNextLevel = false;
        assessment =
            assessment = "Mission passed! Suggest you return to campaign tree";
      }
    }

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
                  mappingProvider.campaigns[levelInfo.CampaignID]!,
                ),
                verticalSpacer(),
                missionHeader(
                  mappingProvider,
                  mappingProvider.getMissions[levelTestResults.MissionID]!,
                ),
                verticalSpacer(),
                levelHeader(levelInfo),
                verticalSpacer(),
                levelTestResultsCard(
                  levelTestResults,
                  levelInfo,
                  passOrFail,
                  myColor,
                ),
                verticalSpacer(),
                assessmentCard(assessment),
                verticalSpacer(),
                ...optionalRedoTestButton(redoTest, levelInfo, context),
                ...optionalLevelPageButton(returnToLevelPage, levelStatus,context),
                ...optionalNextLevelButton(
                  goToNextLevel,
                  generalProvider,
                  nextLevel,
                  context,
                ),
                ...optionalMissionPageButton(
                  returnToMissionPage,
                  generalProvider,
                  mappingProvider,
                  missionMode,
                  levelInfo,
                  context,
                ),
                ...optionalCampaignTreeButton(
                  returnToCampaignTree,
                  levelInfo.CampaignID,
                  context,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget levelTestResultsCard(
    LevelTestResults ltr,
    LevelInfo levelInfo,
    String passOrFail,
    Color myColor,
  ) {
    return Row(
      children: [
        Expanded(
          child: Card(
            color: colorMap["buttonForegroundColor"] ?? Colors.white,
            borderOnForeground: true,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: myColor, width: 3.0),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: (Card(
                color: colorMap["buttonForegroundColor"] ?? Colors.white,
                borderOnForeground: true,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: myColor, width: 3.0),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Wrap(
                      children: [
                        Column(
                          children: [
                            Text(
                              "Test result:",
                              style: TextStyle(fontSize: 24, color: myColor),
                              textAlign: TextAlign.center,
                            ),
                            verticalSpacer(),
                            Text(
                              passOrFail,
                              style: TextStyle(
                                fontSize: 28,
                                color: myColor,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            verticalSpacer(),
                            Text(
                              "Score: " +
                                  ltr.score.toString() +
                                  " / " +
                                  levelInfo.NumQuestions.toString(),
                              style: TextStyle(fontSize: 22, color: myColor),
                              textAlign: TextAlign.center,
                            ),
                            verticalSpacer(),
                            Text(
                              "Passing score: " +
                                  levelInfo.PassingScore.toString(),
                              style: TextStyle(fontSize: 22, color: myColor),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              )),
            ),
          ),
        ),
      ],
    );
  }

  Widget assessmentCard(String assessment) {
    Color myColor = colorMap['borderColor'] ?? Colors.white;
    return Row(
      children: [
        Expanded(
          child: Card(
            color: colorMap["buttonForegroundColor"] ?? Colors.white,
            borderOnForeground: true,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: myColor, width: 1.0),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: (Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Wrap(
                    children: [
                      Column(
                        children: [
                          // Text(
                          //   "Assessment:",
                          //   style: TextStyle(fontSize: 20, color: myColor),
                          //   textAlign: TextAlign.center,
                          // ),
                          // verticalSpacer(),
                          Text(
                            assessment,
                            style: TextStyle(fontSize: 18, color: myColor),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> optionalRedoTestButton(
    bool redoTest,
    LevelInfo levelInfo,
    dynamic context,
  ) {
    if (!redoTest) {
      // finished the level, so no need to repeat test
      return [SizedBox(height: 0)];
    }
    String buttonText = "Repeat test";
    return [
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
                Navigator.pop(context); // pop to level page
                Navigator.pushNamed(
                  context,
                  LevelMelodyIDTest.routeName,
                  arguments: levelInfo,
                );
              },
              child: FittedBox(
                fit: BoxFit.fill,
                child: Text(buttonText, style: TextStyle(fontSize: 20)),
              ),
            ),
          ),
        ],
      ),
    ];
  }

  List<Widget> optionalNextLevelButton(
    bool showbutton,
    GeneralProvider generalProvider,
    LevelInfo? nextLevel,
    dynamic context,
  ) {
    if (!showbutton || nextLevel == null) {
      return [SizedBox(height: 0)];
    }
    String levelStatus = getLevelStatusWithQuery(nextLevel);
    Color nextLevelColor = missionLevelStatusColor(levelStatus);   
    return [
      verticalSpacer(),
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: nextLevelColor,
                foregroundColor:
                    colorMap["buttonForegroundColor"] ?? Colors.white,
                padding: const EdgeInsets.all(12.0),
              ),
              onPressed: () {
                Navigator.pop(context); // pop to level main page
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
              },
              child: FittedBox(
                fit: BoxFit.fill,
                child: Text("Next level", style: TextStyle(fontSize: 20)),
              ),
            ),
          ),
        ],
      ),
    ];
  }

  List<Widget> optionalLevelPageButton(
    bool showbutton, 
    String levelStatus,
    dynamic context) {
    if (!showbutton) {
      return [SizedBox(height: 0)];
    }
    return [
      verticalSpacer(),
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: missionLevelStatusColor(levelStatus),
                foregroundColor:
                    colorMap["buttonForegroundColor"] ?? Colors.white,
                padding: const EdgeInsets.all(12.0),
              ),
              onPressed: () {
                Navigator.pop(context); // pop to level page
              },
              child: FittedBox(
                fit: BoxFit.fill,
                child: Text(
                  "Return to level main page",
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
          ),
        ],
      ),
    ];
  }

  List<Widget> optionalMissionPageButton(
    bool showbutton,
    GeneralProvider generalProvider,
    MappingProvider mappingProvider,
    String mode,
    LevelInfo levelInfo,
    dynamic context,
  ) {
    if (!showbutton) {
      return [SizedBox(height: 0)];
    }
    return [
      verticalSpacer(),
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: getModeColor(mode),
                foregroundColor:
                    colorMap["buttonForegroundColor"] ?? Colors.white,
                padding: const EdgeInsets.all(12.0),
              ),
              onPressed: () {
                Navigator.pop(context); // pop to level page
                resetMissionBeforeMissionPage(
                  generalProvider,
                  mappingProvider,
                  mappingProvider.getMissions[levelInfo.MissionID]!,
                );
                Navigator.pop(context); // pop to mission page
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
    ];
  }

  List<Widget> optionalCampaignTreeButton(
    bool showbutton,
    String campaignID,
    dynamic context,
  ) {
    if (!showbutton) {
      return [SizedBox(height: 0)];
    }
    return [
      verticalSpacer(),
      Row(
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
                Navigator.pop(context); // pop to level page
                Navigator.pop(context); // pop to mission page
                Navigator.pop(context); // pop to campaign tree
              },
              child: FittedBox(
                fit: BoxFit.fill,
                child: Text(
                  "Return to campaign tree page",
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
          ),
        ],
      ),
    ];
  }
}
