import 'package:flutter/material.dart';
import '../providers/general_provider.dart';
import '../providers/mapping_provider.dart';
import 'package:provider/provider.dart';
import '../utils/colors.dart';
import '../melodyPageAbstract.dart';
import '../utils/helper.dart';

class LevelMelodyIDTest extends MelodyPageAbstract {
  const LevelMelodyIDTest({super.key, required super.audioController}) : super();

  static const String routeName = '/levelmelodyidtest';
  @override
  LevelMelodyIDTestState createState() => LevelMelodyIDTestState();
}

class LevelMelodyIDTestState extends MelodyPageAbstractState {
  @override
  Widget build(BuildContext context) {
    final levelInfo = ModalRoute.of(context)!.settings.arguments as LevelInfo;

    final mappingProvider = Provider.of<MappingProvider>(context);
    final generalProvider = Provider.of<missionSettingsProvider>(context);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(title: Text('Practice')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              headingRow(levelInfo.CampaignName),
              verticalSpacer(),
              TextRow("Mission name: " + levelInfo.MissionName),
              verticalSpacer(),
              TextRow("Level name: " + levelInfo.LevelName),
              verticalSpacer(),
              plainText("Passing score: " + levelInfo.PassingScore.toString() 
                + " / " + levelInfo.NumQuestions.toString()),
              verticalSpacer(),
              //generateMelodyButton(generalProvider, mappingProvider, false),
              //verticalSpacer(),
              subHeadingRow("Listen to generated melody:"),
              verticalSpacer(),
              playMelodyButtons(generalProvider, mappingProvider, false),
              verticalSpacer(),
              solfegeExpansionTile(generalProvider, mappingProvider),
              verticalSpacer(),
              subHeadingRow("Play the melody back:"),
              verticalSpacer(),
              buildNoteButtons(generalProvider, mappingProvider),
              verticalSpacer(),
              userWrittenSolfegeArea(),
              verticalSpacer(),
              clearAndBackspaceButtons(),
              verticalSpacer(),
              compareButton(),
              verticalSpacer(),
              subHeadingRow("Listen to your melody:"),
              verticalSpacer(),
              userWrittenMelodyButtons(generalProvider, mappingProvider),
            ],
          ),
        ),
      ),
    );
  }
}
