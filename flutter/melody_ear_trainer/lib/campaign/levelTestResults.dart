import 'package:flutter/material.dart';
import 'package:melody_ear_trainer/campaign/levelMelodyIDtest.dart';
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
    LevelInfo levelInfo = mappingProvider.getLevelInfo(levelTestResults.LevelID);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(title: Text('Melody ear trainer')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            children: [
              campaignHeader(mappingProvider.campaigns[levelInfo.CampaignID]!),
              verticalSpacer(),
              missionHeader(mappingProvider, mappingProvider.getMissions[levelTestResults.MissionID]!),
                verticalSpacer(),
                levelHeader(levelInfo),
              verticalSpacer(),
              TextRow(
                "your score: " +
                    levelTestResults.score.toString() +
                    " / " +
                    levelInfo.NumQuestions.toString(),
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
                          arguments: levelInfo,
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

  Row statusRow(String myText) {
    Color myColor = missionLevelStatusColor(myText);
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
