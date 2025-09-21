import 'package:flutter/material.dart';
import 'utils/colors.dart';
import 'campaign.dart';
import 'utils/helper.dart';

class MelodyHomePage extends StatefulWidget {
  const MelodyHomePage({super.key});
  @override
  State<MelodyHomePage> createState() => _MelodyHomePageState();
}

class _MelodyHomePageState extends State<MelodyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(title: Text('Melody ear trainer')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            children: [
              // First row
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
                              "Campaign 1: Diatonic major",
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
                        Navigator.pushNamed(
                          context,
                          campaignTree.routeName,
                          arguments: CampaignArguments(
                            'Campaign 1: Diatonic major'
                            , 'diatonic_major.json'
                          ),
                        );
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
                        Navigator.pushNamed(context, '/frontpage',
                        );
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
