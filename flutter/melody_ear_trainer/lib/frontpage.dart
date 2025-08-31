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
                        color:getChordButtonColor("blah_VL_1i"),
                        child: SizedBox(
                          height: 120,
                          child: Center(
                            child: const Text(
                              "Melody ID",
                              style: TextStyle(fontSize: 20,
                                  color: Colors.black),
                            ),
                          ),
                        ),
                      ),
                      onTap: () {
                        Navigator.pushNamed(context, '/melodyID');
                      },
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      child: Card(
                        color:getChordButtonColor("blah_M_1i"),
                        child: SizedBox(
                          height: 120,
                          child: Center(
                            child: const Text(
                              "Melody singing",
                              style: TextStyle(fontSize: 20,
                                  color: Colors.black),
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
              SizedBox(height: 16),
              // Second row
              Row(
                children: [
                  Expanded(
                    child: Card(
                      child: SizedBox(
                        height: 120,
                        child: Center(
                          child: Text(
                            "Chords ID",
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Card(
                      child: SizedBox(
                        height: 120,
                        child: Center(
                          child: Text(
                            "Chords singing",
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              // Third row
              Row(
                children: [
                  Expanded(
                    child: Card(
                      child: SizedBox(
                        height: 120,
                        child: Center(
                          child: Text(
                            "Chord melody ID",
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Card(
                      child: SizedBox(
                        height: 120,
                        child: Center(
                          child: Text(
                            "Chord melody singing",
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              // Fourth row: double-width, half-height
              Row(
                children: [
                  Expanded(
                    child: Card(
                      child: SizedBox(
                        height: 60,
                        child: Center(
                          child: Text(
                            "Progress report",
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              // Fifth row: double-width, half-height
              Row(
                children: [
                  Expanded(
                    child: Card(
                      child: SizedBox(
                        height: 60,
                        child: Center(
                          child: Text("Help", style: TextStyle(fontSize: 20)),
                        ),
                      ),
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
