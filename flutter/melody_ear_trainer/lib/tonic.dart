import 'package:flutter/material.dart';
import 'package:melody_ear_trainer/providers/general_provider.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'audio/audio_controller.dart';

class TonicPage extends StatefulWidget {
  const TonicPage({super.key, required this.audioController});
  final AudioController audioController;

  @override
  State<TonicPage> createState() => _TonicPageState();
}

class _TonicPageState extends State<TonicPage> {
  // Replace mappingKeys/instruments with nested mapping
  Map<String, Map<String, Map<String, String>>> nestedMapping = {};

  @override
  void initState() {
    super.initState();
    loadMappingFiles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tonic')),
      body: Center(
        child: Column(
          children: [
            // Starting note "always start with" checkbox
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Starting note (tonic): Always start with'),
            ),
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
                  ["do0", "la0", "do", "la", "do1", "la1", "do2"].map<DropdownMenuItem<String>>((
                    String value,
                  ) {
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
            // Ending note "always start with" checkbox
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Ending note: Always start with'),
            ),
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
                  ["do0", "la0", "do", "la", "do1", "la1", "do2"].map<DropdownMenuItem<String>>((
                    String value,
                  ) {
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
            // Play Guitar Tonic Button
            Padding(
              padding: const EdgeInsets.all(8.0),
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
            // Play Piano Tonic Button
            Padding(
              padding: const EdgeInsets.all(8.0),
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
            // Play Solfege Tonic Button
            Padding(
              padding: const EdgeInsets.all(8.0),
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
          ], // Children of Column
        ),
      ),
    );
  }

  Future<void> loadMappingFiles() async {
    // Load Mapping.txt and populate nestedMapping
    String mappingData =
        await File('assets/mapping/Mapping.txt').readAsString();
    List<String> lines = mappingData.split('\n');
    for (String line in lines) {
      List<String> parts = line.split('\t');
      if (parts.length >= 4) {
        String key1 = parts[0];
        String key2 = parts[1];
        String key3 = parts[2];
        String value = parts[3];
        nestedMapping[key1] ??= {};
        nestedMapping[key1]![key2] ??= {};
        nestedMapping[key1]![key2]![key3] = value.trim();
      }
    }
    setState(() {});
  }
}
