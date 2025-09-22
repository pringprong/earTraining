import 'package:flutter/material.dart';
import 'utils/colors.dart';
import 'utils/helper.dart';

class Level extends StatefulWidget {
  const Level({super.key});

  static const String routeName = '/level';
  @override
  State<Level> createState() => _LevelState();
}

class _LevelState extends State<Level> {
  @override
  Widget build(BuildContext context) {
    final levelInfo =
        ModalRoute.of(context)!.settings.arguments as LevelInfo;
    String campaignTitle = levelInfo.CampaignName;
    String missionTitle = levelInfo.MissionName;
    String levelTitle = levelInfo.LevelName;

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
              TextRow("Mission name: " + missionTitle),
              verticalSpacer(),
              TextRow("Level name: " + levelTitle),
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
            },
            child: FittedBox(
              fit: BoxFit.fill,
              child: Text("Hands free practice", style: TextStyle(fontSize: 20)),
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
