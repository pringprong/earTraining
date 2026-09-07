import 'package:flutter/material.dart';
import 'package:melody_ear_trainer/main.dart';
import '../providers/general_provider.dart';
import '../providers/mapping_provider.dart';
import 'package:provider/provider.dart';
import '../testPageAbstract.dart';
import '../utils/helper.dart';
import 'levelTestResults.dart';
import 'package:intl/intl.dart';

class LevelChordSingingTest extends TestPageAbstract {
  const LevelChordSingingTest({super.key, required super.audioController})
    : super();

  static const String routeName = '/levelchordsingingtest';
  @override
  LevelChordSingingTestState createState() => LevelChordSingingTestState();
}

class LevelChordSingingTestState extends TestPageAbstractState {
  @override
  void onLevelEntered() {
    numberOfQuestions = levelInfo!.NumQuestions;
  }

  @override
  Widget build(BuildContext context) {
    final levelInfo = this.levelInfo!;
    final mappingProvider = context.read<MappingProvider>();
    final generalProvider = context.read<MissionSettingsProvider>();
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(title: Text('Test')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              CampaignHeaderRow(campaignId: levelInfo.CampaignID),
              verticalSpacer(),
              MissionHeaderRow(missionId: levelInfo.MissionID),
              verticalSpacer(),
              LevelHeaderRow(levelId: levelInfo.LevelID),
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
              startTestButtonSinging(generalProvider, mappingProvider, true, levelInfo),
              verticalSpacer(),
              previousQuestionResult(),
              verticalSpacer(),
              plainText("Sing melody based on first note:"),
              verticalSpacer(),
              solfegeTextArea(),
              verticalSpacer(),
              sayTheSolfegeButton(
                generalProvider,
                mappingProvider,
                compact: true,
              ),
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
              subHeadingRow("Chords for reference"),
              verticalSpacer(),
              buildSelectedChordButtonsHelper(
                generalProvider,
                mappingProvider,
                optional: true,
                selectedNotes: levelInfo.Notes.toSet(),
                chordFrequencyOverride: levelInfo.ChordFrequency,
              ),
              verticalSpacer(),
              reportWhetherCorrect(generalProvider, mappingProvider, levelInfo),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void finishTest(MappingProvider mappingProvider) {
    // write a test-result row to the database, then navigate to results page
    final levelInfo = this.levelInfo!;
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
