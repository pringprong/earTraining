//import 'package:flutter/material.dart';
//import 'package:flutter/foundation.dart';
import 'package:melody_ear_trainer/providers/general_provider.dart';
import 'package:melody_ear_trainer/providers/mapping_provider.dart';
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

  ChordMelody.singleChord(String chordName, List<String> chord) {
    chordMelody = [chordName];
    chordMelodySolfege = [chord];
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
    return myListEquals(this.chordMelody, other.getChordMelody());
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

  getFirstNoteOrChord_Melody() {
    if (chordMelody.isNotEmpty) {
      return chordMelody.first;
    }
    return null;
  }

  getFirstNoteOrChord_Solfege() {
    if (chordMelodySolfege.isNotEmpty) {
      return chordMelodySolfege.first;
    }
    return null;
  }

  String generateChordMelody(
    GeneralProvider generalProvider,
    MappingProvider mappingProvider, {
    Set<String> newNotes = const {},
  }) {
    final chordMap = mappingProvider.getChordMap;
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
    List<String> newNotesList = [];
    if (newNotes.isNotEmpty && newNotes.first != "") {
      newNotesList = newNotes.toList();
    }
    int factor = 4;

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
        // Check if startingDo is a note or a chord
        if (mappingProvider.getNoteKeys.contains(startingDo)) {
          chordMelody.add(startingDo);
          chordMelodySolfege.add([startingDo]);
        } else if (mappingProvider.getChordMap.keys.contains(startingDo)) {
          chordMelody.add(startingDo);
          chordMelodySolfege.add(mappingProvider.getChordMap[startingDo] ?? []);
          previousChord = startingDo;
        } else {
          return "Starting note/chord \"$startingDo\" not found in notes or chords.";
        }
      } else if (i == numNotes && endWithDo) {
        // Check if endingDo is a note or a chord
        if (mappingProvider.getNoteKeys.contains(endingDo)) {
          chordMelody.add(endingDo);
          chordMelodySolfege.add([endingDo]);
        } else if (mappingProvider.getChordMap.keys.contains(endingDo)) {
          chordMelody.add(endingDo);
          chordMelodySolfege.add(mappingProvider.getChordMap[endingDo] ?? []);
        } else {
          return "Ending note/chord \"$endingDo\" not found in notes or chords.";
        }
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
        List<String> unusedChords =
            availableChords.where((chord) => chord != previousChord).toList();
        // if we're on the second-last item and endingDo is a chord and allowRepeatedChords
        // is false (which it is in this Else) then we also need to remove endingDo from the list
        // to avoid the situation where endingDo is a repeat  of the secondlast item
        if (i == numNotes - 1 &&
            endWithDo &&
            mappingProvider.getChordMap.keys.contains(endingDo)) {
          unusedChords =
              unusedChords.where((chord) => chord != endingDo).toList();
        }
        if (allowRepeatedChords) {
          // what we want to do here is double or triple the non-repeated chords
          // in the list of available chords
          // so that a repeated chord is possible but not very likely
          List<String> availableChordsForSelection = availableChords;
          availableChordsForSelection.addAll(unusedChords);
          if (availableChords.isNotEmpty && availableChords.length < 5) {
            availableChordsForSelection.addAll(unusedChords);
          }
          selectedChord =
              availableChordsForSelection[random.nextInt(
                availableChordsForSelection.length,
              )];
        } else {
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
            // double or triple the non-repeated notes
            // in the list of available notes
            // so that a repeated note is possible but not very likely
            candidates.addAll(
              availableNotes.where((note) => note != startingDo).toList(),
            );
            if (candidates.isNotEmpty && candidates.length < 8) {
              candidates.addAll(
                availableNotes.where((note) => note != startingDo).toList(),
              );
            }
            if (newNotesList.isNotEmpty) {
              // bias the candidates in favor of the new notes
              int currLength = candidates.length;
              for (int i = 0; i < currLength / factor; i++) {
                candidates.addAll(newNotesList);
              }
            }
          } else {
            candidates =
                availableNotes.where((note) => note != startingDo).toList();
            if (newNotesList.isNotEmpty) {
              // bias the candidates in favor of the new notes
              int currLength = candidates.length;
              for (int i = 0; i < currLength / factor; i++) {
                candidates.addAll(newNotesList);
              }
            }
          }
        } else {
          // third or later note of melody: need to check distance from previous note
          var currentNote = chordMelody.isNotEmpty ? chordMelody.last : null;
          if (currentNote is! String && chordMelody.length >= 2) {
            currentNote = chordMelody[chordMelody.length - 2];
          }
          List<String> nonRepeatedCandidates = [];
          if (i == numNotes - 1 && endWithDo) {
            nonRepeatedCandidates =
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
            nonRepeatedCandidates =
                availableNotes.where((note) {
                  if (currentNote == null) return true;
                  return note != currentNote &&
                      (availableNotes.indexOf(note) -
                                  availableNotes.indexOf(currentNote))
                              .abs() <=
                          maxDist;
                }).toList();
          }
          if (allowRepeats) {
            //what we want to do here is double or triple the non-repeated notes
            // in the list of available notes
            // so that a repeated note is not very likely
            candidates =
                availableNotes.where((note) {
                  if (currentNote == null) return true;
                  return (availableNotes.indexOf(note) -
                              availableNotes.indexOf(currentNote))
                          .abs() <=
                      maxDist;
                }).toList();
            candidates.addAll(nonRepeatedCandidates);
            if (candidates.isNotEmpty && candidates.length < 8) {
              candidates.addAll(nonRepeatedCandidates);
            }
            if (newNotesList.isNotEmpty) {
              // bias the candidates in favor of the new notes
              int currLength = candidates.length;
              int numNewNotes = newNotesList.length;
              for (int i = 0; i < currLength / factor; i++) {
                for (int j = 0; j < numNewNotes; j++) {
                  if (candidates.contains(newNotesList[j])) {
                    candidates.add(newNotesList[j]);
                  }
                }
              }
            }
          } else {
            candidates = nonRepeatedCandidates;
            if (newNotesList.isNotEmpty) {
              // bias the candidates in favor of the new notes
              int currLength = candidates.length;
              int numNewNotes = newNotesList.length;
              for (int i = 0; i < currLength / factor; i++) {
                for (int j = 0; j < numNewNotes; j++) {
                  if (candidates.contains(newNotesList[j])) {
                    candidates.add(newNotesList[j]);
                  }
                }
              }
            }
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

  Future<void> playChordMelody(
    String instrument,
    GeneralProvider generalProvider,
    MappingProvider mappingProvider,
    dynamic widget,
  ) async {
    await widget.audioController.refresh();
    final key = generalProvider.selectedKey;
    final timeBetween = generalProvider.timeBetweenNotes;
    final truncate = generalProvider.truncateNotes;
    final arpeggiateOrder = generalProvider.arpeggiateChordOrder;
    final nestedMapping = mappingProvider.getNestedMapping;
    int i = 0;
    bool arpeggiate = false;
    int arpeggiateDelay = 0;
    if (instrument == "Guitar") {
      arpeggiate = generalProvider.arpeggiateChordDelayGuitar > 0;
      arpeggiateDelay = generalProvider.arpeggiateChordDelayGuitar;
    } else if (instrument == "Piano") {
      arpeggiate = generalProvider.arpeggiateChordDelayPiano > 0;
      arpeggiateDelay = generalProvider.arpeggiateChordDelayPiano;
    } else if (instrument == "Solfege") {
      arpeggiate = generalProvider.arpeggiateChordDelaySolfege > 0;
      arpeggiateDelay = generalProvider.arpeggiateChordDelaySolfege;
    }

    for (var notes in chordMelodySolfege) {
      if (notes.length == 1) {
        final note = notes[0];
        final filename = nestedMapping[key]?[instrument]?[note] ?? '';
        if (filename.isNotEmpty) {
          if (truncate == "None" || truncate == "Never") {
            widget.audioController.playSound("assets/audio/$filename");
          } else {
            widget.audioController.playSoundFade(
              "assets/audio/$filename",
              int.parse(truncate),
              500,
            );
          }
        }
      } else if (notes.length > 1) {
        if (i % 7 == 0) {
          await widget.audioController.refresh();
        }
        List<String> chordNotes = List<String>.from(notes);
        if (arpeggiateOrder == "Descending") {
          chordNotes = chordNotes.reversed.toList();
        } else if (arpeggiateOrder == "Random") {
          chordNotes.shuffle();
        }
        for (var note in chordNotes) {
          final filename = nestedMapping[key]?[instrument]?[note] ?? '';
          if (filename.isNotEmpty) {
            if (truncate == "None" || truncate == "Never") {
              widget.audioController.playSound("assets/audio/$filename");
            } else {
              widget.audioController.playSoundFade(
                "assets/audio/$filename",
                int.parse(truncate),
                500,
              );
            }
          }
          if (arpeggiate) {
            await Future.delayed(Duration(milliseconds: arpeggiateDelay));
          }
        }
      }
      await Future.delayed(Duration(milliseconds: timeBetween));
      i++;
    }
  }

  Future<void> playSpoken(
    GeneralProvider generalProvider,
    MappingProvider mappingProvider,
    dynamic widget,
  ) async {
    await widget.audioController.refresh();
    final timeBetween = generalProvider.timeBetweenNotes;
    final arpeggiate = generalProvider.arpeggiateChordDelaySpoken > 0;
    final arpeggiateDelay = generalProvider.arpeggiateChordDelaySpoken;
    final spokenMapping = mappingProvider.getSpokenMapping;
    int i = 0;
    for (var notes in chordMelodySolfege) {
      if (notes.length == 1) {
        final note = notes[0];
        final filename = spokenMapping[note] ?? '';
        if (filename.isNotEmpty) {
          widget.audioController.playSound("assets/audio/$filename");
        }
      } else if (notes.length > 1) {
        if (i % 7 == 0) {
          await widget.audioController.refresh();
        }
        List<String> chordNotes = List<String>.from(notes);
        for (var note in chordNotes) {
          final filename = spokenMapping[note] ?? '';
          if (filename.isNotEmpty) {
            widget.audioController.playSound("assets/audio/$filename");
          }
          if (arpeggiate) {
            await Future.delayed(Duration(milliseconds: arpeggiateDelay));
          }
        }
      }
      await Future.delayed(Duration(milliseconds: timeBetween));
      i++;
    }
  }
}
