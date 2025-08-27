import 'package:flutter/material.dart';
import 'package:melody_ear_trainer/providers/general_provider.dart';
import 'package:melody_ear_trainer/providers/mapping_provider.dart';
import 'package:provider/provider.dart';
import 'audio/audio_controller.dart';
import 'utils/colors.dart';

class TonicPage extends StatefulWidget {
  const TonicPage({super.key, required this.audioController});
  final AudioController audioController;

  @override
  State<TonicPage> createState() => _TonicPageState();
}

class _TonicPageState extends State<TonicPage> {
  @override
  Widget build(BuildContext context) {
    // Get the nestedMapping from the provider (auto-updates on notifyListeners)
    final nestedMapping = context.watch<MappingProvider>().getNestedMapping;
    return Scaffold(
      appBar: AppBar(title: Text('Tonic')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Starting note "always start with" checkbox
              Row(
                children: [
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Starting note (tonic): Always start with'),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Checkbox(
                    value: context.watch<MelodyIDSettings>().startWithDo,
                    onChanged: (bool? value) {
                      context.read<MelodyIDSettings>().toggleStartWithDo();
                    },
                  ),
                  // Starting note dropdown
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Tonic Note:'),
                  ),
                  DropdownButton<String>(
                    value: context.watch<MelodyIDSettings>().startingDo,
                    items:
                        [
                          "do0",
                          "la0",
                          "do",
                          "la",
                          "do1",
                          "la1",
                          "do2",
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        context.read<MelodyIDSettings>().updateStartingDo(
                          newStartingDo: newValue,
                        );
                      }
                    },
                  ),
                ],
              ),
              SizedBox(height: 8),
              // Ending note "always start with" checkbox
              Row(
                children: [
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Ending note: Always end with'),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Checkbox(
                    value: context.watch<MelodyIDSettings>().endWithDo,
                    onChanged: (bool? value) {
                      context.read<MelodyIDSettings>().toggleEndWithDo();
                    },
                  ),
                  // Ending note dropdown
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Ending Note:'),
                  ),
                  DropdownButton<String>(
                    value: context.watch<MelodyIDSettings>().endingDo,
                    items:
                        [
                          "do0",
                          "la0",
                          "do",
                          "la",
                          "do1",
                          "la1",
                          "do2",
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        context.read<MelodyIDSettings>().updateEndingDo(
                          newEndingDo: newValue,
                        );
                      }
                    },
                  ),
                ],
              ),
              // Play Guitar Tonic Button
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: getChordButtonColor(
                          "blah_M_2i",
                        ),
                        foregroundColor: Colors.black,
                      ),
                      onPressed: () async {
                        String filename =
                            nestedMapping[context
                                .read<MelodyIDSettings>()
                                .selectedKey]!['Guitar']![context
                                .read<MelodyIDSettings>()
                                .startingDo] ??
                            '';
                        filename = "assets/audio/$filename";
                        if (filename.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('No tonic found')),
                          );
                          return;
                        }
                        await widget.audioController.refresh();
                        widget.audioController.playSound(filename);
                      },
                      child: FittedBox(
                        fit: BoxFit.fill,
                        child: Text('Play Guitar Tonic', style: TextStyle(fontSize: 20))),
                    ),
                  ),
                ],
              ),
              // Play Piano Tonic Button
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: getChordButtonColor(
                          "blah_M_All",
                        ),
                        foregroundColor: Colors.black,
                      ),
                      onPressed: () async {
                        String filename =
                            nestedMapping[context
                                .read<MelodyIDSettings>()
                                .selectedKey]!['Piano']![context
                                .read<MelodyIDSettings>()
                                .startingDo] ??
                            '';
                        filename = "assets/audio/$filename";
                        if (filename.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('No tonic found')),
                          );
                          return;
                        }
                        await widget.audioController.refresh();
                        widget.audioController.playSound(filename);
                      },
                      child: FittedBox(
                        fit: BoxFit.fill,
                        child: Text('Play Piano Tonic', style: TextStyle(fontSize: 20))),
                    ),
                  ),
                ],
              ),
              // Play Solfege Tonic Button
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                        backgroundColor: getChordButtonColor(
                          "blah_M_R",
                        ),
                        foregroundColor: Colors.black,
                      ),
                      onPressed: () async {
                        String filename =
                            nestedMapping[context
                                .read<MelodyIDSettings>()
                                .selectedKey]!['Solfege']![context
                                .read<MelodyIDSettings>()
                                .startingDo] ??
                            '';
                        filename = "assets/audio/$filename";
                        if (filename.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('No tonic found')),
                          );
                          return;
                        }
                        await widget.audioController.refresh();
                        widget.audioController.playSound(filename);
                      },
                      child: FittedBox(
                        fit: BoxFit.fill,
                        child: Text('Play Solfege Tonic', style: TextStyle(fontSize: 20))),
                    ),
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
