import 'package:flutter/material.dart';
//import 'package:provider/provider.dart';

class GeneralProvider extends ChangeNotifier {
  // Define your provider variables here
  String selectedKey = "C";
  int numberOfNotes = 5;
  int maxDistance = 7; // Maximum distance between notes
  bool allowRepeatedNotes = false;
  String selectedInstrument = "";

  int timeBetweenNotes = 900; // Time in milliseconds between notes
  String truncateNotes = "1200"; // Truncate notes to 1200 milliseconds

  bool startWithDo = true;
  bool endWithDo = true;
  String startingDo = "do"; // Default starting note
  String endingDo = "do"; // Default ending note

  String selectedOctave = "Middle octave"; // Default octave selection
  String selectedScale = "Diatonic major"; // Default scale selection

  String chordFrequency = "Every 4 notes"; // Default chord frequency
  bool displayChordNames = true; // Default display chord notes setting
  int arpeggiateChordDelay = 0; // Default chord arpeggiation speed
  String arpeggiateChordOrder = "Ascending"; // Default arpeggiate chord order

  String chordSetRange = "Middle"; // Default chord set range
  String chordSet = "I_IV_V"; // Default chord set

  static const List<String> defaultNoteKeys = [
    "do0",
    "re0",
    "mi0",
    "fa0",
    "so0",
    "la0",
    "ti0",
    "do",
    "re",
    "mi",
    "fa",
    "so",
    "la",
    "ti",
    "do1",
  ];

  // Map of booleans for note selection
  static const List<String> noteKeys = [
    "do0",
    "ga0",
    "re0",
    "nu0",
    "mi0",
    "fa0",
    "jur0",
    "so0",
    "ki0",
    "la0",
    "pe0",
    "ti0",
    "do",
    "ga",
    "re",
    "nu",
    "mi",
    "fa",
    "jur",
    "so",
    "ki",
    "la",
    "pe",
    "ti",
    "do1",
    "ga1",
    "re1",
    "nu1",
    "mi1",
    "fa1",
    "jur1",
    "so1",
    "ki1",
    "la1",
    "pe1",
    "ti1",
    "do2",
  ];

  Map<String, bool> noteSelection = {
    for (var key in noteKeys) key: false,
    for (var key in defaultNoteKeys) key: true,
  };

  // --- Selected Chords Map ---
  Map<String, bool> selectedChords = {
    for (var key in "I_M_R,IV_M_R,V_M_R".split(','))
      key: true, // Initialize all chords as not selected
  };

  GeneralProvider({
    this.selectedKey = "C",
    this.selectedInstrument =
        "Piano", // Initialize any default values or load settings if necessary
  });

  get tonicNote => null;

  // Add methods to update the state
  void updateSelectedKey({required String newkey}) async {
    selectedKey = newkey;
    notifyListeners();
  }

  void updateSelectedInstrument({required String instrument}) async {
    selectedInstrument = instrument;
    notifyListeners();
  }

  void updateNumberOfNotes({required int count}) async {
    numberOfNotes = count;
    notifyListeners();
  }

  void toggleAllowRepeatedNotes() {
    allowRepeatedNotes = !allowRepeatedNotes;
    notifyListeners();
  }

  void toggleStartWithDo() {
    startWithDo = !startWithDo;
    notifyListeners();
  }

  void toggleEndWithDo() {
    endWithDo = !endWithDo;
    notifyListeners();
  }

  void updateStartingDo({required String newStartingDo}) async {
    startingDo = newStartingDo;
    notifyListeners();
  }

  void updateEndingDo({required String newEndingDo}) async {
    endingDo = newEndingDo;
    notifyListeners();
  }

  void updateMaxDistance({required int distance}) async {
    maxDistance = distance;
    notifyListeners();
  }

  void updateTimeBetweenNotes({required int time}) async {
    timeBetweenNotes = time;
    notifyListeners();
  }

  void updateTruncateNotes({required String time}) async {
    truncateNotes = time;
    notifyListeners();
  }

  /// 1. Set all values of the map at once
  void setNoteSelection(List<String> selectedKeys) {
    for (var key in noteKeys) {
      noteSelection[key] = selectedKeys.contains(key);
    }
    notifyListeners();
  }

  /// 2. Toggle one value of the map
  void toggleNoteSelection(String key) {
    if (noteSelection.containsKey(key)) {
      noteSelection[key] = !(noteSelection[key] ?? false);
      notifyListeners();
    }
  }

