import 'package:flutter/material.dart';
import 'package:melody_ear_trainer/campaign/levelMelodyIDtest.dart';
import 'package:melody_ear_trainer/main.dart';
import '../../providers/mapping_provider.dart';
import 'package:provider/provider.dart';
import '../utils/colors.dart';
import '../utils/helper.dart';

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
    String campaignTitle =
        mappingProvider.getCampaigns[levelTestResults.CampaignID]!.CampaignName;
    MissionInfo mi = mappingProvider.getMissions[levelTestResults.MissionID]!;
    LevelInfo lvli = mappingProvider.getLevelInfo(levelTestResults.LevelID);
    String missionTitle = mi.MissionName;
    String levelTitle = lvli.LevelName;
    int numPassedTests = objectBox.numPassedTestsForLevel(
      lvli.LevelID,
      lvli.PassingScore,
    );
    String levelStatus =
        numPassedTests >= lvli.NumTests ? "Passed" : "Not passed yet";
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(title: Text('Melody ear trainer')),
      body: Padding(
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
              TextRow("Level status:"),
              verticalSpacer(),
              statusRow(levelStatus, numPassedTests >= lvli.NumTests),
              plainText(
                "Number of passed tests: " +
                    numPassedTests.toString() +
                    " /  " +
                    lvli.NumTests.toString(),
              ),
              plainText(
                "Passing score for each test: " + lvli.PassingScore.toString(),
              ),
              verticalSpacer(),
              TextRow(
                "your score: " +
                    levelTestResults.score.toString() +
                    " / " +
                    lvli.NumQuestions.toString(),
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
                        Navigator.pushNamed(
                          context,
                          LevelMelodyIDTest.routeName,
                          arguments: lvli,
                        );
                      },
                      child: FittedBox(
                        fit: BoxFit.fill,
                        child: Text(
                          "Level not passed yet? Do another test",
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
                          "Return to level main page",
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
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
