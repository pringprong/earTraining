import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/helper.dart';
import 'level.dart';
import '../providers/mapping_provider.dart';
import 'missionSettings.dart';
import 'package:provider/provider.dart';

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
    final mappingProvider = Provider.of<MappingProvider>(context);
    String campaignTitle = mappingProvider.getCampaignName(
      missionInfo.CampaignID,
    );
    String missionTitle = missionInfo.MissionName;
    String mode = missionInfo.MissionMode;
    final levels = mappingProvider.getLevelsForMission(missionInfo.MissionID);

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
              subHeadingRow("Mode: " + mode),
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
                                  DataCell(Text(lvl.LevelName)),
                                  DataCell(Text(lvl.NumTests.toString())),
                                  DataCell(Text(lvl.PassingScore.toString())),
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
