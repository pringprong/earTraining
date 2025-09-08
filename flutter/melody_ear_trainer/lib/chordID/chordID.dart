import 'package:flutter/material.dart';
import '../providers/general_provider.dart';
import '../providers/mapping_provider.dart';
import 'package:provider/provider.dart';
import '../utils/colors.dart';
import '../melodyPageAbstract.dart';

class chordID extends MelodyPageAbstract {
  const chordID({super.key, required super.audioController}) : super();
  @override
  chordIDState createState() => chordIDState();
}

class chordIDState extends MelodyPageAbstractState {
  @override
  Widget build(BuildContext context) {
    final mappingProvider = Provider.of<MappingProvider>(context);
    final generalProvider = Provider.of<chordIDSettings>(context);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(title: Text('Chord ID')),
      drawer: SafeArea(
        child: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              ListTile(
                title: Text('Settings'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/chordIDsettings');
                },
              ),
              ListTile(
                title: Text('Hands-free chord ID'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/chordIDhandsfree');
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
              generateMelodyButton(generalProvider, mappingProvider, false),
              verticalSpacer(),
              subHeadingRow("Listen to generated melody:"),
              verticalSpacer(),
              playMelodyButtons(generalProvider, mappingProvider, false),
              verticalSpacer(),
              solfegeExpansionTile(generalProvider, mappingProvider),
              verticalSpacer(),
              subHeadingRow("Play the melody back:"),
              verticalSpacer(),
              plainText("Long press to see the solfege"),
              verticalSpacer(),
              buildSelectedChordButtons(generalProvider, mappingProvider),
              verticalSpacer(),
              userWrittenSolfegeArea(),
              verticalSpacer(),
              clearAndBackspaceButtons(),
              verticalSpacer(),
              compareButton(),
              verticalSpacer(),
              subHeadingRow("Listen to your melody:"),
              verticalSpacer(),
              userWrittenMelodyButtons(generalProvider, mappingProvider),
            ],
          ),
        ),
      ),
    );
  }
}
