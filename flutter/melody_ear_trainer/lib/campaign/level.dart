import 'package:flutter/material.dart';
import '../../providers/general_provider.dart';
import 'package:provider/provider.dart';
import '../utils/colors.dart';
import '../utils/helper.dart';
import 'levelMelodyID.dart';
import 'levelMelodyIDhandsfree.dart';
import 'levelMelodyIDtest.dart';

class Level extends StatefulWidget {
  const Level({super.key});

  static const String routeName = '/level';
  @override
  State<Level> createState() => _LevelState();
}

class _LevelState extends State<Level> {
  @override
  Widget build(BuildContext context) {
    final levelInfo = ModalRoute.of(context)!.settings.arguments as LevelInfo;
    String campaignTitle = levelInfo.CampaignName;
    String missionTitle = levelInfo.MissionName;
    String levelTitle = levelInfo.LevelName;
    final GeneralProvider = Provider.of<missionSettingsProvider>(context);
    // update the settings to reflect the details of this level
    GeneralProvider.setLevelDetails(
      levelInfo.Notes,
      levelInfo.NumNotes,
      levelInfo.MaxDistance,
      levelInfo.AllowRepeatedNotes,
      levelInfo.PlaybackSpeed,
      levelInfo.StartWithDo,
      levelInfo.EndWithDo,
      levelInfo.StartingDo,
      levelInfo.EndingDo,
      levelInfo.ChordFrequency,
    );

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
                        if (levelInfo.MissionMode == "Melody ID") {
                          Navigator.pushNamed(
                            context,
                            LevelMelodyID.routeName,
                            arguments: levelInfo,
                          );
                        }
                      },
                      child: FittedBox(
                        fit: BoxFit.fill,
                        child: Text("Practice", style: TextStyle(fontSize: 20)),
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
                        if (levelInfo.MissionMode == "Melody ID") {
                          Navigator.pushNamed(
                            context,
                            LevelMelodyIDHandsFree.routeName,
                            arguments: levelInfo,
                          );
                        }
                      },
                      child: FittedBox(
                        fit: BoxFit.fill,
                        child: Text(
                          "Hands free practice",
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
                        if (levelInfo.MissionMode == "Melody ID") {
                          Navigator.pushNamed(
                            context,
                            LevelMelodyIDTest.routeName,
                            arguments: levelInfo,
                          );
                        }
                      },
                      child: FittedBox(
                        fit: BoxFit.fill,
                        child: Text("Test", style: TextStyle(fontSize: 20)),
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
