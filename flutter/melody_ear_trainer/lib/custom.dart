import 'package:flutter/material.dart';
import 'utils/colors.dart';
import '../utils/helper.dart';

class CustomFrontPage extends StatefulWidget {
  const CustomFrontPage({super.key});
  @override
  State<CustomFrontPage> createState() => _CustomFrontPageState();
}

class _CustomFrontPageState extends State<CustomFrontPage> {
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
                        color: getModeColor("Melody ID"),
                        child: SizedBox(
                          height: 100,
                          child: Center(
                            child: Text(
                              "Melody ID",
                              style: TextStyle(
                                fontSize: 20,
                                color:
                                    colorMap["noteButtonForegroundColor"] ??
                                    Colors.white,
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
                        color: getModeColor("Melody singing"),
                        child: SizedBox(
                          height: 100,
                          child: Center(
                            child: Text(
                              "Melody singing",
                              style: TextStyle(
                                fontSize: 20,
                                color:
                                    colorMap["noteButtonForegroundColor"] ??
                                    Colors.white,
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
                        color: getModeColor("Chord ID"),
                        child: SizedBox(
                          height: 100,
                          child: Center(
                            child: Text(
                              "Chord ID",
                              style: TextStyle(
                                fontSize: 20,
                                color:
                                    colorMap["noteButtonForegroundColor"] ??
                                    Colors.white,
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
                        color: getModeColor("Chord singing"),
                        child: SizedBox(
                          height: 100,
                          child: Center(
                            child: Text(
                              "Chord singing",
                              style: TextStyle(
                                fontSize: 20,
                                color:
                                    colorMap["noteButtonForegroundColor"] ??
                                    Colors.white,
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
                        color: getModeColor("Chord melody ID"),
                        child: SizedBox(
                          height: 100,
                          child: Center(
                            child: Text(
                              "Chord melody\nID",
                              style: TextStyle(
                                fontSize: 20,
                                color:
                                    colorMap["noteButtonForegroundColor"] ??
                                    Colors.white,
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
                        color: getModeColor("Chord melody singing"),
                        child: SizedBox(
                          height: 100,
                          child: Center(
                            child: Text(
                              "Chord melody\nsinging",
                              style: TextStyle(
                                fontSize: 20,
                                color:
                                    colorMap["noteButtonForegroundColor"] ??
                                    Colors.white,
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
                        color: colorMap["c1f3"],
                        child: SizedBox(
                          height: 60,
                          child: Center(
                            child: Text(
                              "Help",
                              style: TextStyle(
                                fontSize: 20,
                                color:
                                    colorMap["noteButtonForegroundColor"] ??
                                    Colors.white,
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
              verticalSpacer(),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      child: Card(
                        color: colorMap["c6f2"],
                        child: SizedBox(
                          height: 60,
                          child: Center(
                            child: Text(
                              "Back to front page",
                              style: TextStyle(
                                fontSize: 20,
                                color:
                                    colorMap["noteButtonForegroundColor"] ??
                                    Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
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
