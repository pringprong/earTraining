import 'package:flutter/material.dart';
import 'package:melody_ear_trainer/providers/general_provider.dart';
import 'package:provider/provider.dart';
import 'audio/audio_controller.dart';

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
    final nestedMapping = context.watch<GeneralProvider>().getNestedMapping;
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
                    value: context.watch<GeneralProvider>().startWithDo,
                    onChanged: (bool? value) {
                      context.read<GeneralProvider>().toggleStartWithDo();
                    },
                  ),
                  // Starting note dropdown
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Tonic Note:'),
                  ),
                  DropdownButton<String>(
                    value: context.watch<GeneralProvider>().startingDo,
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
                        context.read<GeneralProvider>().updateStartingDo(
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
                    value: context.watch<GeneralProvider>().endWithDo,
                    onChanged: (bool? value) {
                      context.read<GeneralProvider>().toggleEndWithDo();
                    },
                  ),
                  // Ending note dropdown
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Ending Note:'),
                  ),
                  DropdownButton<String>(
                    value: context.watch<GeneralProvider>().endingDo,
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
                        context.read<GeneralProvider>().updateEndingDo(
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
                      onPressed: () {
                        String filename =
                            nestedMapping[context
                                .read<GeneralProvider>()
                                .selectedKey]!['Guitar']![context
                                .read<GeneralProvider>()
                                .startingDo] ??
                            '';
                        filename = "assets/audio/$filename";
                        if (filename.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('No tonic found')),
                          );
                          return;
                        }
                        widget.audioController.playSound(filename);
                      },
                      child: Text('Play Guitar Tonic'),
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
                      onPressed: () {
                        String filename =
                            nestedMapping[context
                                .read<GeneralProvider>()
                                .selectedKey]!['Piano']![context
                                .read<GeneralProvider>()
                                .startingDo] ??
                            '';
                        filename = "assets/audio/$filename";
                        if (filename.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('No tonic found')),
                          );
                          return;
                        }
                        widget.audioController.playSound(filename);
                      },
                      child: Text('Play Piano Tonic'),
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
                      onPressed: () {
                        String filename =
                            nestedMapping[context
                                .read<GeneralProvider>()
                                .selectedKey]!['Solfege']![context
                                .read<GeneralProvider>()
                                .startingDo] ??
                            '';
                        filename = "assets/audio/$filename";
                        if (filename.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('No tonic found')),
                          );
                          return;
                        }
                        widget.audioController.playSound(filename);
                      },
                      child: Text('Play Solfege Tonic'),
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
