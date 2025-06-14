import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:melody_ear_trainer/providers/general_provider.dart';

class ChordsPage extends StatefulWidget {
  const ChordsPage({super.key});
  @override
  State<ChordsPage> createState() => _ChordsPageState();
}

class _ChordsPageState extends State<ChordsPage> {
  @override
  Widget build(BuildContext context) {
    final generalProvider = Provider.of<GeneralProvider>(context);
    final chordsMapping = context.watch<GeneralProvider>().getChordsMapping;
    final chordSetsMapping =
        context.watch<GeneralProvider>().getChordSetsMapping;
    final rangesList = context.watch<GeneralProvider>().getRangesList;
    final chordSetsList = context.watch<GeneralProvider>().getChordSetsList;
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
                          value: context.watch<GeneralProvider>().chordSetRange,
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
                              context.read<GeneralProvider>().updateChordRange(
                                newChordRange: selectedRange ?? '',
                              );
                              if (selectedRange != null &&
                                  selectedChordSet != null) {
                                final chords =
                                    chordSetsMapping[selectedRange!]?[selectedChordSet!] ??
                                    [];
                                context
                                    .read<GeneralProvider>()
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
                          value: context.watch<GeneralProvider>().chordSet,
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
                              context.read<GeneralProvider>().updateChordSet(
                                newChordSet: selectedChordSet ?? '',
                              );
                              if (selectedRange != null &&
                                  selectedChordSet != null) {
                                final chords =
                                    chordSetsMapping[selectedRange!]?[selectedChordSet!] ??
                                    [];
                                context
                                    .read<GeneralProvider>()
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
              //Expanded(child: _buildNotesGrid(generalProvider)),
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
                              ? GeneralProvider.getChordButtonColor(chordName)
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
