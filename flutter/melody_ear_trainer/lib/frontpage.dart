import 'package:flutter/material.dart';
import 'utils/colors.dart';

class MelodyFrontPage extends StatefulWidget {
  const MelodyFrontPage({super.key});
  @override
  State<MelodyFrontPage> createState() => _MelodyFrontPageState();
}

class _MelodyFrontPageState extends State<MelodyFrontPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(title: Text('Melody ear trainer')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            children: [
              // First row
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      child: Card(
                        color: c2f4,
                        child: SizedBox(
                          height: 100,
                          child: Center(
                            child: const Text(
                              "Melody ID",
                              style: TextStyle(
                                fontSize: 20,
                                color: buttonForegroundColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                      onTap: () {
                        Navigator.pushNamed(context, '/melodyID');
                      },
                    ),
                  ),
                  horizontalSpacer(),
                  Expanded(
                    child: GestureDetector(
                      child: Card(
                        color: c2f2,
                        child: SizedBox(
                          height: 100,
                          child: Center(
                            child: const Text(
                              "Melody singing",
                              style: TextStyle(
                                fontSize: 20,
                                color: buttonForegroundColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                      onTap: () {
                        Navigator.pushNamed(context, '/melodySinging');
                      },
                    ),
                  ),
                ],
              ),
              verticalSpacer(),
              // Second row
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      child: Card(
                        color: c4f4,
                        child: SizedBox(
                          height: 100,
                          child: Center(
                            child: const Text(
                              "Chord ID",
                              style: TextStyle(
                                fontSize: 20,
                                color: buttonForegroundColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                      onTap: () {
                        Navigator.pushNamed(context, '/chordID');
                      },
                    ),
                  ),
                  horizontalSpacer(),
                  Expanded(
                    child: GestureDetector(
                      child: Card(
                        color: c4f2,
                        child: SizedBox(
                          height: 100,
                          child: Center(
                            child: const Text(
                              "Chord singing",
                              style: TextStyle(
                                fontSize: 20,
                                color: buttonForegroundColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                      onTap: () {
                        Navigator.pushNamed(context, '/chordSinging');
                      },
                    ),
                  ),
                ],
              ),
              verticalSpacer(),
              // Third row
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      child: Card(
                        color: c3f4,
                        child: SizedBox(
                          height: 100,
                          child: Center(
                            child: const Text(
                              "Chord melody\nID",
                              style: TextStyle(
                                fontSize: 20,
                                color: buttonForegroundColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                      onTap: () {
                        Navigator.pushNamed(context, '/chordMelodyID');
                      },
                    ),
                  ),
                  horizontalSpacer(),
                  Expanded(
                    child: GestureDetector(
                      child: Card(
                        color: c3f2,
                        child: SizedBox(
                          height: 100,
                          child: Center(
                            child: const Text(
                              "Chord melody\nsinging",
                              style: TextStyle(
                                fontSize: 20,
                                color: buttonForegroundColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                      onTap: () {
                        Navigator.pushNamed(context, '/chordMelodySinging');
                      },
                    ),
                  ),
                ],
              ),
              verticalSpacer(),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      child: Card(
                        color: c1f4,
                        child: SizedBox(
                          height: 100,
                          child: Center(
                            child: const Text(
                              "Help",
                              style: TextStyle(
                                fontSize: 20,
                                color: buttonForegroundColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                      onTap: () {
                        Navigator.pushNamed(context, '/help');
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
