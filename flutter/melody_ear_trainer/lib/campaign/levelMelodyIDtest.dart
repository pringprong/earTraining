import 'package:flutter/material.dart';
import 'package:melody_ear_trainer/main.dart';
import '../providers/general_provider.dart';
import '../providers/mapping_provider.dart';
import 'package:provider/provider.dart';
import '../testPageAbstract.dart';
import '../utils/helper.dart';
import 'levelTestResults.dart';
import 'package:intl/intl.dart';
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
              campaignHeader(mappingProvider.campaigns[levelInfo.CampaignID]!),
              verticalSpacer(),
              missionHeader(
                mappingProvider,
                mappingProvider.missions[levelInfo.MissionID]!,
              ),
              verticalSpacer(),
              levelHeader(levelInfo),
              plainText(
                "Current score: " +
                    correctAnswers.toString() +
                    "/" +
                    completedQuestions.toString() +
                    "   " +
                    levelInfo.PassingScore.toString() +
                    "/" +
                    levelInfo.NumQuestions.toString() +
                    " to pass",
              ),
              verticalSpacer(),
              startTestButton(generalProvider, mappingProvider, false, levelInfo),
              verticalSpacer(),
              previousQuestionResult(),
              // verticalSpacer(),
              // TextRow("Current question: " + currentRound.toString()),
              verticalSpacer(),
              plainText("Listen to melody again:"),
              verticalSpacer(),
              playMelodyButtons(generalProvider, mappingProvider, false),
              verticalSpacer(),
              plainText(
                "Enter the solfege (" +
                    levelInfo.NumNotes.toString() +
                    " notes):",
              ),
              verticalSpacer(),
              buildNoteButtons(generalProvider, mappingProvider),
              verticalSpacer(),
              userWrittenSolfegeArea(),
              // verticalSpacer(),
              // clearAndBackspaceButtons(),
              verticalSpacer(),
              enterGuessbutton(generalProvider, mappingProvider, false, levelInfo),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void finishTest(MappingProvider mappingProvider) {
    // write a test-result row to the database, then navigate to results page
    String timestamp = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());

    // insert and when done navigate to results pag
    LevelTestResults ltr = LevelTestResults(
      CampaignID: levelInfo.CampaignID,
      MissionID: levelInfo.MissionID,
      LevelID: levelInfo.LevelID,
      score: correctAnswers,
      timestamp: timestamp,
    );
    objectBox.insertLevelTestResult(ltr);

    String thisMissionStatus = getDeepMissionStatus(
      mappingProvider,
      levelInfo.MissionID,
    );
    objectBox.updateMissionStatus(levelInfo.MissionID, thisMissionStatus);
    Navigator.pushReplacementNamed(
      context,
      LevelTestResultsPage.routeName,
      arguments: ltr,
    );
  }
}
