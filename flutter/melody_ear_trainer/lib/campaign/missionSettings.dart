import 'package:flutter/material.dart';
import 'package:melody_ear_trainer/main.dart';
import '../../providers/general_provider.dart';
import '../../providers/mapping_provider.dart';
import 'package:provider/provider.dart';
import '../../utils/helper.dart';

class MissionSettingsPage extends StatefulWidget {
  const MissionSettingsPage({super.key});

  static const String routeName = '/missionSettings';
  @override
  State<MissionSettingsPage> createState() => _MissionSettingsPageState();
}

class _MissionSettingsPageState extends State<MissionSettingsPage> {
  @override
  Widget build(BuildContext context) {
    final missionInfo =
        ModalRoute.of(context)!.settings.arguments as MissionInfo;
    final mappingProvider = Provider.of<MappingProvider>(context);
    final String missionName = missionInfo.MissionName;

    return Scaffold(
      appBar: AppBar(title: Text(missionName + ' settings')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              CampaignHeaderRow(campaignId: missionInfo.CampaignID),
                verticalSpacer(),
                MissionHeaderRow(missionId: missionInfo.MissionID, max:true),
              verticalSpacer(),
              subHeadingRow("Playback settings:"),
              verticalSpacer(),
              plainText("These settings will be used for all levels in this mission"),
              verticalSpacer(),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Key:'),
                  ),
                  DropdownButton<String>(
                    hint: Text('Playback key'),
                    value: context.watch<MissionSettingsProvider>().selectedKey,
                    items:
                        mappingProvider.getMappingKeys
                            .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            })
                            .toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        context
                            .read<MissionSettingsProvider>()
                            .updateSelectedKey(newkey: newValue);
                        objectBox.updateKey(
                          missionInfo.MissionID,
                          newValue,
                          );
                      }
                    },
                  ),
                ],
              ),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Instrument:'),
                  ),
                  DropdownButton<String>(
                    hint: Text('Playback instrument'),
                    value:
                        context
                            .watch<MissionSettingsProvider>()
                            .selectedInstrument,
                    items:
                        mappingProvider.getInstruments
                            .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            })
                            .toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        context
                            .read<MissionSettingsProvider>()
                            .updateSelectedInstrument(instrument: newValue);
                        objectBox.updateInstrument(
                          missionInfo.MissionID, 
                          newValue);
                      }
                    },
                  ),
                ],
              ),
            ], // Children of Column
          ),
        ),
      ),
    );
  }
}
