import 'package:flutter/material.dart';
import 'package:melody_ear_trainer/utils/helper.dart';
import '../providers/general_provider.dart';
import '../providers/mapping_provider.dart';
import '../utils/colors.dart';
import 'melodyPageAbstract.dart';
import '../utils/chordMelody.dart';

abstract class TestPageAbstract extends MelodyPageAbstract {
  const TestPageAbstract({super.key, required super.audioController}) : super();
  // final AudioController audioController;
}

abstract class TestPageAbstractState extends MelodyPageAbstractState {
  int currentRound = 0;
  int correctAnswers = 0;
  int numberOfQuestions = 0;
  int completedQuestions = 0;
  String previousQuestionResultText = "";
  bool testStarted = false;

  Row startTestButton(
    GeneralProvider generalProvider,
    MappingProvider mappingProvider,
    bool setSolfegeText,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colorMap['brightBackground'] ?? Colors.white,
              foregroundColor:
                  colorMap["buttonForegroundColor"] ?? Colors.white,
              padding: const EdgeInsets.all(12.0),
              side: BorderSide(
                color: colorMap["testButtonColor"] ?? Colors.white,
                width: borderWidth,
              ),
            ),
            onPressed: () {
              testStarted = true;
              currentRound = 1;
              correctAnswers = 0;
              completedQuestions = 0;
              previousQuestionResultText =
                  "Question " + currentRound.toString();
              newGenerateChordMelody(
                generalProvider,
                mappingProvider,
                setSolfegeText,
              );
              setState(() {
                setToWaitingForGuess();
              });
              generatedChordMelody.playChordMelody(
                generalProvider.getSelectedInstrument,
                generalProvider,
                mappingProvider,
                widget,
              );
            },
            child: FittedBox(
              fit: BoxFit.fill,
              child: Text("Start test", style: TextStyle(fontSize: 20)),
            ),
          ),
        ),
      ],
    );
  }

  Row startTestButtonSinging(
    GeneralProvider generalProvider,
    MappingProvider mappingProvider,
    bool setSolfegeText,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          child: ElevatedButton(
             style: ElevatedButton.styleFrom(
              backgroundColor: colorMap['brightBackground'] ?? Colors.white,
              foregroundColor:
                  colorMap["buttonForegroundColor"] ?? Colors.white,
              padding: const EdgeInsets.all(12.0),
              side: BorderSide(
                color: colorMap["testButtonColor"] ?? Colors.white,
                width: borderWidth,
              ),
            ),
            onPressed: () {
              testStarted = true;
              currentRound = 1;
              correctAnswers = 0;
              completedQuestions = 0;
              previousQuestionResultText =
                  "Question " + currentRound.toString();
              newGenerateChordMelody(generalProvider, mappingProvider, true);
              //solfegeText = generatedChordMelody.getChordMelody().join(' ');
                  setState(() {});
              ChordMelody fn = ChordMelody.singleChord(
                generatedChordMelody.getFirstNoteOrChord_Melody(),
                generatedChordMelody.getFirstNoteOrChord_Solfege(),
              );
              fn.playChordMelody(
                generalProvider.getSelectedInstrument,
                generalProvider,
                mappingProvider,
                widget,
              );
            },
            child: FittedBox(
              fit: BoxFit.fill,
              child: Text("Start test", style: TextStyle(fontSize: 20)),
            ),
          ),
        ),
      ],
    );
  }

  Row enterGuessbutton(
    GeneralProvider generalProvider,
    MappingProvider mappingProvider,
    bool setSolfegeText,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          child: ElevatedButton.icon(
            icon: Icon(comparisonIcon, color: comparisonIconColor),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorMap['brightBackground'],
              foregroundColor:
                  colorMap["buttonForegroundColor"] ?? Colors.white,
              padding: const EdgeInsets.all(12.0),
              side: BorderSide(
                color: colorMap["waitingForGuessIconColor"] ?? Colors.white,
                width: borderWidth,
              ),
            ),
            label: FittedBox(
              fit: BoxFit.fill,
              child: Text("Enter your guess", style: TextStyle(fontSize: 20)),
            ),
            onPressed: () {
              if (testStarted) {
                // don't do anything if the test hasn't started yet
                setState(() {
                  completedQuestions++;
                  currentRound++;
                  // Compare writtenChordMelody with generated melody
                  melodiesSame = generatedChordMelody.sameAs(
                    userWrittenChordMelody,
                  );
                  if (melodiesSame) {
                    setToCorrectGuess();
                    correctAnswers++;
                    previousQuestionResultText =
                        "Correct! Question " + currentRound.toString();
                  } else {
                    setToIncorrectGuess();
                    previousQuestionResultText =
                        "Incorrect. Question " + currentRound.toString();
                  }
                });
                if (completedQuestions == numberOfQuestions) {
                  // override this method in the implementation
                  finishTest(mappingProvider);
                } else {
                  newGenerateChordMelody(
                    generalProvider,
                    mappingProvider,
                    setSolfegeText,
                  );
                  setState(() {
                    //solfegeText = ""; // Clear solfege area
                    setToWaitingForGuess();
                  });
                  generatedChordMelody.playChordMelody(
                    generalProvider.getSelectedInstrument,
                    generalProvider,
                    mappingProvider,
                    widget,
                  );
                }
              }
            },
          ),
        ),
      ],
    );
  }

  Row reportWhetherCorrect(
    GeneralProvider generalProvider,
    MappingProvider mappingProvider, {
    bool setSolfegeText = true,
  }) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            icon: Icon(
              correctGuessIcon,
              color: colorMap['correctGuessIconColor'] ?? Colors.white,
            ),
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all<Color>(
                colorMap['correctGuessButtonColor'] ?? Colors.white,
              ),
              foregroundColor: WidgetStateProperty.all<Color>(
                colorMap["buttonForegroundColor"] ?? Colors.white,
              ),
              padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                const EdgeInsets.all(12.0),
              ),
            ),
            label: FittedBox(
              fit: BoxFit.fill,
              child: Text("Yes", style: TextStyle(fontSize: 20)),
            ),
            onPressed: () {
              if (testStarted) {
                // don't do anything if the test hasn't started yet
                setState(() {
                  completedQuestions++;
                  currentRound++;
                  correctAnswers++;
                  previousQuestionResultText =
                      "Correct! Question " + currentRound.toString();
                });
                if (completedQuestions == numberOfQuestions) {
                  // override this method in the implementation
                  finishTest(mappingProvider);
                } else {
                  newGenerateChordMelody(
                    generalProvider,
                    mappingProvider,
                    true,
                  );
                  solfegeText = generatedChordMelody.getChordMelody().join(' ');
                  setState(() {});
                  ChordMelody fn = ChordMelody.singleChord(
                    generatedChordMelody.getFirstNoteOrChord_Melody(),
                    generatedChordMelody.getFirstNoteOrChord_Solfege(),
                  );
                  fn.playChordMelody(
                    generalProvider.getSelectedInstrument,
                    generalProvider,
                    mappingProvider,
                    widget,
                  );
                }
              }
            },
          ),
        ),
        horizontalSpacer(),
        Expanded(
          child: ElevatedButton.icon(
            icon: Icon(
              incorrectGuessIcon,
              color: colorMap['incorrectGuessIconColor'] ?? Colors.white,
            ),
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all<Color>(
                colorMap['incorrectGuessButtonColor'] ?? Colors.white,
              ),
              foregroundColor: WidgetStateProperty.all<Color>(
                colorMap["buttonForegroundColor"] ?? Colors.white,
              ),
              padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                const EdgeInsets.all(12.0),
              ),
            ),
            label: FittedBox(
              fit: BoxFit.fill,
              child: Text("No", style: TextStyle(fontSize: 20)),
            ),
            onPressed: () {
              if (testStarted) {
                // don't do anything if the test hasn't started yet
                setState(() {
                  completedQuestions++;
                  currentRound++;
                  correctAnswers;
                  previousQuestionResultText =
                      "Incorrect. Question " + currentRound.toString();
                });
                if (completedQuestions == numberOfQuestions) {
                  // override this method in the implementation
                  finishTest(mappingProvider);
                } else {
                  newGenerateChordMelody(
                    generalProvider,
                    mappingProvider,
                    true,
                  );
                  setState(() {});
                  ChordMelody fn = ChordMelody.singleChord(
                    generatedChordMelody.getFirstNoteOrChord_Melody(),
                    generatedChordMelody.getFirstNoteOrChord_Solfege(),
                  );
                  fn.playChordMelody(
                    generalProvider.getSelectedInstrument,
                    generalProvider,
                    mappingProvider,
                    widget,
                  );
                }
              }
            },
          ),
        ),
      ],
    );
  }

  Row previousQuestionResult() {
    return Row(
      // Solfege Text Area
      children: [
        Expanded(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.9,
            ),
            width: double.infinity,
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(
                color: colorMap["borderColor"] ?? Colors.white,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              previousQuestionResultText,
              style: TextStyle(fontSize: 22),
            ),
          ),
        ),
      ],
    );
  }

  void finishTest(MappingProvider mappingProvider) {
    // override this in the implementation
  }
}
