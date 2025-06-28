import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/theme.dart';

class GeneralProvider extends ChangeNotifier {
  ThemeData _themeData = darkMode;
  ThemeData get getThemeData {
    return _themeData;
  }

  bool darkModeBool = false;
  void setDarkMode(bool value) {
    darkModeBool = value;
    if (darkModeBool) {
      _themeData = lightMode;
    } else {
      _themeData = darkMode;
    }
    notifyListeners();
    saveSettings();
  }

  // Define your provider variables here
  String selectedKey = "C";
  int numberOfNotes = 5;
  int maxDistance = 7; // Maximum distance between notes
  bool allowRepeatedNotes = false;
  String selectedInstrument = "Piano";

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
  int arpeggiateChordDelay = 50; // Default chord arpeggiation speed
  String arpeggiateChordOrder = "Ascending"; // Default arpeggiate chord order
  bool allowRepeatedChords = false; // Allow repeated chords

  String chordSetRange = "Middle"; // Default chord set range
  String chordSet = "I_IV_V"; // Default chord set

  List<String> mappingKeys = [];
  List<String> instruments = [];
  Map<String, Map<String, Map<String, String>>> nestedMapping = {};
  Map<String, Map<String, Map<String, String>>> get getNestedMapping {
    return nestedMapping;
  }

  List<String> get getMappingKeys {
    return mappingKeys;
  }

  List<String> get getInstruments {
    return instruments;
  }

  Map<String, Map<String, Map<String, List<String>>>> chordsMapping = {};
  List<String> chordList = [];
  Map<String, Map<String, List<String>>> chordSetsMapping = {};
  List<String> rangesList = [];
  List<String> chordSetsList = [];
  Map<String, List<String>> chordMap = {};
  List<String> get getChordList {
    return chordList;
  }

  List<String> get getRangesList {
    return rangesList;
  }

  List<String> get getChordSetsList {
    return chordSetsList;
  }

  Map<String, List<String>> get getChordMap {
    return chordMap;
  }

  Map<String, Map<String, List<String>>> get getChordSetsMapping {
    return chordSetsMapping;
  }

  Map<String, Map<String, Map<String, List<String>>>> get getChordsMapping {
    return chordsMapping;
  }

  Map<String, Map<String, List<String>>> scalesMapping = {};
  List<String> octavekeys = [];
  List<String> scalekeys = [];
  List<String> get getOctaveKeys {
    return octavekeys;
  }

  List<String> get getScaleKeys {
    return scalekeys;
  }

  Map<String, Map<String, List<String>>> get getScalesMapping {
    return scalesMapping;
  }

  List<String> noteKeys = [];
  Map<String, String> noteColors = {};
  Map<String, double> noteColorFactors = {};
  List<String> get getNoteKeys {
    return noteKeys;
  }

  Map<String, String> get getNoteColors {
    return noteColors;
  }

  Map<String, double> get getNoteColorFactors {
    return noteColorFactors;
  }

  static const List<String> defaultNoteKeys = [
    "do",
    "re",
    "mi",
    "fa",
    "so",
    "la",
    "ti",
    "do1",
  ];

  Map<String, bool> noteSelection = {};
  Map<String, bool> get getNoteSelection {
    return noteSelection;
  }

  // --- Selected Chords Map ---
  Map<String, bool> selectedChords = {
    for (var key in "I_M_R,IV_M_R,V_M_R".split(','))
      key: true, // Initialize all chords as not selected
  };

  GeneralProvider() {
    loadSettings();
  }

  // Add methods to update the state
  void updateSelectedKey({required String newkey}) async {
    selectedKey = newkey;
    saveSettings();
    notifyListeners();
  }

  void updateSelectedInstrument({required String instrument}) async {
    selectedInstrument = instrument;
    saveSettings();
    notifyListeners();
  }

  void updateNumberOfNotes({required int count}) async {
    numberOfNotes = count;
    saveSettings();
    notifyListeners();
  }

  void toggleAllowRepeatedNotes() {
    allowRepeatedNotes = !allowRepeatedNotes;
    saveSettings();
    notifyListeners();
  }

  void toggleStartWithDo() {
    startWithDo = !startWithDo;
    saveSettings();
    notifyListeners();
  }

