import 'package:flutter/material.dart';
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
      assessment =
          "Level in progress! You need to pass " +
          (levelInfo.NumTests - numPassedTests).toString() +
          " more tests to pass this level. Do another test!";
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
                campaignHeader(mappingProvider.campaigns[levelInfo.CampaignID]!),
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
                ...optionalLevelPageButton(returnToLevelPage, context),
                ...optionalNextLevelButton(goToNextLevel, nextLevel, context),
                ...optionalMissionPageButton(returnToMissionPage, context),
                ...optionalCampaignTreeButton(returnToCampaignTree, context),
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
                Navigator.pop(context);
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
    LevelInfo? nextLevel,
    dynamic context,
  ) {
    if (!showbutton || nextLevel == null) {
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
                backgroundColor: colorMap["c2f3"] ?? Colors.white,
                foregroundColor:
                    colorMap["buttonForegroundColor"] ?? Colors.white,
                padding: const EdgeInsets.all(12.0),
              ),
              onPressed: () {
                Navigator.pop(context); // pops to level main page
                Navigator.pop(context); // pops to mission main page
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

  List<Widget> optionalLevelPageButton(bool showbutton, dynamic context) {
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

  List<Widget> optionalMissionPageButton(bool showbutton, dynamic context) {
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
                backgroundColor: colorMap["c2f3"] ?? Colors.white,
                foregroundColor:
                    colorMap["buttonForegroundColor"] ?? Colors.white,
                padding: const EdgeInsets.all(12.0),
              ),
              onPressed: () {
                Navigator.pop(context);
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
    ];
  }

  List<Widget> optionalCampaignTreeButton(bool showbutton, dynamic context) {
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
                backgroundColor: colorMap["c2f3"] ?? Colors.white,
                foregroundColor:
                    colorMap["buttonForegroundColor"] ?? Colors.white,
                padding: const EdgeInsets.all(12.0),
              ),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
                Navigator.pop(context);
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
