import 'package:flutter/material.dart';
import '../providers/general_provider.dart';
import '../providers/mapping_provider.dart';
import 'package:provider/provider.dart';
import '../utils/helper.dart';
import '../melodyPageAbstract.dart';

class MelodyID extends MelodyPageAbstract {
  const MelodyID({super.key, required super.audioController}) : super();
  @override
  MelodyIDState createState() => MelodyIDState();
}

class MelodyIDState extends MelodyPageAbstractState {
  @override
  Widget build(BuildContext context) {
    final mappingProvider = Provider.of<MappingProvider>(context);
    final generalProvider = Provider.of<MelodyIDSettings>(context);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(title: Text('Melody ID')),
      drawer: SafeArea(
        child: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              ListTile(
                title: Text('Settings'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/melodyIDsettings');
                },
              ),
              ListTile(
                title: Text('Hands-free melody ID'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/melodyIDhandsfree');
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
              buildNoteButtons(generalProvider, mappingProvider),
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
