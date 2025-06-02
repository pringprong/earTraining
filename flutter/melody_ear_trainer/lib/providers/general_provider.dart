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

  String selectedOctave  = "All octaves"; // Default octave selection
  String selectedScale = "Chromatic"; // Default scale selection
    // Map of booleans for note selection
  static const List<String> noteKeys = [
    "do0", "ga0", "re0", "nu0", "mi0", "fa0", "jur0", "so0", "ki0", "la0", "pe0", "ti0",
    "do", "ga", "re", "nu", "mi", "fa", "jur", "so", "ki", "la", "pe", "ti",
    "do1", "ga1", "re1", "nu1", "mi1", "fa1", "jur1", "so1", "ki1", "la1", "pe1", "ti1",
    "do2"
  ];

  Map<String, bool> noteSelection = {
    for (var key in noteKeys) key: true,
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
  
}