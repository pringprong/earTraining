import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:melody_ear_trainer/providers/general_provider.dart';
import 'package:melody_ear_trainer/providers/mapping_provider.dart';
import 'utils/colors.dart';

class ChordsPage extends StatefulWidget {
  const ChordsPage({super.key});
  @override
  State<ChordsPage> createState() => _ChordsPageState();
}

class _ChordsPageState extends State<ChordsPage> {
  @override
  Widget build(BuildContext context) {
    final generalProvider = Provider.of<MelodyIDSettings>(context);
    final chordsMapping = context.watch<MappingProvider>().getChordsMapping;
    final chordSetsMapping =
        context.watch<MappingProvider>().getChordSetsMapping;
    final rangesList = context.watch<MappingProvider>().getRangesList;
    final chordSetsList = context.watch<MappingProvider>().getChordSetsList;
    String? selectedRange =
        generalProvider.chordSetRange; // Default range selection
    String? selectedChordSet =
        generalProvider.chordSet; // Default set selection

    return Scaffold(
      appBar: AppBar(title: Text('Chord Selection')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Octave dropdown
              SizedBox(
                width: double.infinity,
                child: Wrap(
                  alignment: WrapAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Range:'),
                        ),
                        DropdownButton<String>(
                          value: context.watch<MelodyIDSettings>().chordSetRange,
                          hint: Text('Select Range'),
                          items:
                              rangesList
                                  .map(
                                    (range) => DropdownMenuItem(
                                      value: range,
                                      child: Text(range),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (range) {
                            setState(() {
                              selectedRange = range;
                              context.read<MelodyIDSettings>().updateChordRange(
                                newChordRange: selectedRange ?? '',
                              );
                              if (selectedRange != null &&
                                  selectedChordSet != null) {
                                final chords =
                                    chordSetsMapping[selectedRange!]?[selectedChordSet!] ??
                                    [];
                                context
                                    .read<MelodyIDSettings>()
                                    .setSelectedChords(chords);
                              }
                            });
                          },
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Set:'),
                        ),
                        DropdownButton<String>(
                          value: context.watch<MelodyIDSettings>().chordSet,
                          hint: Text('Select Set'),
                          items:
                              chordSetsList
                                  .map(
                                    (set) => DropdownMenuItem(
                                      value: set,
                                      child: Text(set),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (set) {
                            setState(() {
                              selectedChordSet = set;
                              context.read<MelodyIDSettings>().updateChordSet(
                                newChordSet: selectedChordSet ?? '',
                              );
                              if (selectedRange != null &&
                                  selectedChordSet != null) {
                                final chords =
                                    chordSetsMapping[selectedRange!]?[selectedChordSet!] ??
                                    [];
                                context
                                    .read<MelodyIDSettings>()
                                    .setSelectedChords(chords);
                              }
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Notes grid
              buildChordButtons(chordsMapping, generalProvider),
            ],
          ),
        ),
      ),
    );
  }

  // c. Draw dynamic chord buttons
  Widget buildChordButtons(
    Map<String, Map<String, Map<String, List<String>>>> chordsMapping,
    GeneralProvider generalProvider,
  ) {
    List<Widget> sections = [];
    chordsMapping.forEach((category, degreesMap) {
      // Section title
      sections.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            category,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
      );
      degreesMap.forEach((degree, chordSetMap) {
        // Row for each degree
        List<Widget> chordButtons = [];
        chordSetMap.forEach((chordName, notes) {
          final selected = generalProvider.selectedChords[chordName] == true;
          chordButtons.add(
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: Tooltip(
                message: notes.join(' '),
                child: GestureDetector(
                  onTap: () {
                    generalProvider.toggleSelectedChord(chordName);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color:
                          selected
                              ? getChordButtonColor(chordName)
                              : Colors.grey[400],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    child: FittedBox(
                      fit: BoxFit.fill,
                      child: Text(
                        chordName,
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight:
                              selected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        });
        sections.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.0),
            child: Wrap(spacing: 4, runSpacing: 4, children: chordButtons),
          ),
        );
      });
    });
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sections,
    );
  }
}
