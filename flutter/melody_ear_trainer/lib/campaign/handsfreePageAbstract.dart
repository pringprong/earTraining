import 'dart:math';

import 'package:flutter/material.dart';
import 'package:melody_ear_trainer/providers/general_provider.dart';
import 'package:melody_ear_trainer/providers/mapping_provider.dart';
import '../audio/audio_controller.dart';
import '../melodyPageAbstract.dart';
import '../utils/chordMelody.dart';
import '../utils/colors.dart';
import '../utils/helper.dart';
import '../utils/level_config.dart';

/// Abstract base for the hands-free campaign practice pages.
///
/// Owns the shared session state (round counter, pause/running flags, solfege
/// display, alternate-instrument cycling), the Start/Stop controls, the round
/// display, the DB-derived level status, audio cleanup on dispose and the
/// mounted-safe setState override. Concrete pages only implement their
/// per-round playback sequence in [playRound].
///
/// Uses [CampaignLevelArgs] so settings always come from the displayed
/// LevelInfo via [resolveLevelConfig] — the same rule as the practice pages.
abstract class HandsFreePageAbstract extends StatefulWidget {
  const HandsFreePageAbstract({super.key, required this.audioController});
  final AudioController audioController;
}

abstract class HandsFreePageAbstractState<W extends HandsFreePageAbstract>
    extends State<W> with CampaignLevelArgs<W> {
  int currentRound = 0;
  bool notPaused = true;
  bool running = false;
  String solfegeText = "";
  ChordMelody chordMelody = ChordMelody();
  String currentInstrument = "Piano";
  Color startButtonBackgroundColor = colorMap["c3f3"] ?? Colors.white;
  String levelStatus = "";

  /// Same resolution rule as MelodyPageAbstractState.resolveLevelConfig.
  LevelConfig resolveLevelConfig(GeneralProvider generalProvider) {
    final info = levelInfo;
    if (info != null) {
      return LevelConfig.fromLevelInfo(info);
    }
    return LevelConfig.fromProvider(generalProvider);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh the DB-derived status when the page (re)gains visibility,
    // instead of querying ObjectBox on every build.
    if (levelInfo != null) {
      levelStatus = getLevelStatusWithQuery(levelInfo!);
    }
  }

  @override
  void dispose() {
    notPaused = false;
    running = false;
    // Stop this page's sounds without deinitialising the shared audio engine.
    widget.audioController.stopAll();
    super.dispose();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  String getInstrument(String userChoice) {
    if (userChoice == "Alternate") {
      if (currentInstrument == "Guitar") {
        currentInstrument = "Piano"; // Alternate to Piano
        return "Piano"; // Alternate to Piano
      } else if (currentInstrument == "Piano") {
        currentInstrument = "Guitar"; // Alternate to Guitar
        return "Guitar"; // Alternate to Guitar
      }
    } else if (userChoice.isNotEmpty) {
      return userChoice;
    }
    return "Guitar"; // Default to Guitar if no valid choice
  }
  /// Runs `play` up to `repeats` times, waiting `delaySeconds` between plays
  /// and bailing out as soon as the session is paused or disposed.
  Future<void> repeatPlay({
    required int repeats,
    required Future<void> Function() play,
    required int delaySeconds,
  }) async {
    for (int i = 0; i < repeats && notPaused; i++) {
      await play();
      if (!notPaused) return;
      await Future.delayed(Duration(seconds: delaySeconds));
    }
  }

  /// One round of the session. Return false to abort the whole session
  /// (e.g. melody generation failed).
  Future<bool> playRound(
    GeneralProvider melodySettings,
    GeneralProvider roundSettings,
    MappingProvider mappingProvider,
  );

  /// The full session loop: one [playRound] per round until the configured
  /// number of rounds has been played or the session is paused/stopped.
  Future<void> playFunction(
    GeneralProvider melodySettings,
    GeneralProvider roundSettings,
    MappingProvider mappingProvider,
  ) async {
    while (currentRound < roundSettings.getNumberOfRounds && notPaused) {
      final ok = await playRound(
        melodySettings,
        roundSettings,
        mappingProvider,
      );
      if (!ok || !notPaused) break;
    }
    running = false;
    setState(() {
      startButtonBackgroundColor = colorMap["c3f3"] ?? Colors.white;
    });
  }

  Widget startStopButtons({
    required GeneralProvider melodySettings,
    required GeneralProvider roundSettings,
    required MappingProvider mappingProvider,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: startButtonBackgroundColor,
                  foregroundColor:
                      colorMap["buttonForegroundColor"] ?? Colors.white,
                ),
                onPressed: () {
                  if (!running) {
                    setState(() {
                      solfegeText = "";
                      notPaused = true;
                      startButtonBackgroundColor =
                          colorMap["lockedMissionColor"] ?? Colors.white;
                    });
                    running = true;
                    currentRound = 0;
                    chordMelody = ChordMelody();
                    playFunction(
                      melodySettings,
                      roundSettings,
                      mappingProvider,
                    );
                  }
                },
                child: FittedBox(
                  fit: BoxFit.fill,
                  child: Text('Start', style: TextStyle(fontSize: 20)),
                ),
              ),
            ),
          ],
        ),
        verticalSpacer(),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorMap["c5f2"] ?? Colors.white,
                  foregroundColor:
                      colorMap["buttonForegroundColor"] ?? Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    notPaused = false;
                    running = false;
                    startButtonBackgroundColor =
                        colorMap["c3f3"] ?? Colors.white;
                    solfegeText = "";
                    currentRound = 0;
                    widget.audioController.refresh();
                  });
                },
                child: FittedBox(
                  fit: BoxFit.fill,
                  child: Text('Stop', style: TextStyle(fontSize: 20)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget solfegeArea() {
    return Row(
      children: [
        Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.9,
          ),
          width: double.infinity,
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: colorMap["borderColor"] ?? Colors.white),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(solfegeText, style: TextStyle(fontSize: 18)),
        ),
      ],
    );
  }

  Widget currentRoundRow(GeneralProvider roundSettings) {
    return Row(
      children: [
        Text(
          min(currentRound + 1, roundSettings.getNumberOfRounds).toString() +
              " / " +
              roundSettings.getNumberOfRounds.toString(),
          style: TextStyle(fontSize: 18),
        ),
      ],
    );
  }

  /// A labelled settings row. `value` is typically provided with
  /// `context.select` so only genuine value changes rebuild the page.
  Widget settingsDropdownRow<T>({
    required String label,
    required T value,
    required List<T> items,
    required void Function(T newValue) onChanged,
  }) {
    return Row(
      children: [
        Padding(padding: const EdgeInsets.all(8.0), child: Text(label)),
        DropdownButton<T>(
          value: value,
          items:
              items
                  .map<DropdownMenuItem<T>>(
                    (T itemValue) => DropdownMenuItem<T>(
                      value: itemValue,
                      child: Text(itemValue.toString()),
                    ),
                  )
                  .toList(),
          onChanged: (T? newValue) {
            if (newValue != null) {
              onChanged(newValue);
            }
          },
        ),
      ],
    );
  }

  Widget returnToLevelButton(String levelStatus) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colorMap['darkBackground'] ?? Colors.white,
              foregroundColor:
                  colorMap["noteButtonForegroundColor"] ?? Colors.white,
              padding: const EdgeInsets.all(12.0),
              side: BorderSide(
                color: missionLevelStatusColor(levelStatus),
                width: borderWidth,
              ),
            ),
            onPressed: () {
              Navigator.pop(context); // pop to level page
            },
            child: FittedBox(
              fit: BoxFit.fill,
              child: Text(
                "Return to level main page",
                style: TextStyle(fontSize: 20),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

