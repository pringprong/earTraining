import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

abstract class GeneralProvider extends ChangeNotifier {
  /// Name used to save settings in SharedPreferences
  /// Override in subclasses for different settings
  String saveName = "general_settings";

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

  // Settings that are user preferences
  // and will be set in the Mission Settings

  String defaultKey = "C";
  String selectedKey = "C";
  String selectedInstrument = "Piano";

  void setKeyAndInstrument(String newKey, String newInstrument) {
    selectedKey = newKey;
    selectedInstrument = newInstrument;
    saveSettings();
    notifyListeners();
  }

  // Settings that will be fixed by the level
  // Either because they are related to melody difficulty
  // or because we don't want the user to be able to change them
  // in the missions
  Map<String, bool> _noteSelection = {};

  int numberOfNotesDefault = 5;
  int numberOfNotes = 5;
  int maxDistance = 7;
  bool allowRepeatedNotes = false;
  int timeBetweenNotes = 900; // Time in milliseconds between notes
  String truncateNotes = "1200"; // Truncate notes to 1200 milliseconds
  String playbackSpeed = "Normal"; // Playback speed

  bool startWithDo = true;
  bool endWithDo = true;
  String startingDoDefault = "";
  String endingDoDefault = "";
  String startingDo = ""; // Default starting note
  String endingDo = ""; // Default ending note

  String chordFrequencyDefault = "Every 4 notes";
  String chordFrequency = "Every 4 notes";

  void setLevelDetails(
    List<String> newSelectedKeys,
    int newNumNotes,
    int newMaxDistance,
    bool newAllowRepeatedNotes,
    String newPlaybackSpeed,
    bool newStartWithDo,
    bool newEndWithDo,
    String newStartingDo,
    String newEndingDo,
    String newChordFrequency,
  ) {
    for (var key in noteKeys) {
      _noteSelection[key] = newSelectedKeys.contains(key);
    }
    numberOfNotes = newNumNotes;
    maxDistance = newMaxDistance;
    allowRepeatedNotes = newAllowRepeatedNotes;
    playbackSpeed = newPlaybackSpeed;

    switch (newPlaybackSpeed) {
      case 'Very fast':
        {
          timeBetweenNotes = 300;
          truncateNotes = '600';
        }
      case 'Fast':
        {
          timeBetweenNotes = 600;
          truncateNotes = '900';
        }
      case 'Normal':
        {
          timeBetweenNotes = 900;
          truncateNotes = '1200';
        }
      case 'Slow':
        {
          timeBetweenNotes = 1200;
          truncateNotes = '1500';
        }
    }
    startWithDo = newStartWithDo;
    endWithDo = newEndWithDo;
    startingDo = newStartingDo;
    endingDo = newEndingDo;
    chordFrequency = newChordFrequency;

    saveSettings();
    notifyListeners();
  }

  // only for levels that have chords:
  int arpeggiateChordDelayGuitarDefault = 0;
  int arpeggiateChordDelayGuitar = 0; // Default chord arpeggiation speed

  int arpeggiateChordDelayPianoDefault = 100;
  int arpeggiateChordDelayPiano = 100; // Default chord arpeggiation speed

  int arpeggiateChordDelaySolfegeDefault = 500;
  int arpeggiateChordDelaySolfege = 500; // Default chord arpeggiation speed

  int arpeggiateChordDelaySpokenDefault = 600;
  int arpeggiateChordDelaySpoken = 600; // Default chord arpeggiation speed

  String arpeggiateChordOrder = "Ascending"; // Default arpeggiate chord order
  bool allowRepeatedChords = false; // Allow repeated chords

  // --- Selected Chords Map ---
  Map<String, bool> selectedChords = {
    for (var key in "I_Rt,IV0_Sec,V0_Fir".split(',')) key: true,
  };

