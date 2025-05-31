import 'dart:developer' as dev;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'audio/audio_controller.dart';

void main() async {
  // The `flutter_soloud` package logs everything
  // (from severe warnings to fine debug messages)
  // using the standard `package:logging`.
  // You can listen to the logs as shown below.
  Logger.root.level = kDebugMode ? Level.FINE : Level.INFO;
  Logger.root.onRecord.listen((record) {
    dev.log(
      record.message,
      time: record.time,
      level: record.level.value,
      name: record.loggerName,
      zone: record.zone,
      error: record.error,
      stackTrace: record.stackTrace,
    );
  });

  WidgetsFlutterBinding.ensureInitialized();
  final audioController = AudioController();
  await audioController.initialize();
  runApp(MelodyEarTrainerApp (audioController: audioController));
}

class MelodyEarTrainerApp  extends StatelessWidget {
  const MelodyEarTrainerApp ({required this.audioController, super.key});
  final AudioController audioController;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Melody Ear Trainer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.brown),
        useMaterial3: true,
      ),
      home: MelodyHomePage(audioController: audioController),
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
  static const _gap = SizedBox(height: 16);
  bool filterApplied = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter SoLoud Demo')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            OutlinedButton(
              onPressed: () {
                widget.audioController.playSound('assets/audio/C4.mp3');
                Future.delayed(Duration(milliseconds: 800), () {
                  widget.audioController.playSound('assets/audio/E4.mp3');
                  Future.delayed(Duration(milliseconds: 800), () {
                    widget.audioController.playSound('assets/audio/G4.mp3');
                });
               });
              },
              child: const Text('Play Sound'),
            ),
            _gap,
            OutlinedButton(
              onPressed: () {
                widget.audioController.startMusic();
              },
              child: const Text('Start Music'),
            ),
            _gap,
            OutlinedButton(
              onPressed: () {
                widget.audioController.fadeOutMusic();
              },
              child: const Text('Fade Out Music'),
            ),
            _gap,
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Apply Filter'),
                Checkbox(
                  value: filterApplied,
                  onChanged: (value) {
                    setState(() {
                      filterApplied = value!;
                    });
                    if (filterApplied) {
                      widget.audioController.applyFilter();
                    } else {
                      widget.audioController.removeFilter();
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}