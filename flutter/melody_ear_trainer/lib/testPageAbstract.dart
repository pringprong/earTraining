import 'package:flutter/material.dart';
//import 'package:melody_ear_trainer/utils/helper.dart';
//import '../audio/audio_controller.dart';
import '../providers/general_provider.dart';
import '../providers/mapping_provider.dart';
import '../utils/colors.dart';
//import '../utils/chordMelody.dart';
import 'melodyPageAbstract.dart';

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
              backgroundColor: c7f3,
              foregroundColor: buttonForegroundColor,
              padding: const EdgeInsets.all(12.0),
            ),
            onPressed: () {
              currentRound++;
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
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all<Color>(comparisonColor),
              foregroundColor: WidgetStateProperty.all<Color>(
                buttonForegroundColor,
              ),
              padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                const EdgeInsets.all(12.0),
              ),
            ),
            label: FittedBox(
              fit: BoxFit.fill,
              child: Text("Enter your guess", style: TextStyle(fontSize: 20)),
            ),
            onPressed: () {
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
                  previousQuestionResultText = "Correct! Next question:";
                } else {
                  setToIncorrectGuess();
                  previousQuestionResultText = "Incorrect. Next question:";
                }
              });
              if (completedQuestions == numberOfQuestions) {
                // override this method in the implementation
                finishTest();
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
        Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.9,
          ),
          width: double.infinity,
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(previousQuestionResultText, style: TextStyle(fontSize: 22)),
        ),
      ],
    );
  }

  void finishTest() {
    // override this in the implementation
  }
}