  voidSetChordDetails(
    int newArpeggiateChordDelayGuitar,
    int newArpeggiateChordDelayPiano,
    int newArpeggiateChordDelaySolfege,
    int newArpeggiateChordDelaySpoken,
    String newArpeggiateChordOrder,
    bool newAllowRepeatedChords,
    List<String> newChords,
  ) {
    arpeggiateChordDelayGuitar = newArpeggiateChordDelayGuitar;
    arpeggiateChordDelayPiano = newArpeggiateChordDelayPiano;
    arpeggiateChordDelaySolfege = newArpeggiateChordDelaySolfege;
    arpeggiateChordDelaySpoken = newArpeggiateChordDelaySpoken;
    arpeggiateChordOrder = newArpeggiateChordOrder;
    allowRepeatedChords = newAllowRepeatedChords;
    selectedChords.clear();
    for (var chord in newChords) {
      if (chord.isNotEmpty) {
        selectedChords[chord] = true;
      }
    }
    saveSettings();
    notifyListeners();
  }

  // Settings that are only relevant to the custom practice area
  // and are ignored by the missions and levels

  String selectedOctave = "Middle octave"; // Default octave selection
  String selectedScale = "Diatonic major"; // Default scale selection
  String chordSetRange = "Middle"; // Default chord set range
  String chordSet = "I_IV_V"; // Default chord set

  // settings that are ignored by everyone
  bool displayChordNames = false; // Whether to display chord names

  // settings for the handsfree
  int numberOfRounds = 5;
  int melodyRepeatsDefault = 3;
  int melodyRepeats = 3;
  int spokenRepeatsDefault = 1;
  int spokenRepeats = 1;
  int solfegeRepeatsDefault = 1;
  int solfegeRepeats = 1;
  String handsfreeInstrument = "Alternate";
  int timeDelayRepeat = 5;

  GeneralProvider() {
    loadSettings();
  }

  Map<String, bool> get getNoteSelection {
    return _noteSelection;
  }

  String get getSelectedKey {
    return selectedKey;
  }

