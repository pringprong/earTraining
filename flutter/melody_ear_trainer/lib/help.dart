import 'package:flutter/material.dart';
import 'package:melody_ear_trainer/providers/theme_provider.dart';
import 'providers/general_provider.dart';
import 'package:provider/provider.dart';
import 'utils/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HelpPage extends StatefulWidget {
  const HelpPage({super.key});
  @override
  State<HelpPage> createState() => _HelpPageState();
}

Widget sectionBox({required Color color, required Widget child}) {
  return Container(
    width: double.infinity,
    decoration: BoxDecoration(
      color: color,

      borderRadius: BorderRadius.circular(12),
    ),
    margin: EdgeInsets.symmetric(vertical: 6),
    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
    child: child,
  );
}

class _HelpPageState extends State<HelpPage> {
  @override
  Widget build(BuildContext context) {
    final melodyIDProvider = Provider.of<MelodyIDSettings>(context);
    final melodySingingProvider = Provider.of<MelodySingingSettings>(context);
    final chordIDProvider = Provider.of<chordIDSettings>(context);
    final chordSingingProvider = Provider.of<chordSingingSettings>(context);
    final chordMelodyIDProvider = Provider.of<chordMelodyIDSettings>(context);
    final chordMelodySingingProvider = Provider.of<chordMelodySingingSettings>(
      context,
    );
    return Scaffold(
      appBar: AppBar(title: Text('Help')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextRow("Display settings"),
              verticalSpacer(),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Light mode:'),
                  ),
                  Checkbox(
                    value: context.watch<ThemeProvider>().darkModeBool,
                    onChanged: (bool? newValue) {
                      if (newValue != null) {
                        context.read<ThemeProvider>().setDarkMode(newValue);
                      }
                    },
                  ),
                ],
              ),
              Row(
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: c2f3,
                      foregroundColor: buttonForegroundColor,
                      padding: const EdgeInsets.all(12.0),
                    ),
                    onPressed: () {
                      deleteAllPreferences();
                      melodyIDProvider.loadSettings();
                      melodySingingProvider.loadSettings();
                      chordIDProvider.loadSettings();
                      chordSingingProvider.loadSettings();
                      chordMelodyIDProvider.loadSettings();
                      chordMelodySingingProvider.loadSettings();
                      setState(() {});
                    },
                    child: FittedBox(
                      fit: BoxFit.fill,
                      child: Text(
                        "Reset all settings to default",
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                ],
              ),
              verticalSpacer(),
              sectionBox(
                color: c1f0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    headingRow("1 Melody Ear Trainer: Overview"),
                    verticalSpacer(),
                    TextRow("1.1 Philosophy"),
                    verticalSpacer(),
                    plainText(
                      "Anyone can learn to identify, play, and sing melodies and chords by ear with enough practice, provided that they mentally stay in the correct key.",
                    ),
                    verticalSpacer(),
                    subHeadingRow("1.1.1 Start and end with the tonic"),
                    verticalSpacer(),
                    plainText(
                      "By default, all melodies and chord progressions in Melody Ear Trainer start and end with the tonic note \"do\" (or the tonic chord I or i) to help you stay mindful of the current key.",
                    ),
                    verticalSpacer(),
                    TextRow("1.2 Notes and solfege"),
                    verticalSpacer(),
                    plainText(
                      "Notes are presented in solfege using Sotorrio for the chromatic notes. All twelve keys are supported. E is the lowest key, from E2 to E5, while D# is the highest, from D#3 to D#6. Both la-based and do-based minor keys are supported.",
                    ),
                    verticalSpacer(),
                    subHeadingRow("1.2.1 Octaves"),
                    verticalSpacer(),
                    plainText(
                      '''Three octaves are available in each key. The notes of the lowest octave are named "do0" to "ti0", the notes of the middle octave are named "do" to "ti", and the notes of the highest octave are named "do1" to "ti1". There is also one more do above "ti1" named "do2".''',
                    ),
                    verticalSpacer(),
                    subHeadingRow("1.2.2 Chords"),
                    verticalSpacer(),
                    plainText(
                      '''The chords have both names and associated solfege. The chord names have three sections:''',
                    ),
                    plainText(
                      '''1. Chord scale degree ("I", "IV", "vi", etc. with upper-case for major chords and lower-case for minor chords),''',
                    ),
                    plainText('''2. Octave "00", "0", nothing, or "1",'''),
                    plainText(
                      '''3. Chord type ("Rt" for root position, "Fir" for first inversion, "Sec" for second inversion, and "Thr" for third inversion of seventh chords).''',
                    ),
                    verticalSpacer(),
                    plainText(
                      '''For example, "I0_Rt" is the tonic major chord in root position in the lowest octave, with associated solfege "do0, mi0, so0".''',
                    ),
                    plainText(
                      '''"IV_Sec" is the major four chord in second inversion in the middle octave, with associated solfege "do1, fa1, la1".''',
                    ),
                    verticalSpacer(),
                    plainText(
                      '''Long press any chord button to reveal the associated solfege of the chord.''',
                    ),
                    verticalSpacer(),
                    TextRow("1.3 Modes"),
                    verticalSpacer(),
                    plainText(
                      '''There are six modes, all of which begin by randomly generating a melody according to the settings for that mode.''',
                    ),
                    verticalSpacer(),
                    subHeadingRow("1.3.1 Melody, Chords, and Chord melody"),
                    verticalSpacer(),
                    plainText(
                      '''There are three types of melody: single notes only ("Melody"), chords only ("Chords"), and both single notes and chords ("Chord melody").''',
                    ),
                    verticalSpacer(),
                    subHeadingRow("1.3.2 ID and Singing"),
                    verticalSpacer(),
                    plainText(
                      '''There are two ways of interacting with the generated melody: listen to the melody first and then identify the notes ("ID"), or look at the notes first, listen to the first note or chord, and then sing the melody ("Singing").''',
                    ),
                  ],
                ),
              ),
              verticalSpacer(),
              sectionBox(
                color: c2f0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    headingRow("2 Melody ID, Chord ID, and Chord melody ID"),
                    verticalSpacer(),
                    TextRow("2.1 ID: Basic play"),
                    verticalSpacer(),
                    subHeadingRow("2.1.1 Generate a melody"),
                    verticalSpacer(),
                    plainText(
                      '''Press "Generate melody", then press "Guitar" or "Piano" to listen to the generated melody.''',
                    ),
                    verticalSpacer(),
                    subHeadingRow("2.1.2 Play the melody using the buttons"),
                    verticalSpacer(),
                    plainText(
                      '''After listening, play back the melody by pressing the corresponding solfege and/or chord buttons. Your guess will appear in the text area below the buttons.''',
                    ),
                    plainText(
                      "Alternatively, you can play the melody on your instrument first and then input your guess using the buttons.",
                    ),
                    verticalSpacer(),
                    subHeadingRow("2.1.3 Compare your guess"),
                    verticalSpacer(),
                    plainText(
                      '''Press "Compare with generated melody" to see if your written guess is correct. The button will turn green and show a checkmark if you are correct; it will turn red and show an "X" if you are incorrect.''',
                    ),
                    verticalSpacer(),
                    plainText(
                      '''If you are incorrect, you can listen as many times as you like until you get it right; use "Clear" and "Backspace" to update your guess.''',
                    ),
                    plainText(
                      '''Use the "Guitar", "Piano", and "Solfege" buttons at the bottom to listen to to the melody you wrote and compare it to the sound of the generated melody.''',
                    ),
                    verticalSpacer(),
                    subHeadingRow("2.1.4 See or listen to the correct answer"),
                    verticalSpacer(),
                    plainText(
                      '''Expand the section "Solfege for generated melody" to see or listen to the correct answer.''',
                    ),
                    verticalSpacer(),
                    TextRow("2.2 ID: Settings"),
                    verticalSpacer(),
                    plainText(
                      '''Press the three horizontal lines (hamburger icon) in the top left corner to open the drawer where you can find a link to the settings page of the current mode.''',
                    ),
                    verticalSpacer(),
                    subHeadingRow("2.2.1 Melody notes"),
                    verticalSpacer(),
                    plainText(
                      '''For "Melody ID" and "Chord Melody ID" modes, you can select which notes are available to be included in the generated melody.''',
                    ),
                    plainText(
                      '''Using the "Scale" and "Octave" dropdowns, you can select some common sets of notes. Absolute beginners to ear training are suggested to set these to "Middle octave" and "Do-re-mi" to start with simple melodies.''',
                    ),
                    plainText(
                      '''You can also manually select or deselect individual notes by pressing the corresponding note buttons.''',
                    ),
                    verticalSpacer(),
                    subHeadingRow("2.2.2 Melody settings"),
                    verticalSpacer(),
                    plainText(
                      '''You can set the length and complexity of the melody.''',
                    ),
                    plainText(
                      '''For "Max distance between adjacent notes", if you set this to a low number, the generated melody will be relatively simple with only small changes in pitch from note to note (depending on which notes are selected). If you set it to a high number (and select more notes), the melody will contain larger leaps in pitch and be more complex.''',
                    ),
                    verticalSpacer(),
                    plainText(
                      '''"Chord melody ID" mode has additional settings for the frequency of chords in the generated melody.''',
                    ),
                    verticalSpacer(),
                    subHeadingRow("2.2.3 Playback settings"),
                    verticalSpacer(),
                    plainText(
                      '''You can select the key, instrument, and playback speed of the melody.''',
                    ),
                    verticalSpacer(),
                    plainText(
                      '''"Chord ID" and "Chord melody ID" modes have additional settings regarding whether to arpeggiate the chords, and if so, how slowly, or alternatively play all the notes of the chord at once (Arpeggiate chord delay 0).''',
                    ),
                    verticalSpacer(),
                    subHeadingRow("2.2.4 Tonic"),
                    verticalSpacer(),
                    plainText(
                      '''In the "Tonic" section, you can select which note or chords will be automatically used as the first and last note of the melody. We strongly recommend keeping these checked as they will help you stay mindful of the current key.''',
                    ),
                    verticalSpacer(),
                    plainText(
                      '''If you are using "la-based minor", you can set the tonic and ending note to "la" instead of "do".''',
                    ),
                    verticalSpacer(),
                    subHeadingRow("2.2.5 Chord settings"),
                    verticalSpacer(),
                    plainText(
                      '''In "Chord ID" and "Chord melody ID" modes, you can select which chords can be included in the generated melody.''',
                    ),
                    plainText(
                      '''There are a lot of chords in existence, and only a small selection are currently catalogued in the app.''',
                    ),
                    plainText(
                      '''Long-press any chord button to see the associated solfege of the chord.''',
                    ),
                    verticalSpacer(),
                    plainText(
                      '''The "Range" dropdown box can be used to select the general octave of the chord sets.''',
                    ),
                    plainText(
                      '''The "Set" dropdown box can be used to select some common sets of chords.''',
                    ),
                    plainText(
                      '''You can also manually select or deselect individual chords by pressing the corresponding chord buttons.''',
                    ),
                    verticalSpacer(),
                    TextRow("2.3 ID: Hands-free"),
                    verticalSpacer(),
                    plainText(
                      '''Press the three horizontal lines (hamburger icon) in the top left corner to open the drawer where you can find a link to the hands-free page of the current mode.''',
                    ),
                    verticalSpacer(),
                    subHeadingRow("2.3.1 Automate your practice"),
                    verticalSpacer(),
                    plainText(
                      '''After you have generated and guessed the solfege of melodies one by one a few times and the settings are suitable for your level, you can practice ear training while walking around, working on something else, or just sitting with your eyes closed.''',
                    ),
                    verticalSpacer(),
                    plainText(
                      '''On the "Hands-free" page, you can generate and play between 5 and 25 melodies in a row without interacting with the app at all.''',
                    ),
                    verticalSpacer(),
                    plainText(
                      '''For each round, the app will automatically generate a melody, play the melody using Guitar, Piano, or both, give you a few seconds to guess the solfege for that melody, and then sing and/or say the solfege to tell you the answer.''',
                    ),
                    plainText(
                      '''There is no option (nor any need) to input your guess using the buttons. Instead, you can sing the solfege out loud, then continue to listen to see if you are correct.''',
                    ),
                    verticalSpacer(),
                    subHeadingRow("2.3.2 Hands-free settings"),
                    verticalSpacer(),
                    plainText(
                      '''Use the dropdowns to select the number of rounds, the number of times the melody is played with an instrument, the number of times the melody is sung in solfege, and the number of times the melody is spoken in solfege.''',
                    ),
                    plainText(
                      '''You can also set the duration of the pauses between each step of a round, and which instrument is used to initially play the melody.''',
                    ),
                    verticalSpacer(),
                    subHeadingRow("2.3.3 Controls"),
                    verticalSpacer(),
                    plainText(
                      '''Press "Start" to start the hands-free practice session.''',
                    ),
                    verticalSpacer(),
                    plainText(
                      '''Press "Stop" to stop the playback of the melody at the end of the currently playing melody. There is no way to stop playback in the middle of a melody; if you press "Stop" repeatedly, each note will be cut short until it stops completely.''',
                    ),
                    verticalSpacer(),
                    subHeadingRow("2.3.4 Solfege"),
                    verticalSpacer(),
                    plainText(
                      '''The text of the solfege will be shown in the text box while the solfege is being sung and spoken.''',
                    ),
                  ],
                ),
              ),
              verticalSpacer(),
              sectionBox(
                color: c3f0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    headingRow(
                      "3 Melody singing, Chord singing, and Chord melody singing",
                    ),
                    verticalSpacer(),
                    TextRow("3.1 Singing: Basic play"),
                    verticalSpacer(),
                    subHeadingRow("3.1.1 Generate a melody"),
                    verticalSpacer(),
                    plainText(
                      '''Press "Generate melody". The solfege text of the generated melody will be shown in the text area.''',
                    ),
                    plainText(
                      '''Optionally you can press "Say the solfege" to say the text of the solfege out loud.''',
                    ),
                    verticalSpacer(),
                    subHeadingRow("3.1.2 Listen to the first note or chord"),
                    verticalSpacer(),
                    plainText(
                      '''Now press the upper "Guitar", "Piano", and/or "Solfege" buttons to listen to the first note or chord of the generated melody to cue the key.''',
                    ),
                    plainText(
                      '''The rest of the melody should be sung relative to the first note or chord.''',
                    ),
                    verticalSpacer(),
                    plainText(
                      '''If "Starting note" is checked in the "Tonic" section of settings, the first note or chord of the melody will always be the tonic "do" or the I/i chord.''',
                    ),
                    verticalSpacer(),
                    subHeadingRow("3.1.3 Sing the melody"),
                    verticalSpacer(),
                    plainText(
                      '''Sing the melody out loud based on the starting note.''',
                    ),
                    verticalSpacer(),
                    subHeadingRow("3.1.4 Listen to the generated melody"),
                    verticalSpacer(),
                    plainText(
                      '''Then press the lower "Guitar", "Piano", and/or "Solfege" buttons to listen to the generated melody.''',
                    ),
                    plainText('''Evaluate whether you sang it correctly.'''),
                    verticalSpacer(),
                    plainText(
                      '''Optionally, you can press the buttons for the notes and chords at the bottom of the page to remind yourself what they sound like.''',
                    ),
                    verticalSpacer(),
                    TextRow('3.2 Singing: Settings'),
                    verticalSpacer(),
                    plainText(
                      '''The settings for "Melody singing", "Chord singing", and "Chord melody singing" modes are the same as those for "Melody ID", "Chord ID", and "Chord melody ID" modes, respectively. See "ID: Settings" above.''',
                    ),
                    verticalSpacer(),
                    plainText(
                      '''Ensure that the selected key, notes, and chords are in your singing range.''',
                    ),
                    plainText(
                      '''Each note of a chord needs to be sung individually, so it is recommended to set "Arpeggiate chord delay" to a relatively high number so that you can hear them individually.''',
                    ),
                    verticalSpacer(),
                    TextRow("3.3 Singing: Hands-free"),
                    verticalSpacer(),
                    plainText(
                      '''Press the three horizontal lines (hamburger icon) in the top left corner to open the drawer where you can find a link to the hands-free page of the current mode.''',
                    ),
                    verticalSpacer(),
                    subHeadingRow("3.3.1 Automate your practice"),
                    verticalSpacer(),
                    plainText(
                      '''After you have generated and sung the solfege of melodies one by one a few times and the settings are suitable for your level, you can practice ear training while walking around, working on something else, or just sitting with your eyes closed.''',
                    ),
                    verticalSpacer(),
                    plainText(
                      '''On the "Hands-free" page, you can generate and sing between 5 and 25 melodies in a row without interacting with the app at all.''',
                    ),
                    verticalSpacer(),
                    plainText(
                      '''For each round, the app will automatically generate a melody, say the solfege of the melody out loud, play the first note or chord, give you some time to sing the melody yourself, and then play the melody in sung solfege and/or an instrument to tell you the answer.''',
                    ),
                    verticalSpacer(),
                    subHeadingRow("3.3.2 Hands-free settings"),
                    verticalSpacer(),
                    plainText(
                      '''Use the dropdowns to select the number of rounds, the number of times the solfege of melody is spoken out loud together with the first note, the number of times the melody is sung in solfege, and the number of times the melody is played on an instrument.''',
                    ),
                    plainText(
                      '''You can also set the duration of the pauses between each step of a round, and which instrument is used to play the melody.''',
                    ),
                    verticalSpacer(),
                    subHeadingRow("3.3.3 Controls"),
                    verticalSpacer(),
                    plainText(
                      '''Press "Start" to start the hands-free practice session.''',
                    ),
                    verticalSpacer(),
                    plainText(
                      '''Press "Stop" to stop the playback of the melody at the end of the currently playing melody. There is no way to stop playback in the middle of a melody; if you press "Stop" repeatedly, each note will be cut short until it stops completely.''',
                    ),
                    verticalSpacer(),
                    subHeadingRow("3.3.4 Solfege"),
                    verticalSpacer(),
                    plainText(
                      '''The text of the solfege will be shown in the text box.''',
                    ),
                  ],
                ),
              ),
              verticalSpacer(),
              sectionBox(
                color: c4f0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    headingRow("4 About"),
                    verticalSpacer(),
                    plainText(
                      "Melody Ear Trainer is a free and open-source app designed to help people improve their musical ear. It can currently be installed on Windows and Android.",
                    ),
                    verticalSpacer(),
                    plainText(
                      "Melody Ear Trainer has no ads, no in-app purchases, no premium version, and no usage tracking.",
                    ),
                    verticalSpacer(),
                    plainText(
                      "It does not access the internet, nor does it use the microphone or require any other permissions.",
                    ),
                    verticalSpacer(),
                    plainText(
                      "The author wrote the app to improve their own musical ear, using a lot of free online resources, and the resulting app is freely shared back to the music community.",
                    ),
                    verticalSpacer(),
                    plainText("Version 2.0.0, 2025"),
                    verticalSpacer(),
              plainText('''Developed by github contributor "pringprong"'''),
                    plainText(
                      "https://github.com/pringprong/earTraining/tree/main/flutter/melody_ear_trainer",
                    ),
                  ],
                ),
              ),
              verticalSpacer(),
              sectionBox(
                color: c5f0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    headingRow("5 Acknowledgements"),
                    verticalSpacer(),
                    plainText(
                      "This app uses the following open-source packages and samples. Samples were extensively modified in terms of format, length, and pitch.",
                    ),
                    plainText("flutter"),
                    plainText("soloud"),
                    plainText("wcgbg/solfege-samples"),
                    plainText("SpanishClassicalGuitar-SFZ-20190618"),
                    plainText("Salamander Grand Piano V3_48khz24bit"),
                  ],
                ),
              ),
            ], // Children of Column
          ),
        ),
      ),
    );
  }

  Future<void> deleteAllPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
