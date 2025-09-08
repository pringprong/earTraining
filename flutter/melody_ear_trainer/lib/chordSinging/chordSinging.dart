import 'package:flutter/material.dart';
import '../providers/general_provider.dart';
import '../providers/mapping_provider.dart';
import 'package:provider/provider.dart';
import '../utils/colors.dart';
import '../melodyPageAbstract.dart';

class chordSinging extends MelodyPageAbstract {
  const chordSinging({super.key, required super.audioController}) : super();
  @override
  chordSingingState createState() => chordSingingState();
}

class chordSingingState extends MelodyPageAbstractState {
  @override
  Widget build(BuildContext context) {
    final mappingProvider = Provider.of<MappingProvider>(context);
    final generalProvider = Provider.of<chordSingingSettings>(context);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(title: Text('Chord singing')),
      drawer: SafeArea(
        child: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              ListTile(
                title: Text('Settings'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/chordSingingSettings');
                },
              ),
              ListTile(
                title: Text('Hands-free chord singing'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/chordSinginghandsfree');
                },
              ),
              ListTile(
                title: Text('Home'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              generateMelodyButton(generalProvider, mappingProvider, true),
              verticalSpacer(),
              subHeadingRow("Generated melody:"),
              verticalSpacer(),
              solfegeTextArea(),
              verticalSpacer(),
              sayTheSolfegeButton(generalProvider, mappingProvider),
              verticalSpacer(),
              subHeadingRow("Listen to first note:"),
              verticalSpacer(),
              playFirstNoteButtons(generalProvider, mappingProvider),
              verticalSpacer(),
              instructionRow("Now try to sing the melody out loud..."),
              verticalSpacer(),
              subHeadingRow("Listen to the melody for comparison:"),
              verticalSpacer(),
              playMelodyButtons(generalProvider, mappingProvider, true),
              verticalSpacer(),
              instructionRow("Did you sing it correctly?"),
              verticalSpacer(),
              subHeadingRow("Chords for reference"),
              verticalSpacer(),
              plainText("Long press to see the solfege"),
              verticalSpacer(),
              plainText("Note: Make sure all of these are in your range..."),
              verticalSpacer(),
              plainText("Long press to see the solfege"),
              verticalSpacer(),
              buildSelectedChordButtons(generalProvider, mappingProvider),
            ],
          ),
        ),
      ),
    );
  }
}