  String get getSelectedInstrument {
    return selectedInstrument;
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

  void updatePlaybackSpeed({required String speed}) async {
    playbackSpeed = speed;
    saveSettings();
    notifyListeners();
  }

  String get getPlaybackSpeed {
    return playbackSpeed;
  }

  /// 1. Set all values of the map at once
  void setNoteSelection({required List<String> selectedKeys}) async {
    for (var key in noteKeys) {
      _noteSelection[key] = selectedKeys.contains(key);
    }
    saveSettings();
    notifyListeners();
  }

  /// 2. Toggle one value of the map
  void toggleNoteSelection({required String key}) async {
    _noteSelection[key] = !(_noteSelection[key] ?? false);
    saveSettings();
    notifyListeners();
  }

  /// 3. Get all values that are set to True as a list of Strings, in order
  List<String> getSelectedNotes() {
    return noteKeys.where((key) => _noteSelection[key] == true).toList();
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

  void updateArpeggiateChordDelayGuitar({required int delay}) async {
    arpeggiateChordDelayGuitar = delay;
    saveSettings();
    notifyListeners();
  }

  void updateArpeggiateChordDelayPiano({required int delay}) async {
    arpeggiateChordDelayPiano = delay;
    saveSettings();
    notifyListeners();
  }

  void updateArpeggiateChordDelaySolfege({required int delay}) async {
    arpeggiateChordDelaySolfege = delay;
    saveSettings();
    notifyListeners();
  }

  void updateArpeggiateChordDelaySpoken({required int delay}) async {
    arpeggiateChordDelaySpoken = delay;
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
    if (selectedChords.isEmpty) {
      return ["No chords selected"];
    }
    return selectedChords.entries
        .where((entry) => entry.value == true)
        .map((entry) => entry.key)
        .toList();
  }

  void toggleAllowRepeatedChords() {
    allowRepeatedChords = !allowRepeatedChords;
    saveSettings();
    notifyListeners();
  }

  /******** Handsfree listening settings  ********/

  int get getNumberOfRounds {
    return numberOfRounds;
  }

  void setNumberOfRounds({required int rounds}) async {
    numberOfRounds = rounds;
    saveSettings();
    notifyListeners();
  }

  int get getMelodyRepeats {
    return melodyRepeats;
  }

  void setMelodyRepeats({required int repeats}) async {
    melodyRepeats = repeats;
    saveSettings();
    notifyListeners();
  }

  int get getSpokenRepeats {
    return spokenRepeats;
  }

  void setSpokenRepeats({required int repeats}) async {
    spokenRepeats = repeats;
    saveSettings();
    notifyListeners();
  }

  int get getSolfegeRepeats {
    return solfegeRepeats;
  }

  void setSolfegeRepeats({required int repeats}) async {
    solfegeRepeats = repeats;
    saveSettings();
    notifyListeners();
  }

  String get getHandsfreeInstrument {
    return handsfreeInstrument;
  }

  void setHandsfreeInstrument({required String instrument}) async {
    handsfreeInstrument = instrument;
    saveSettings();
    notifyListeners();
  }

  int get getTimeDelayRepeat {
    return timeDelayRepeat;
  }

  void setTimeDelayRepeat({required int delay}) async {
    timeDelayRepeat = delay;
    saveSettings();
    notifyListeners();
  }

  /******** end Handsfree Listening settings */

  // Call this after any setting changes
  Future<void> saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settings = {
      'selectedKey': selectedKey,
      'numberOfNotes': numberOfNotes,
      'maxDistance': maxDistance,
      'allowRepeatedNotes': allowRepeatedNotes,
      'selectedInstrument': selectedInstrument,
      'timeBetweenNotes': timeBetweenNotes,
      'truncateNotes': truncateNotes,
      'playbackSpeed': playbackSpeed,
      'startWithDo': startWithDo,
      'endWithDo': endWithDo,
      'startingDo': startingDoDefault,
      'endingDo': endingDoDefault,
      'selectedOctave': selectedOctave,
      'selectedScale': selectedScale,
      'chordFrequency': chordFrequencyDefault,
      'displayChordNames': displayChordNames,
      'arpeggiateChordDelayGuitar': arpeggiateChordDelayGuitar,
      'arpeggiateChordDelayPiano': arpeggiateChordDelayPiano,
      'arpeggiateChordDelaySolfege': arpeggiateChordDelaySolfege,
      'arpeggiateChordDelaySpoken': arpeggiateChordDelaySpoken,
      'arpeggiateChordOrder': arpeggiateChordOrder,
      'allowRepeatedChords': allowRepeatedChords,
      'chordSetRange': chordSetRange,
      'chordSet': chordSet,
      'noteSelection': jsonEncode(_noteSelection),
      'selectedChords': jsonEncode(selectedChords),
      'numberOfRounds': numberOfRounds,
      'melodyRepeats': melodyRepeats,
      'spokenRepeats': spokenRepeats,
      'solfegeRepeats': solfegeRepeats,
      'handsfreeInstrument': handsfreeInstrument,
      'timeDelayRepeat': timeDelayRepeat,
    };
    prefs.setString(saveName, jsonEncode(settings));
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(saveName);
    if (jsonString == null) {
      resetAllSettings();
      return;
    }
    final settings = jsonDecode(jsonString);

    selectedKey = settings['selectedKey'] ?? defaultKey;
    numberOfNotes = settings['numberOfNotes'] ?? numberOfNotesDefault;
    maxDistance = settings['maxDistance'] ?? 7;
    allowRepeatedNotes = settings['allowRepeatedNotes'] ?? false;
    selectedInstrument = settings['selectedInstrument'] ?? "Piano";
    timeBetweenNotes = settings['timeBetweenNotes'] ?? 900;
    truncateNotes = settings['truncateNotes'] ?? "1200";
    playbackSpeed = settings['playbackSpeed'] ?? "Normal";
    startWithDo = settings['startWithDo'] ?? true;
    endWithDo = settings['endWithDo'] ?? true;
    startingDo = settings['startingDo'] ?? startingDoDefault;
    endingDo = settings['endingDo'] ?? endingDoDefault;
    selectedOctave = settings['selectedOctave'] ?? "Middle octave";
    selectedScale = settings['selectedScale'] ?? "Diatonic major";
    chordFrequency = settings['chordFrequency'] ?? chordFrequencyDefault;
    displayChordNames = settings['displayChordNames'] ?? false;
    arpeggiateChordDelayGuitar =
        settings['arpeggiateChordDelayGuitar'] ??
        arpeggiateChordDelayGuitarDefault;
    arpeggiateChordDelayPiano =
        settings['arpeggiateChordDelayPiano'] ??
        arpeggiateChordDelayPianoDefault;
    arpeggiateChordDelaySolfege =
        settings['arpeggiateChordDelaySolfege'] ??
        arpeggiateChordDelaySolfegeDefault;
    arpeggiateChordDelaySpoken =
        settings['arpeggiateChordDelaySpoken'] ??
        arpeggiateChordDelaySpokenDefault;
    arpeggiateChordOrder = settings['arpeggiateChordOrder'] ?? "Ascending";
    allowRepeatedChords = settings['allowRepeatedChords'] ?? false;
    chordSetRange = settings['chordSetRange'] ?? "Middle";
    chordSet = settings['chordSet'] ?? "I_IV_V";
    _noteSelection = Map<String, bool>.from(
      jsonDecode(
        settings['noteSelection'] ??
            '{"do":true,"re":true,"mi":true,"fa":true,"so":true,"la":true,"ti":true,"do1":true}',
      ),
    );
    selectedChords = Map<String, bool>.from(
      jsonDecode(
        settings['selectedChords'] ?? '{"I_Rt":true,"IV_Rt":true,"V_Rt":true}',
      ),
    );
    numberOfRounds = settings['numberOfRounds'] ?? 5;
    melodyRepeats = settings['melodyRepeats'] ?? melodyRepeatsDefault;
    spokenRepeats = settings['spokenRepeats'] ?? spokenRepeatsDefault;
    solfegeRepeats = settings['solfegeRepeats'] ?? solfegeRepeatsDefault;
    handsfreeInstrument = settings['handsfreeInstrument'] ?? "Alternate";
    timeDelayRepeat = settings['timeDelayRepeat'] ?? 5;
    notifyListeners();
  }

  void resetAllSettings() {
    // Set all settings to their default values
    selectedKey = defaultKey;
    numberOfNotes = numberOfNotesDefault;
    maxDistance = 7;
    allowRepeatedNotes = false;
    selectedInstrument = "Piano";
    timeBetweenNotes = 900;
    truncateNotes = "1200";
    playbackSpeed = "Normal";
    startWithDo = true;
    endWithDo = true;
    startingDo = startingDoDefault;
    endingDo = endingDoDefault;
    selectedOctave = "Middle octave";
    selectedScale = "Diatonic major";
    chordFrequency = chordFrequencyDefault;
    displayChordNames = true;
    arpeggiateChordDelayGuitar = arpeggiateChordDelayGuitarDefault;
    arpeggiateChordDelayPiano = arpeggiateChordDelayPianoDefault;
    arpeggiateChordDelaySolfege = arpeggiateChordDelaySolfegeDefault;
    arpeggiateChordDelaySpoken = arpeggiateChordDelaySpokenDefault;
    arpeggiateChordOrder = "Ascending";
    allowRepeatedChords = false;
    chordSetRange = "Middle";
    chordSet = "I_IV_V";
    _noteSelection = {for (var key in defaultNoteKeys) key: true};
    selectedChords = {
      for (var key in "I_Rt,IV0_Sec,V0_Fir".split(','))
        key: true, // Initialize all chords as not selected
    };
    numberOfRounds = 5;
    melodyRepeats = melodyRepeatsDefault;
    spokenRepeats = spokenRepeatsDefault;
    solfegeRepeats = solfegeRepeatsDefault;
    handsfreeInstrument = "Alternate";
    timeDelayRepeat = 5;
    saveSettings();
    notifyListeners();
  }
}

class MelodyIDSettings extends GeneralProvider {
  @override
  String saveName = "melody_id_settings";