  void toggleEndWithDo() {
    endWithDo = !endWithDo;
    saveSettings();
    notifyListeners();
  }

  void updateStartingDo({required String newStartingDo}) async {
    startingDo = newStartingDo;
    saveSettings();
    notifyListeners();
  }

  void updateEndingDo({required String newEndingDo}) async {
    endingDo = newEndingDo;
    saveSettings();
    notifyListeners();
  }

  void updateMaxDistance({required int distance}) async {
    maxDistance = distance;
    saveSettings();
    notifyListeners();
  }

  void updateTimeBetweenNotes({required int time}) async {
    timeBetweenNotes = time;
    saveSettings();
    notifyListeners();
  }

  void updateTruncateNotes({required String time}) async {
    truncateNotes = time;
    saveSettings();
    notifyListeners();
  }

  /// 1. Set all values of the map at once
  void setNoteSelection({required List<String> selectedKeys}) async {
    for (var key in noteKeys) {
      noteSelection[key] = selectedKeys.contains(key);
    }
    saveSettings();
    notifyListeners();
  }

  /// 2. Toggle one value of the map
  void toggleNoteSelection({required String key}) async {
    noteSelection[key] = !(noteSelection[key] ?? false);
    saveSettings();
    notifyListeners();
  }

  /// 3. Get all values that are set to True as a list of Strings, in order
  List<String> getSelectedNotes() {
    return noteKeys.where((key) => noteSelection[key] == true).toList();
  }

  void updateSelectedOctave({required String octave}) async {
    selectedOctave = octave;
    saveSettings();
    notifyListeners();
  }

  void updateSelectedScale({required String newscale}) async {
    selectedScale = newscale;
    saveSettings();
    notifyListeners();
  }

  void updateChordFrequency({required String frequency}) async {
    chordFrequency = frequency;
    saveSettings();
    notifyListeners();
  }

  void toggleDisplayChordNames() {
    displayChordNames = !displayChordNames;
    saveSettings();
    notifyListeners();
  }

  void updateArpeggiateChordDelay({required int delay}) async {
    arpeggiateChordDelay = delay;
    saveSettings();
    notifyListeners();
  }

  void updateArpeggiateChordOrder({required String order}) async {
    arpeggiateChordOrder = order;
    saveSettings();
    notifyListeners();
  }

  void updateChordRange({required String newChordRange}) async {
    chordSetRange = newChordRange;
    saveSettings();
    notifyListeners();
  }

  void updateChordSet({required String newChordSet}) async {
    chordSet = newChordSet;
    saveSettings();
    notifyListeners();
  }

  /// Toggle a single chord in the selectedChords map
  void toggleSelectedChord(String chord) {
    if (selectedChords.containsKey(chord) && selectedChords[chord] == true) {
      selectedChords[chord] = false;
    } else {
      selectedChords[chord] = true;
    }
    saveSettings();
    notifyListeners();
  }

  /// Set all selected chords at once from a list of chord names
  void setSelectedChords(List<String> chords) {
    // Clear all previous selections
    selectedChords.clear();
    for (var chord in chords) {
      if (chord.isNotEmpty) {
        selectedChords[chord] = true;
      }
    }
    saveSettings();
    notifyListeners();
  }

  /// Get all selected chords as a list of strings
  List<String> getSelectedChords() {
    //print ("Selected Chords: $selectedChords");
    if (selectedChords.isEmpty) {
      return ["No chords selected"];
    }
    return selectedChords.entries
        .where((entry) => entry.value == true)
        .map((entry) => entry.key)
        .toList();
  }

