import 'package:flutter/material.dart';
import 'package:melody_ear_trainer/main.dart';
import 'utils/colors.dart';
import 'campaign/campaign.dart';
import 'utils/helper.dart';
import 'package:provider/provider.dart';
import 'providers/mapping_provider.dart';

class MelodyHomePage extends StatefulWidget {
  const MelodyHomePage({super.key});
  @override
  State<MelodyHomePage> createState() => _MelodyHomePageState();
}

class _MelodyHomePageState extends State<MelodyHomePage> {
  @override
  Widget build(BuildContext context) {
    // obtain campaigns map from MappingProvider
    final mappingProvider = Provider.of<MappingProvider>(context);
    final Map<String, CampaignInfo> campaigns = mappingProvider.getCampaigns;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(title: Text('Melody ear trainer')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              children: [
                subHeadingRow("Campaigns"),
                verticalSpacer(),
                // generate one button per campaign entry
                if (campaigns.isEmpty) ...[
                  TextRow('No campaigns available'),
                ] else
                  ...campaigns.entries.expand((entry) sync* {
                    CampaignInfo campArgs = entry.value;
                    yield Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            child: Card(
                              color: getCampaignColor(campArgs.CampaignID),
                              child: SizedBox(
                                height: 50,
                                child: Center(
                                  child: Text(
                                    campArgs.CampaignName,
                                    style: TextStyle(
                                      fontSize: 20,
                                      color:
                                          colorMap["buttonForegroundColor"] ??
                                          Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                campaignTree.routeName,
                                arguments: campArgs,
                              );
                            },
                          ),
                        ),
                      ],
                    );
                    yield verticalSpacer();
                  }).toList(),
                subHeadingRow("Custom practice"),
                verticalSpacer(),
                plainText("Set all settings manually"),
                verticalSpacer(),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        child: Card(
                          color: colorMap["c5f4"],
                          child: SizedBox(
                            height: 50,
                            child: Center(
                              child: Text(
                                "Custom practice",
                                style: TextStyle(
                                  fontSize: 20,
                                  color:
                                      colorMap["buttonForegroundColor"] ??
                                      Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                        onTap: () {
                          Navigator.pushNamed(context, '/frontpage');
                        },
                      ),
                    ),
                  ],
                ),
                verticalSpacer(),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        child: Card(
                          color: colorMap["c1f4"] ?? Colors.white,
                          child: SizedBox(
                            height: 50,
                            child: Center(
                              child: Text(
                                "Help",
                                style: TextStyle(
                                  fontSize: 20,
                                  color:
                                      colorMap["buttonForegroundColor"] ??
                                      Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                        onTap: () {
                          Navigator.pushNamed(context, '/help');
                        },
                      ),
                    ),
                  ],
                ),
                plainText("Version " + versionNumber),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