  @override
  int numberOfNotesDefault = 5;

  @override
  String startingDoDefault = "do";

  @override
  String endingDoDefault = "do";

  @override
  String startingDo = "do";

  @override
  String endingDo = "do";

  @override
  String chordFrequencyDefault = "Never";

  @override
  int melodyRepeatsDefault = 3;

  @override
  int spokenRepeatsDefault = 1;

  @override
  int solfegeRepeatsDefault = 2;
}

class MelodySingingSettings extends GeneralProvider {
  @override
  String saveName = "melody_singing_settings";

  @override
  int numberOfNotesDefault = 4;

  @override
  String startingDoDefault = "do";

  @override
  String endingDoDefault = "do";

  @override
  String startingDo = "do";

  @override
  String endingDo = "do";

  @override
  String chordFrequencyDefault = "Never";

  @override
  int melodyRepeatsDefault = 1;

  @override
  int spokenRepeatsDefault = 1;

  @override
  int solfegeRepeatsDefault = 1;
}

class chordIDSettings extends GeneralProvider {
  @override
  String saveName = "chord_id_settings";

  @override
  int numberOfNotesDefault = 3;

  @override
  String chordFrequencyDefault = "Every note";

  @override
  int arpeggiateChordDelayGuitarDefault = 0;

  @override
  int arpeggiateChordDelayPianoDefault = 100;

