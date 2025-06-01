import 'package:flutter/material.dart';
//import 'package:provider/provider.dart';

class GeneralProvider extends ChangeNotifier {
  // Define your provider variables here
  String selectedKey = "C";
  String selectedInstrument = "";
  int numberOfNotes = 5;
  bool allowRepeatedNotes = false;
  bool startWithDo = true;
  bool endWithDo = true;

  GeneralProvider({
    this.selectedKey = "C",
    this.selectedInstrument ="Piano", // Initialize any default values or load settings if necessary
  });

  // Add methods to update the state
  void updateSelectedKey({
    required String newkey,
    }) async {
    selectedKey = newkey;
    notifyListeners();
  }

  void updateSelectedInstrument({
    required String instrument,
    }) async {
    selectedInstrument = instrument;
    notifyListeners();
  }

  void updateNumberOfNotes({
    required int count, 
    }) async {
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
}
