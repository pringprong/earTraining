// import 'dart:developer' as dev;
// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
//import 'package:melody_ear_trainer/theme/theme.dart';
import 'package:provider/provider.dart';

// import 'package:logging/logging.dart';
//import 'dart:convert';
import 'audio/audio_controller.dart';
import 'general.dart';
import 'tonic.dart';
import 'providers/general_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/mapping_provider.dart';
import 'homepage.dart';
import 'scales.dart';
import 'chords.dart';
import 'handsfree.dart';
import 'singing.dart';
import 'handsfreesinging.dart';
//import 'package:flutter_screenutil/flutter_screenutil.dart';

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
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>(
          create: (context) {
            final themeProvider = ThemeProvider();
            return themeProvider;
          },
        ),
        ChangeNotifierProvider<MappingProvider>(
          create: (context) {
            final mappingProvider = MappingProvider();
            return mappingProvider;
          },
        ),
        ChangeNotifierProvider<MelodyIDSettings>(
          create: (context) {
            final melodyIDSettingsProvider =
                MelodyIDSettings();
            return melodyIDSettingsProvider;
          },
        ),
        ChangeNotifierProvider<MelodySingingSettings>(
          create: (context) {
            final melodySingingSettingsProvider =
                MelodySingingSettings();
            return melodySingingSettingsProvider;
          },
        ),
      ],
      child: MelodyEarTrainerApp(audioController: audioController),
    ),
  );
}

class MelodyEarTrainerApp extends StatelessWidget {
  const MelodyEarTrainerApp({required this.audioController, super.key});
  final AudioController audioController;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Melody Ear Trainer',
      //theme: ThemeData.dark(),
      theme: context.watch<ThemeProvider>().getThemeData,
      home: MelodyHomePage(audioController: audioController),
      routes: {
        '/home': (context) => MelodyHomePage(audioController: audioController),
        '/general': (context) => GeneralPage(),
        '/tonic': (context) => TonicPage(audioController: audioController),
        '/scales': (context) => ScalesPage(),
        '/chords': (context) => ChordsPage(),
        '/handsfree': (context) => HandsFree(audioController: audioController),
        '/singing': (context) => Singing(audioController: audioController),
        '/handsfreesinging':
            (context) => HandsFreeSinging(audioController: audioController),
        // Add other routes here
      },
    );
    //   );
  } // Build method
} // MelodyEarTrainerApp
