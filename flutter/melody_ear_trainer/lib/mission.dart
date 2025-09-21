import 'package:flutter/material.dart';
import 'utils/colors.dart';
import 'utils/helper.dart';
import 'level.dart';
import 'providers/general_provider.dart';
import 'missionSettings.dart';

class Mission extends StatefulWidget {
  const Mission({super.key});

  static const String routeName = '/mission';
  @override
  State<Mission> createState() => _MissionState();
}

class _MissionState extends State<Mission> {
  @override
  Widget build(BuildContext context) {
    final missionInfo =
        ModalRoute.of(context)!.settings.arguments as MissionInfo;
    String campaignTitle = missionInfo.campaignName;
    String missionTitle = missionInfo.missionName;
    String mode = missionInfo.mode;
    missionSettingsProvider ms = missionSettingsProvider();

    missionInfo.setSettings(ms);

    final levels = missionInfo.levels;

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
              subHeadingRow(mode),
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
              Navigator.pushNamed(
                context,
                missionSettingsPage.routeName,
                arguments: missionInfo,
              );

            },
            child: FittedBox(
              fit: BoxFit.fill,
              child: Text("Settings", style: TextStyle(fontSize: 20)),
            ),
          ),
        ),
      ],
    ),
              // Levels table
              if (levels.isEmpty) ...[
                TextRow('No levels available'),
              ] else ...[
                // Constrain table height to avoid overflow
                SizedBox(
                  height: 240,
                  child: SingleChildScrollView(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Level')),
                          DataColumn(label: Text('Tests')),
                          DataColumn(label: Text('Passing')),
                        ],
                        rows:
                            levels.map((LevelInfo lvl) {
                              lvl.setSettings(ms);
                              return DataRow(
                                // make the row selectable/clickable
                                onSelectChanged: (selected) {
                                  if (selected == true) {
                                    Navigator.pushNamed(
                                      context,
                                      Level.routeName,
                                      arguments: lvl,
                                    );
                                  }
                                },
                                cells: [
                                  DataCell(Text(lvl.levelName)),
                                  DataCell(Text(lvl.numTests.toString())),
                                  DataCell(Text(lvl.passingScore.toString())),
                                ],
                              );
                            }).toList(),
                      ),
                    ),
                  ),
                ),
              ],
              verticalSpacer(),
            ],
          ),
        ),
      ),
    );
  }
}
