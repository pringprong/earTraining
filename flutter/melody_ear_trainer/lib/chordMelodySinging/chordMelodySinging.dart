import 'package:flutter/material.dart';
import '../providers/general_provider.dart';
import '../providers/mapping_provider.dart';
import 'package:provider/provider.dart';
import '../utils/colors.dart';
import '../melodyPageAbstract.dart';

class chordMelodySinging extends MelodyPageAbstract {
  const chordMelodySinging({super.key, required super.audioController}) : super();
  @override
  chordMelodySingingState createState() => chordMelodySingingState();
}

class chordMelodySingingState extends MelodyPageAbstractState {
  @override
  Widget build(BuildContext context) {
    final mappingProvider = Provider.of<MappingProvider>(context);
    final generalProvider = Provider.of<chordMelodySingingSettings>(context);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(title: Text('Chord melody singing')),
      drawer: SafeArea(
        child: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              ListTile(
                title: Text('Settings'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/chordMelodySingingSettings');
                },
              ),
              ListTile(
                title: Text('Hands-free chord melody singing'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/chordMelodySingingHandsfree');
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
              TextRow("Generated melody:"),
              verticalSpacer(),
              solfegeTextArea(),
              verticalSpacer(),
              sayTheSolfegeButton(generalProvider, mappingProvider),
              verticalSpacer(),
              TextRow("Listen to first note:"),
              verticalSpacer(),
              playFirstNoteButtons(generalProvider, mappingProvider),
              verticalSpacer(),
              bigTextRow("Now try to sing the melody out loud..."),
              verticalSpacer(),
              TextRow("Listen to the melody for comparison:"),
              verticalSpacer(),
              playMelodyButtons(generalProvider, mappingProvider, true),
              verticalSpacer(),
              bigTextRow("Did you sing it correctly?"),
              verticalSpacer(),
              TextRow("Notes for reference"),
              verticalSpacer(),
              TextRow("Make sure all of these are in your range..."),
              verticalSpacer(),
              buildNoteButtons(generalProvider, mappingProvider),
              verticalSpacer(),
              buildSelectedChordButtons(generalProvider, mappingProvider,),
            ],
          ),
        ),
      ),
    );
  }
}