  /// 3. Get all values that are set to True as a list of Strings, in order
  List<String> getSelectedNotes() {
    return noteKeys.where((key) => noteSelection[key] == true).toList();
  }

  void updateSelectedOctave({required String octave}) async {
    selectedOctave = octave;
    notifyListeners();
  }

  void updateSelectedScale({required String newscale}) async {
    selectedScale = newscale;
    notifyListeners();
  }

  void updateChordFrequency({required String frequency}) async {
    chordFrequency = frequency;
    notifyListeners();
  }

  void toggleDisplayChordNames() {
    displayChordNames = !displayChordNames;
    notifyListeners();
  }

  void updateArpeggiateChordDelay({required int delay}) async {
    arpeggiateChordDelay = delay;
    notifyListeners();
  }

  void updateArpeggiateChordOrder({required String order}) async {
    arpeggiateChordOrder = order;
    notifyListeners();
  }

  void updateChordRange({required String newChordRange}) async {
    chordSetRange = newChordRange;
    notifyListeners();
  }

  void updateChordSet({required String newChordSet}) async {
    chordSet = newChordSet;
    notifyListeners();
  }

  /// Toggle a single chord in the selectedChords map
  void toggleSelectedChord(String chord) {
    if (selectedChords.containsKey(chord) && selectedChords[chord] == true) {
      selectedChords[chord] = false;
    } else {
      selectedChords[chord] = true;
    }
    notifyListeners();
  }

  /// Set all selected chords at once from a list of chord names
  void setSelectedChords(List<String> chords) {
    // Clear all previous selections
    selectedChords.clear();
    for (var chord in chords) {
      selectedChords[chord] = true;
    }
    notifyListeners();
  }

  /// Get all selected chords as a list of strings
  List<String> getSelectedChords() {
    return selectedChords.entries
        .where((entry) => entry.value == true)
        .map((entry) => entry.key)
        .toList();
  }

    Color multiplyHexColor(String hexColor, double factor) {
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) {
      int r = int.parse(hexColor.substring(0, 2), radix: 16);
      int g = int.parse(hexColor.substring(2, 4), radix: 16);
      int b = int.parse(hexColor.substring(4, 6), radix: 16);

      r = (r * factor).clamp(0, 255).toInt();
      g = (g * factor).clamp(0, 255).toInt();
      b = (b * factor).clamp(0, 255).toInt();

      return Color.fromARGB(255, r, g, b);
    }
    return Colors.grey;
  }

  // b. Get chord button color
  Color getChordButtonColor(String chordName) {
    const color1 = "#8189d3";
    const color2 = "#89afaa";
    const color3 = "#bcae9a";
    const color4 = "#c3b2b7";
    const color5 = "#d0a89b";
    const buttonColor = "#84b6d4";
    const factor1 = 0.85;
    const factor2 = 1.0;
    const factor3 = 1.15;
    const factor4 = 1.3;
    //const FACTOR5 = 1.45;

    String c = chordName;
    if (c.endsWith("_VL_R")) return multiplyHexColor(color1, factor1);
    if (c.endsWith("_L_R")) return multiplyHexColor(color1, factor2);
    if (c.endsWith("_M_R")) return multiplyHexColor(color1, factor3);
    if (c.endsWith("_H_R")) return multiplyHexColor(color1, factor4);

    if (c.endsWith("_VL_1i")) return multiplyHexColor(color2, factor1);
    if (c.endsWith("_L_1i")) return multiplyHexColor(color2, factor2);
    if (c.endsWith("_M_1i")) return multiplyHexColor(color2, factor3);
    if (c.endsWith("_H_1i")) return multiplyHexColor(color2, factor4);

    if (c.endsWith("_VL_2i")) return multiplyHexColor(color3, factor1);
    if (c.endsWith("_L_2i")) return multiplyHexColor(color3, factor2);
    if (c.endsWith("_M_2i")) return multiplyHexColor(color3, factor3);
    if (c.endsWith("_H_2i")) return multiplyHexColor(color3, factor4);

    if (c.endsWith("_VL_3i")) return multiplyHexColor(color4, factor1);
    if (c.endsWith("_L_3i")) return multiplyHexColor(color4, factor2);
    if (c.endsWith("_M_3i")) return multiplyHexColor(color4, factor3);
    if (c.endsWith("_H_3i")) return multiplyHexColor(color4, factor4);

    if (c.endsWith("_All")) return multiplyHexColor(color5, factor2);

    return multiplyHexColor(buttonColor, 1.0);
  }

  
}
