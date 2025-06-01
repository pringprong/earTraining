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

  GeneralProvider({
    this.selectedKey = "C",
    this.selectedInstrument =
        "Piano", // Initialize any default values or load settings if necessary
  });

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
}