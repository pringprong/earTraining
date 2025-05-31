// import 'dart:developer' as dev;
// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:logging/logging.dart';
import 'audio/audio_controller.dart';
//import 'dart:convert';
import 'dart:io';

void main() async {
  // The `flutter_soloud` package logs everything
  // (from severe warnings to fine debug messages)
  // using the standard `package:logging`.
  // You can listen to the logs as shown below.

  // Logger.root.level = kDebugMode ? Level.FINE : Level.INFO;
  // Logger.root.onRecord.listen((record) {
  //   dev.log(
  //     record.message,
  //     time: record.time,
  //     level: record.level.value,
  //     name: record.loggerName,
  //     zone: record.zone,
  //     error: record.error,
  //     stackTrace: record.stackTrace,
  //   );
  // });

  WidgetsFlutterBinding.ensureInitialized();
  final audioController = AudioController();
  await audioController.initialize();
  runApp(MelodyEarTrainerApp(audioController: audioController));
}

class MelodyEarTrainerApp extends StatelessWidget {
  const MelodyEarTrainerApp({required this.audioController, super.key});
  final AudioController audioController;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Melody Ear Trainer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.brown),
        useMaterial3: true,
        primarySwatch: Colors.blue,
      ),
      home: MelodyHomePage(audioController: audioController),
        routes: {
          '/home': (context) => MelodyHomePage(audioController: audioController),
          '/general': (context) => GeneralPage(),
          // Add other routes here
  },
    );
  }
}

class GeneralPage extends StatefulWidget {
  const GeneralPage({super.key});

  @override
  State<GeneralPage> createState() => _GeneralPageState();
}

class _GeneralPageState extends State<GeneralPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('General Settings')),
      body: Center(
        child: Text('General settings will be implemented here.'),
      ),
    );
  }
}

class MelodyHomePage extends StatefulWidget {
  const MelodyHomePage({super.key, required this.audioController});
  final AudioController audioController;
  @override
  State<MelodyHomePage> createState() => _MelodyHomePageState();
}

class _MelodyHomePageState extends State<MelodyHomePage> {
  List<String> mappingKeys = [];
  List<String> instruments = [];
  String selectedKey = "";
  String selectedInstrument = "";
  int numberOfNotes = 5;
  bool allowRepeatedNotes = false;
  bool startWithDo = true;
  bool endWithDo = true;

  @override
  void initState() {
    super.initState();
    loadMappingFiles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Melody Ear Trainer')),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            ListTile(
              title: Text('Melody'),
              onTap: () {
                // Update the state of the app
                // Then close the drawer
                Navigator.pop(context);
                Navigator.pushNamed(context, '/home');
              },
            ),            ListTile(
              title: Text('General'),
              onTap: () {
                // Update the state of the app
                // Then close the drawer
                Navigator.pop(context);
                Navigator.pushNamed(context, '/general');
              },
            ),
            ListTile(
              title: Text('Tonic'),
              onTap: () {
                // Update the state of the app
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Scales'),
              onTap: () {
                // Update the state of the app
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Chords'),
              onTap: () {
                // Update the state of the app
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Chord Sets'),
              onTap: () {
                // Update the state of the app
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<String>(
              hint: Text('Select Key'),
              value: selectedKey,
              onChanged: (String? newValue) {
                if (newValue is String) {
                  setState(() {
                    selectedKey = newValue;
                  });
                }
              },
              items:
                  mappingKeys.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
            ),
            DropdownButton<String>(
              hint: Text('Select Instrument'),
              value: selectedInstrument,
              onChanged: (String? newValue) {
                if (newValue is String) {
                  setState(() {
                    selectedInstrument = newValue;
                  });
                }
              },
              items:
                  instruments.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
            ),
            ElevatedButton(
              onPressed: () {
                // Logic to generate melody and play
                widget.audioController.playSound('assets/audio/C4.mp3');
              },
              child: Text('Play Melody'),
            ),
            // Additional UI elements for notes and chords can be added here
          ],
        ),
      ),
    );
  }

  Future<void> loadMappingFiles() async {
    // Load Mapping.txt and populate mappingKeys and instruments
    String mappingData = await File('mapping/Mapping.txt').readAsString();
    List<String> lines = mappingData.split('\n');
    for (String line in lines) {
      List<String> parts = line.split('\t');
      if (parts.isNotEmpty && !mappingKeys.contains(parts[0])) {
        mappingKeys.add(parts[0]);
      }
      if (parts.length > 1 && !instruments.contains(parts[1])) {
        instruments.add(parts[1]);
      }
    }
    setState(() {});
  }
}