  static Color multiplyHexColor(String hexColor, double factor) {
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
  static Color getChordButtonColor(String chordName) {
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

  void toggleAllowRepeatedChords() {
    allowRepeatedChords = !allowRepeatedChords;
    saveSettings();
    notifyListeners();
  }

  Future<void> get loadMappingJSON async {
    final String jsonData = await rootBundle.loadString(
      'assets/mapping/Mapping.json',
    );
    final List<dynamic> items = await json.decode(jsonData);
    for (var item in items) {
      String key = item['Key'];
      String instrument = item['Instrument'];
      String note = item['Note'];
      String filename = item['File'];
      nestedMapping[key] ??= {};
      nestedMapping[key]![instrument] ??= {};
      nestedMapping[key]![instrument]![note] = filename;

      if (key.isNotEmpty && !mappingKeys.contains(key)) {
        mappingKeys.add(key);
      }
      if (instrument.length > 1 && !instruments.contains(instrument)) {
        instruments.add(instrument);
      }
    }
    notifyListeners();
  }

  Future<void> get loadChordSetsJSON async {
    // Load Chords.json and populate chordsMapping
    final String jsonData = await rootBundle.loadString(
      'assets/mapping/Chords.json',
    );
    final List<dynamic> items = await json.decode(jsonData);
    for (var item in items) {
      String category = item['Category'];
      String degree = item['Degree'];
      String chordSet = item['Chord Set'];
      String notesStr = item['Notes'];
      List<String> notes = notesStr.split(',').map((s) => s.trim()).toList();

      if (chordSet.isNotEmpty && !chordList.contains(chordSet)) {
        chordList.add(chordSet);
      }
      if (chordSet.isNotEmpty && !chordMap.containsKey(chordSet)) {
        chordMap[chordSet] = notes;
      }
      chordsMapping[category] ??= {};
      chordsMapping[category]![degree] ??= {};
      chordsMapping[category]![degree]![chordSet] = notes;
    }
    // Load Chords.json and populate chordsSetMapping
    final String jsonData2 = await rootBundle.loadString(
      'assets/mapping/ChordSets.json',
    );
    final List<dynamic> items2 = await json.decode(jsonData2);
    for (var item in items2) {
      String rangeValue = item['Range'];
      String set = item['Set'];
      String chordSet = item['Chords'];
      List<String> chordSets =
          chordSet.split(',').map((s) => s.trim()).toList();

      chordSetsMapping[rangeValue] ??= {};
      chordSetsMapping[rangeValue]![set] = chordSets;

      if (rangeValue.isNotEmpty && !rangesList.contains(rangeValue)) {
        rangesList.add(rangeValue);
      }
      if (set.isNotEmpty && !chordSetsList.contains(set)) {
        chordSetsList.add(set);
      }
    }

    // Add "Select all" set for each rangeValue
    for (var rangeValue in rangesList) {
      chordSetsMapping[rangeValue]?["Select all"] = List<String>.from(
        chordList,
      );
    }
    notifyListeners();
  }

  Future<void> get loadScalesJSON async {
    // Load Scales.json and populate scalesMapping
    final String jsonData = await rootBundle.loadString(
      'assets/mapping/Scales.json',
    );
    final List<dynamic> items = await json.decode(jsonData);
    for (var item in items) {
      String octave = item['Octave'];
      String set = item['Set'];
      String notesStr = item['Notes'];
      List<String> notes = notesStr.split(',').map((s) => s.trim()).toList();

      scalesMapping[octave] ??= {};
      scalesMapping[octave]![set] = notes;

      if (octave.isNotEmpty && !octavekeys.contains(octave)) {
        octavekeys.add(octave);
      }
      if (set.isNotEmpty && !scalekeys.contains(set)) {
        scalekeys.add(set);
      }
    }
    notifyListeners();
  }

  Future<void> get loadNotesJSON async {
    final String jsonData = await rootBundle.loadString(
      'assets/mapping/Notes.json',
    );
    final List<dynamic> items = await json.decode(jsonData);
    for (var item in items) {
      String note = item['Note'];
      String color = item['Color'];
      double factor = double.parse(item['Factor']);
      noteColors[note] = color;
      noteColorFactors[note] = factor;
      if (note.isNotEmpty && !noteKeys.contains(note)) {
        noteKeys.add(note);
      }
    }
    notifyListeners();
  }

  // Call this after any setting changes
  Future<void> saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settings = {
      'darkModeBool': darkModeBool,
      'selectedKey': selectedKey,
      'numberOfNotes': numberOfNotes,
      'maxDistance': maxDistance,
      'allowRepeatedNotes': allowRepeatedNotes,
      'selectedInstrument': selectedInstrument,
      'timeBetweenNotes': timeBetweenNotes,
      'truncateNotes': truncateNotes,
      'startWithDo': startWithDo,
      'endWithDo': endWithDo,
      'startingDo': startingDo,
      'endingDo': endingDo,
      'selectedOctave': selectedOctave,
      'selectedScale': selectedScale,
      'chordFrequency': chordFrequency,
      'displayChordNames': displayChordNames,
      'arpeggiateChordDelay': arpeggiateChordDelay,
      'arpeggiateChordOrder': arpeggiateChordOrder,
      'allowRepeatedChords': allowRepeatedChords,
      'chordSetRange': chordSetRange,
      'chordSet': chordSet,
      'noteSelection': jsonEncode(noteSelection),
      'selectedChords': jsonEncode(selectedChords),
    };
    prefs.setString('general_settings', jsonEncode(settings));
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('general_settings');
    if (jsonString == null) {
      resetAllSettings();
      return;
    }
    final settings = jsonDecode(jsonString);

    darkModeBool = settings['darkModeBool'] ?? false;
    selectedKey = settings['selectedKey'] ?? "C";
    numberOfNotes = settings['numberOfNotes'] ?? 5;
    maxDistance = settings['maxDistance'] ?? 7;
    allowRepeatedNotes = settings['allowRepeatedNotes'] ?? false;
    selectedInstrument = settings['selectedInstrument'] ?? "Piano";
    timeBetweenNotes = settings['timeBetweenNotes'] ?? 900;
    truncateNotes = settings['truncateNotes'] ?? "1200";
    startWithDo = settings['startWithDo'] ?? true;
    endWithDo = settings['endWithDo'] ?? true;
    startingDo = settings['startingDo'] ?? "do";
    endingDo = settings['endingDo'] ?? "do";
    selectedOctave = settings['selectedOctave'] ?? "Middle octave";
    selectedScale = settings['selectedScale'] ?? "Diatonic major";
    chordFrequency = settings['chordFrequency'] ?? "Every 4 notes";
    displayChordNames = settings['displayChordNames'] ?? false;
    arpeggiateChordDelay = settings['arpeggiateChordDelay'] ?? 50;
    arpeggiateChordOrder = settings['arpeggiateChordOrder'] ?? "Ascending";
    allowRepeatedChords = settings['allowRepeatedChords'] ?? false;
    chordSetRange = settings['chordSetRange'] ?? "Middle";
    chordSet = settings['chordSet'] ?? "I_IV_V";
    noteSelection = Map<String, bool>.from(
      jsonDecode(
        settings['noteSelection'] ??
            '{"do":true,"re":true,"mi":true,"fa":true,"so":true,"la":true,"ti":true,"do1":true}',
      ),
    );
    selectedChords = Map<String, bool>.from(
      jsonDecode(
        settings['selectedChords'] ??
            '{"I_M_R":true,"IV_M_R":true,"V_M_R":true}',
      ),
    );
    if (darkModeBool) {
      _themeData = lightMode;
    } else {
      _themeData = darkMode;
    }
    notifyListeners();
  }

  void resetAllSettings() {
    // Set all settings to their default values
    darkModeBool = false;
    selectedKey = "C";
    numberOfNotes = 5;
    maxDistance = 7;
    allowRepeatedNotes = false;
    selectedInstrument = "Piano";
    timeBetweenNotes = 900;
    truncateNotes = "1200";
    startWithDo = true;
    endWithDo = true;
    startingDo = "do";
    endingDo = "do";
    selectedOctave = "Middle octave";
    selectedScale = "Diatonic major";
    chordFrequency = "Every 4 notes";
    displayChordNames = true;
    arpeggiateChordDelay = 50;
    arpeggiateChordOrder = "Ascending";
    allowRepeatedChords = false;
    chordSetRange = "Middle";
    chordSet = "I_IV_V";
    noteSelection = {for (var key in defaultNoteKeys) key: true};
    selectedChords = {
      for (var key in "I_M_R,IV_M_R,V_M_R".split(','))
        key: true, // Initialize all chords as not selected
    };
    if (darkModeBool) {
      _themeData = lightMode;
    } else {
      _themeData = darkMode;
    }
    saveSettings();
    notifyListeners();
  }
}
