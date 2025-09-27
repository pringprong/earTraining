import 'package:flutter/material.dart';
import '../providers/general_provider.dart';
import '../providers/mapping_provider.dart';
import 'package:provider/provider.dart';
import '../utils/colors.dart';
import '../testPageAbstract.dart';
import '../utils/helper.dart';
import 'levelTestResults.dart';
//import '../utils/resultsDB.dart';

class LevelMelodyIDTest extends TestPageAbstract {
  const LevelMelodyIDTest({super.key, required super.audioController})
    : super();

  static const String routeName = '/levelmelodyidtest';
  @override
  LevelMelodyIDTestState createState() => LevelMelodyIDTestState();
}

class LevelMelodyIDTestState extends TestPageAbstractState {
  LevelInfo levelInfo = LevelInfo(
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    0,
    0,
    false,
    "",
    true,
    true,
    "",
    ""
        "",
    "",
    0,
    0,
    0,
  );

  @override
  Widget build(BuildContext context) {
    levelInfo = ModalRoute.of(context)!.settings.arguments as LevelInfo;

    final mappingProvider = Provider.of<MappingProvider>(context);
    final generalProvider = Provider.of<missionSettingsProvider>(context);
    numberOfQuestions = levelInfo.NumQuestions;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(title: Text('Test')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              headingRow(levelInfo.CampaignName),
              verticalSpacer(),
              TextRow("Mission: " + levelInfo.MissionName),
              verticalSpacer(),
              TextRow("Level: " + levelInfo.LevelName),
              verticalSpacer(),
              plainText(
                "Passing score: " +
                    levelInfo.PassingScore.toString() +
                    " / " +
                    levelInfo.NumQuestions.toString(),
              ),
              verticalSpacer(),
              plainText(
                "Current score: " +
                    correctAnswers.toString() +
                    " / " +
                    completedQuestions.toString(),
              ),
              verticalSpacer(),
              startTestButton(generalProvider, mappingProvider, false),
              verticalSpacer(),
              previousQuestionResult(),
              verticalSpacer(),
              TextRow("Current question: " + currentRound.toString()),
              verticalSpacer(),
              subHeadingRow("Listen to melody again:"),
              verticalSpacer(),
              playMelodyButtons(generalProvider, mappingProvider, false),
              verticalSpacer(),
              //solfegeExpansionTile(generalProvider, mappingProvider),
              //verticalSpacer(),
              subHeadingRow("Enter the solfege for the melody:"),
              verticalSpacer(),
              buildNoteButtons(generalProvider, mappingProvider),
              verticalSpacer(),
              userWrittenSolfegeArea(),
              verticalSpacer(),
              clearAndBackspaceButtons(),
              verticalSpacer(),
              enterGuessbutton(generalProvider, mappingProvider, false),
              //compareButton(),
              //verticalSpacer(),
              //subHeadingRow("Listen to your melody:"),
              // verticalSpacer(),
              // userWrittenMelodyButtons(generalProvider, mappingProvider),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void finishTest() {
    // write a test-result row to the database, then navigate to results page
    final timestamp = DateTime.now().toIso8601String();
    // final entry = TestResult(
    //   timestamp: timestamp,
    //   levelID: levelInfo.LevelID,
    //   numQuestions: levelInfo.NumQuestions,
    //   score: correctAnswers,
    // );

    // insert and when done navigate to results pag
    LevelTestResults ltr = LevelTestResults(
      levelInfo.CampaignID,
      levelInfo.MissionID,
      levelInfo.LevelID, 
      correctAnswers,
      timestamp
      );
    Navigator.pop(context);
    Navigator.pushNamed(
      context,
      LevelTestResultsPage.routeName,
      arguments: ltr,
    );
  }
}
