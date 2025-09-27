import 'package:flutter/material.dart';
import 'package:melody_ear_trainer/campaign/levelMelodyIDtest.dart';
import '../../providers/mapping_provider.dart';
import 'package:provider/provider.dart';
import '../utils/colors.dart';
import '../utils/helper.dart';
//import 'levelMelodyID.dart';
//import 'levelMelodyIDhandsfree.dart';
//import 'levelMelodyIDtest.dart';

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
    MissionInfo mi =
        mappingProvider.getMissions[levelTestResults.MissionID]!;
    LevelInfo lvli = mappingProvider.getLevelInfo(levelTestResults.LevelID);
    String missionTitle = mi.MissionName;
    String levelTitle = lvli.LevelName;
    //final GeneralProvider = Provider.of<missionSettingsProvider>(context);

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
                        backgroundColor: c2f3,
                        foregroundColor: buttonForegroundColor,
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
                          "Do another test",
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
                        backgroundColor: c2f3,
                        foregroundColor: buttonForegroundColor,
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
}