  @override
  String startingDoDefault = "I_Rt";

  @override
  String endingDoDefault = "I_Rt";

  @override
  String startingDo = "I_Rt";

  @override
  String endingDo = "I_Rt";

  @override
  int melodyRepeatsDefault = 3;

  @override
  int spokenRepeatsDefault = 0;

  @override
  int solfegeRepeatsDefault = 2;
}

class chordSingingSettings extends GeneralProvider {
  @override
  String saveName = "chord_singing_settings";

  @override
  int numberOfNotesDefault = 3;

  @override
  String chordFrequencyDefault = "Every note";

  @override
  int arpeggiateChordDelayGuitarDefault = 200;

  @override
  int arpeggiateChordDelayPianoDefault = 300;

  @override
  String startingDoDefault = "I_Rt";

  @override
  String endingDoDefault = "I_Rt";

  @override
  String startingDo = "I_Rt";

  @override
  String endingDo = "I_Rt";

  @override
  int melodyRepeatsDefault = 1;

  @override
  int spokenRepeatsDefault = 1;

  @override
  int solfegeRepeatsDefault = 1;
}

class chordMelodyIDSettings extends GeneralProvider {
  @override
  String saveName = "chord_melody_id_settings";

  @override
  int numberOfNotesDefault = 5;

  @override
  String startingDoDefault = "do";

  @override
  String endingDoDefault = "do";

  @override
  String startingDo = "do";

  @override
  String endingDo = "do";

  @override
  int arpeggiateChordDelayGuitarDefault = 0;

  @override
  int arpeggiateChordDelayPianoDefault = 50;

  @override
  String chordFrequencyDefault = "Every 4 notes";

  @override
  int melodyRepeatsDefault = 3;

  @override
  int spokenRepeatsDefault = 0;

  @override
  int solfegeRepeatsDefault = 2;
}

class chordMelodySingingSettings extends GeneralProvider {
  @override
  String saveName = "chord_melody_singing_settings";

  @override
  int numberOfNotesDefault = 4;

  @override
  String startingDoDefault = "do";

  @override
  String endingDoDefault = "do";

  @override
  String startingDo = "do";

  @override
  String endingDo = "do";

  @override
  int arpeggiateChordDelayGuitarDefault = 200;

  @override
  int arpeggiateChordDelayPianoDefault = 300;

  @override
  String chordFrequencyDefault = "Every 4 notes";

  @override
  int melodyRepeatsDefault = 1;

  @override
  int spokenRepeatsDefault = 1;

  @override
  int solfegeRepeatsDefault = 1;
}

class missionSettingsProvider extends GeneralProvider {
  @override
  String saveName = "minimal_settings";

  @override
  int numberOfNotesDefault = 5;

  @override
  String startingDoDefault = "do";

  @override
  String endingDoDefault = "do";

  @override
  String startingDo = "do";

  @override
  String endingDo = "do";

  @override
  String chordFrequencyDefault = "Never";

  @override
  int melodyRepeatsDefault = 1;

  @override
  int spokenRepeatsDefault = 1;

  @override
  int solfegeRepeatsDefault = 1;
}
