import 'package:flutter/material.dart';
import '../../providers/general_provider.dart';
import '../../providers/mapping_provider.dart';
import 'package:provider/provider.dart';
import '../../utils/colors.dart';
import '../../utils/helper.dart';

class missionSettingsPage extends StatefulWidget {
  const missionSettingsPage({super.key});

  static const String routeName = '/missionSettings';
  @override
  State<missionSettingsPage> createState() => _missionSettingsPageState();
}

class _missionSettingsPageState extends State<missionSettingsPage> {
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
              verticalSpacer(),
              subHeadingRow("Playback settings:"),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Playback key:'),
                  ),
                  DropdownButton<String>(
                    hint: Text('Playback key'),
                    value: context.watch<missionSettingsProvider>().selectedKey,
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
                        context.read<missionSettingsProvider>().updateSelectedKey(
                          newkey: newValue,
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
                    child: Text('Playback instrument:'),
                  ),
                  DropdownButton<String>(
                    hint: Text('Playback instrument'),
                    value:
                        context
                            .watch<missionSettingsProvider>()
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
                            .read<missionSettingsProvider>()
                            .updateSelectedInstrument(instrument: newValue);
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
