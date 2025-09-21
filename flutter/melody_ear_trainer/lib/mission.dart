import 'package:flutter/material.dart';
import 'utils/colors.dart';
import 'utils/helper.dart';

class Mission extends StatefulWidget {
  const Mission({super.key});

  static const String routeName = '/mission';
  @override
  State<Mission> createState() => _MissionState();
}

class _MissionState extends State<Mission> {


  @override
  Widget build(BuildContext context) {
        final args =
        ModalRoute.of(context)!.settings.arguments as MissionInfo;
    String campaignTitle = args.campaignName;
    String missionTitle = args.missionName;
    String missionInfo = args.mode;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(title: Text('Melody ear trainer')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            children: [
                  headingRow( campaignTitle),
                  verticalSpacer(),
                  TextRow( missionTitle),
                  verticalSpacer(),
                  subHeadingRow( missionInfo),
                  verticalSpacer(),
            ],
          ),
        ),
      ),
    );
  }
}
