import 'package:flutter/material.dart';
import 'utils/colors.dart';
import 'campaign.dart';
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
    final Map<String, CampaignArguments> campaigns =
        mappingProvider.getCampaigns;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(title: Text('Melody ear trainer')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            children: [
              // generate one button per campaign entry
              if (campaigns.isEmpty) ...[
                TextRow('No campaigns available'),
              ] else
                ...campaigns.entries.expand((entry) sync* {
                  CampaignArguments campArgs = entry.value;
                  yield Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          child: Card(
                            color: c5f4,
                            child: SizedBox(
                              height: 100,
                              child: Center(
                                child: Text(
                                  campArgs.CampaignName,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    color: buttonForegroundColor,
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
                              arguments: campArgs
                              );
                          },
                        ),
                      ),
                    ],
                  );
                  yield verticalSpacer();
                }).toList(),
              verticalSpacer(),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      child: Card(
                        color: c5f4,
                        child: SizedBox(
                          height: 100,
                          child: Center(
                            child: const Text(
                              "Custom study",
                              style: TextStyle(
                                fontSize: 20,
                                color: buttonForegroundColor,
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
                        color: c1f4,
                        child: SizedBox(
                          height: 100,
                          child: Center(
                            child: const Text(
                              "Help",
                              style: TextStyle(
                                fontSize: 20,
                                color: buttonForegroundColor,
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
            ],
          ),
        ),
      ),
    );
  }
}
