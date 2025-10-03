import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'audio/audio_controller.dart';
import 'help.dart';
import 'providers/general_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/mapping_provider.dart';
import 'custom.dart';
import 'melodyID/melodyID.dart';
import 'melodyID/melodyIDsettings.dart';
import 'melodyID/melodyIDhandsfree.dart';
import 'melodySinging/melodySinging.dart';
import 'melodySinging/melodySingingHandsfree.dart';
import 'melodySinging/melodySingingSettings.dart';
import 'chordID/chordID.dart';
import 'chordID/chordIDsettings.dart';
import 'chordID/chordIDhandsfree.dart';
import 'chordSinging/chordSinging.dart';
import 'chordSinging/chordSingingsettings.dart';
import 'chordSinging/chordSinginghandsfree.dart';
import 'chordMelodyID/chordMelody.dart';
import 'chordMelodyID/chordMelodyIDsettings.dart';
import 'chordMelodyID/chordMelodyIDhandsfree.dart';
import 'chordMelodySinging/chordMelodySinging.dart';
import 'chordMelodySinging/chordMelodySingingHandsfree.dart';
import 'chordMelodySinging/chordMelodySingingSettings.dart';
import 'campaign/campaign.dart';
import 'homepage.dart';
import 'campaign/mission.dart';
import 'campaign/level.dart';
import 'campaign/missionSettings.dart';
import 'campaign/levelMelodyID.dart';
import 'campaign/levelMelodyIDhandsfree.dart';
import 'campaign/levelMelodyIDtest.dart';
import 'campaign/levelTestResults.dart';
import 'utils/objectBox.dart';
import 'campaign/levelMelodySinging.dart';

late ObjectBox objectBox;
final String versionNumber = "3.0";

Future main() async {
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
  objectBox = await ObjectBox.init();
  // Initialize FFI
  //sqfliteFfiInit();
  //databaseFactory = databaseFactoryFfi;
  //final database = openDatabase(join(await getDatabasesPath(),'test_results.db'));
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
            final melodyIDSettingsProvider = MelodyIDSettings();
            return melodyIDSettingsProvider;
          },
        ),
        ChangeNotifierProvider<MelodySingingSettings>(
          create: (context) {
            final melodySingingSettingsProvider = MelodySingingSettings();
            return melodySingingSettingsProvider;
          },
        ),
        ChangeNotifierProvider<chordIDSettings>(
          create: (context) {
            final chordIDSettingsProvider = chordIDSettings();
            return chordIDSettingsProvider;
          },
        ),
        ChangeNotifierProvider<chordSingingSettings>(
          create: (context) {
            final chordSingingSettingsProvider = chordSingingSettings();
            return chordSingingSettingsProvider;
          },
        ),
        ChangeNotifierProvider<chordMelodyIDSettings>(
          create: (context) {
            final chordMelodyIDSettingsProvider = chordMelodyIDSettings();
            return chordMelodyIDSettingsProvider;
          },
        ),
        ChangeNotifierProvider<chordMelodySingingSettings>(
          create: (context) {
            final chordMelodySingingSettingsProvider =
                chordMelodySingingSettings();
            return chordMelodySingingSettingsProvider;
          },
        ),
        ChangeNotifierProvider<missionSettingsProvider>(
          create: (context) {
            final msp = missionSettingsProvider();
            return msp;
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
      home: MelodyHomePage(),
      routes: {
        '/home': (context) => MelodyHomePage(),
        '/help': (context) => HelpPage(),
        '/frontpage': (context) => CustomFrontPage(),
        '/melodyID': (context) => MelodyID(audioController: audioController),
        '/melodyIDsettings':
            (context) => MelodyIDSettingsPage(audioController: audioController),
        '/melodyIDhandsfree':
            (context) => MelodyIDHandsFree(audioController: audioController),
        '/melodySinging':
            (context) => MelodySinging(audioController: audioController),
        '/melodySingingSettings':
            (context) =>
                MelodySingingSettingsPage(audioController: audioController),
        '/melodySingingHandsfree':
            (context) =>
                MelodySingingHandsFree(audioController: audioController),
        '/chordID': (context) => chordID(audioController: audioController),
        '/chordIDsettings':
            (context) => chordIDSettingsPage(audioController: audioController),
        '/chordIDhandsfree':
            (context) => chordIDHandsFree(audioController: audioController),
        '/chordSinging':
            (context) => chordSinging(audioController: audioController),
        '/chordSingingSettings':
            (context) =>
                chordSingingSettingsPage(audioController: audioController),
        '/chordSinginghandsfree':
            (context) =>
                chordSingingHandsFree(audioController: audioController),
        '/chordMelodyID':
            (context) => chordMelodyID(audioController: audioController),
        '/chordMelodyIDsettings':
            (context) =>
                chordMelodyIDSettingsPage(audioController: audioController),
        '/chordMelodyIDhandsfree':
            (context) =>
                chordMelodyIDHandsFree(audioController: audioController),
        '/chordMelodySinging':
            (context) => chordMelodySinging(audioController: audioController),
        '/chordMelodySingingSettings':
            (context) => chordMelodySingingSettingsPage(
              audioController: audioController,
            ),
        '/chordMelodySingingHandsfree':
            (context) =>
                chordMelodySingingHandsFree(audioController: audioController),
        campaignTree.routeName: (context) => campaignTree(),
        Mission.routeName: (context) => Mission(),
        Level.routeName: (context) => Level(),
        LevelTestResultsPage.routeName: (context) => LevelTestResultsPage(),
        missionSettingsPage.routeName: (context) => missionSettingsPage(),
        LevelMelodyID.routeName:
            (context) => LevelMelodyID(audioController: audioController),
        LevelMelodyIDHandsFree.routeName:
            (context) =>
                LevelMelodyIDHandsFree(audioController: audioController),
        LevelMelodyIDTest.routeName:
            (context) => LevelMelodyIDTest(audioController: audioController),
        LevelMelodySinging.routeName:
            (context) => LevelMelodySinging(audioController: audioController),

        // Add other routes here
      },
    );
    //   );
  } // Build method
} // MelodyEarTrainerApp
