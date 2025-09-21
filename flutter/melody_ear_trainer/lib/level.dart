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
    String campaignTitle = levelInfo.campaignName;
    String missionTitle = levelInfo.missionName;
    String levelTitle = levelInfo.levelName;

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
              TextRow(missionTitle),
              verticalSpacer(),
              TextRow(levelTitle),
              verticalSpacer(),
            ],
          ),
        ),
      ),
    );
  }
}
