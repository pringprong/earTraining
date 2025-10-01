import 'package:flutter/material.dart';
import '../providers/general_provider.dart';
import '../providers/mapping_provider.dart';
import 'package:provider/provider.dart';
import '../melodyPageAbstract.dart';
import '../utils/helper.dart';

class LevelMelodyID extends MelodyPageAbstract {
  const LevelMelodyID({super.key, required super.audioController}) : super();

  static const String routeName = '/levelmelodyid';
  @override
  LevelMelodyIDState createState() => LevelMelodyIDState();
}

class LevelMelodyIDState extends MelodyPageAbstractState {
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
              campaignHeader(mappingProvider.campaigns[levelInfo.CampaignID]!),
              verticalSpacer(),
              TextRow("Mission: " + mappingProvider.getMissionName(levelInfo.MissionID)),
              verticalSpacer(),
              TextRow("Level: " + levelInfo.LevelName),
              verticalSpacer(),
              generateMelodyButton(generalProvider, mappingProvider, false),
              verticalSpacer(),
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
