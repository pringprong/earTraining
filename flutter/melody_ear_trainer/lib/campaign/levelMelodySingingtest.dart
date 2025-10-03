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

class LevelMelodySingingTest extends TestPageAbstract {
  const LevelMelodySingingTest({super.key, required super.audioController})
    : super();

  static const String routeName = '/levelmelodysingingtest';
  @override
  LevelMelodySingingTestState createState() => LevelMelodySingingTestState();
}

class LevelMelodySingingTestState extends TestPageAbstractState {
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
                    " to pass" 
              ),
              verticalSpacer(),
              startTestButtonSinging(generalProvider, mappingProvider, true),
              verticalSpacer(),
              previousQuestionResult(),
              verticalSpacer(),
              plainText("Sing melody based on first note:"),
              verticalSpacer(),
              solfegeTextArea(),
              verticalSpacer(),
              sayTheSolfegeButton(generalProvider, mappingProvider, compact:true),
              verticalSpacer(),
              plainText("Listen to first note again:"),
              verticalSpacer(),
              playFirstNoteButtons(generalProvider, mappingProvider),
              verticalSpacer(),
              plainText("Listen to melody to check:"),
              verticalSpacer(),
              playMelodyButtons(generalProvider, mappingProvider, true),
              verticalSpacer(),
              plainText("Did you sing it correctly?"),
              verticalSpacer(),
              reportWhetherCorrect(generalProvider, mappingProvider)
            ],
          ),
        ),
      ),
    );
  }

  @override
  void finishTest() {
    // write a test-result row to the database, then navigate to results page
    String timestamp = DateFormat('yyyy-MM-dd HH:MM').format(DateTime.now());

    // insert and when done navigate to results pag
    LevelTestResults ltr = LevelTestResults(
      CampaignID: levelInfo.CampaignID,
      MissionID: levelInfo.MissionID,
      LevelID: levelInfo.LevelID,
      score: correctAnswers,
      timestamp: timestamp,
    );
    objectBox.insertLevelTestResult(ltr);
    Navigator.pushReplacementNamed(
      context,
      LevelTestResultsPage.routeName,
      arguments: ltr,
    );
  }
}
