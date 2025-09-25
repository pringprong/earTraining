import 'package:flutter/material.dart';
import '../../providers/general_provider.dart';
import 'package:provider/provider.dart';
import '../utils/colors.dart';
import '../utils/helper.dart';
import 'levelMelodyID.dart';
import 'levelMelodyIDhandsfree.dart';
import 'levelMelodyIDtest.dart';
import '../utils/resultsDB.dart';

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
              TextRow("Level main page"),
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
              verticalSpacer(),

              // Test history section: show saved test results for this level
              subHeadingRow("Test history"),
              verticalSpacer(),
              FutureBuilder<List<TestResult>>(
                future: TestResultsDB.instance.getResultsForLevel(
                  levelInfo.LevelID,
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return plainText("Loading history...");
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return plainText("No test results yet for this level.");
                  }
                  final rows = snapshot.data!;
                  return SizedBox(
                    height: 160, // fixed height so page scroll stays stable
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: rows.length,
                      separatorBuilder: (_, __) => Divider(),
                      itemBuilder: (context, index) {
                        final r = rows[index];
                        // format timestamp to a friendly display
                        String when;
                        try {
                          when =
                              DateTime.parse(r.timestamp).toLocal().toString();
                        } catch (_) {
                          when = r.timestamp;
                        }
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                when,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text("${r.score} / ${r.numQuestions}"),
                          ],
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
