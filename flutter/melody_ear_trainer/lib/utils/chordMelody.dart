//import 'package:flutter/material.dart';
import 'package:melody_ear_trainer/providers/general_provider.dart';
import 'dart:math';
import 'helper.dart';

class ChordMelody {
  List<String> chordMelody = [];
  List<List<String>> chordMelodySolfege = [];

  ChordMelody() {
    // Initialize with some default values if needed
    chordMelody = [];
    chordMelodySolfege = [];
  }

  void clear() {
    chordMelody.clear();
    chordMelodySolfege.clear();
  }

  getChordMelody() {
    return chordMelody;
  }

  getChordMelodySolfege() {
    return chordMelodySolfege;
  }

  bool sameAs(ChordMelody other) {
    return listEquals(this.chordMelody, other.getChordMelody());
  }

  addNote(String note) {
    chordMelody.add(note);
    chordMelodySolfege.add([note]);
  }

  addChord(String chord, List<String> notes) {
    chordMelody.add(chord);
    chordMelodySolfege.add(List<String>.from(notes));
  }

  removeLastNote() {
    if (chordMelody.isNotEmpty) {
      chordMelody.removeLast();
    }
    if (chordMelodySolfege.isNotEmpty) {
      chordMelodySolfege.removeLast();
    }
  }

  String generateChordMelody(GeneralProvider generalProvider) {
    final chordMap = generalProvider.getChordMap;
    chordMelody.clear();
    chordMelodySolfege.clear();

    final numNotes = generalProvider.numberOfNotes;
    final maxDist = generalProvider.maxDistance;
    final allowRepeats = generalProvider.allowRepeatedNotes;
    final startWithDo = generalProvider.startWithDo;
    final endWithDo = generalProvider.endWithDo;
    final startingDo = generalProvider.startingDo;
    final endingDo = generalProvider.endingDo;
    final notes = generalProvider.getSelectedNotes();
    final chordFrequency = generalProvider.chordFrequency;
    final chords = generalProvider.getSelectedChords();
    final allowRepeatedChords = generalProvider.allowRepeatedChords;
    String previousChord = "";

    int chordStartOffset = 2;
    if (chordFrequency == "Every 3 notes") {
      chordStartOffset = 1;
    }

    List<String> availableNotes = List<String>.from(notes);
    List<String> availableChords = List<String>.from(chords);

    // Calculate minimums
    int minNumberOfNotes = !allowRepeats ? 2 : 1;
    minNumberOfNotes = chordFrequency == "Every note" ? 0 : minNumberOfNotes;

    int minNumberOfChords = !allowRepeatedChords ? 2 : 1;
    minNumberOfChords = chordFrequency == "Never" ? 0 : minNumberOfChords;

    int effectiveLength =
        numNotes - (startWithDo ? 1 : 0) - (endWithDo ? 1 : 0);
    minNumberOfNotes = min(minNumberOfNotes, effectiveLength);
    minNumberOfChords = min(minNumberOfChords, effectiveLength);

    if (availableNotes.length < minNumberOfNotes) {
      return "Not enough notes selected! Please select at least $minNumberOfNotes notes.";
    }
    if (availableChords.length < minNumberOfChords) {
      return "Not enough chords selected! Please select at least $minNumberOfChords chords or set Chord frequency to Never.";
    }

    Random random = Random();

    for (int i = 1; i <= numNotes; i++) {
      if (i == 1 && startWithDo) {
        chordMelody.add(startingDo);
        chordMelodySolfege.add([startingDo]);
      } else if (i == numNotes && endWithDo) {
        chordMelody.add(endingDo);
        chordMelodySolfege.add([endingDo]);
      } else if (chordFrequency != "Never" &&
          ((i + chordStartOffset) %
                  {
                    "Every 4 notes": 4,
                    "Every 3 notes": 3,
                    "Every 2 notes": 2,
                    "Every note": 1,
                  }[chordFrequency]! ==
              0)) {
        // Add a chord
        String selectedChord;
        if (allowRepeatedChords) {
          selectedChord =
              availableChords[random.nextInt(availableChords.length)];
        } else {
          List<String> unusedChords =
              availableChords.where((chord) => chord != previousChord).toList();
          if (unusedChords.isEmpty) {
            return "Not enough unique chords available! Please select more chords or set Chord Frequency to Never.";
          }
          selectedChord = unusedChords[random.nextInt(unusedChords.length)];
          previousChord = selectedChord; // Update previous chord
        }
        chordMelody.add(selectedChord);
        chordMelodySolfege.add(
          List<String>.from(chordMap[selectedChord] ?? []),
        );
      } else {
        // Add a note
        List<String> candidates = [];
        if (i == 2 && startWithDo) {
          if (allowRepeats) {
            candidates = List<String>.from(availableNotes);
          } else {
            candidates =
                availableNotes.where((note) => note != startingDo).toList();
          }
        } else {
          // third or later note of melody: need to check distance from previous note
          var currentNote = chordMelody.isNotEmpty ? chordMelody.last : null;
          if (currentNote is! String && chordMelody.length >= 2) {
            currentNote = chordMelody[chordMelody.length - 2];
          }
          if (allowRepeats) {
            candidates =
                availableNotes.where((note) {
                  if (currentNote == null) return true;
                  return (availableNotes.indexOf(note) -
                              availableNotes.indexOf(currentNote))
                          .abs() <=
                      maxDist;
                }).toList();
          } else if (i == numNotes - 1 && endWithDo) {
            candidates =
                availableNotes.where((note) {
                  if (currentNote == null) return true;
                  return note != currentNote &&
                      note != endingDo &&
                      (availableNotes.indexOf(note) -
                                  availableNotes.indexOf(currentNote))
                              .abs() <=
                          maxDist;
                }).toList();
          } else {
            candidates =
                availableNotes.where((note) {
                  if (currentNote == null) return true;
                  return note != currentNote &&
                      (availableNotes.indexOf(note) -
                                  availableNotes.indexOf(currentNote))
                              .abs() <=
                          maxDist;
                }).toList();
          }
        }
        if (candidates.isEmpty) {
          return "Not enough unique notes available! Please enable repeated notes or select more notes.";
        }
        String nextNote = candidates[random.nextInt(candidates.length)];
        chordMelody.add(nextNote);
        chordMelodySolfege.add([nextNote]);
      }
    }
    return "";
  }
}
