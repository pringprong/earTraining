import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:async';
//import 'package:flutter/scheduler.dart';

void main() {
  runApp(const MelodyEarTrainerApp());
}

class MelodyEarTrainerApp extends StatelessWidget {
  const MelodyEarTrainerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MelodyHomePage(),
    );
  }
}

class MelodyHomePage extends StatefulWidget {
  const MelodyHomePage({super.key});

  @override
  State<MelodyHomePage> createState() => _MelodyHomePageState();
}

class _MelodyHomePageState extends State<MelodyHomePage> {
  final AudioPlayer _player1 = AudioPlayer();
  final AudioPlayer _player2 = AudioPlayer();

  Future<void> _playTwoNotes() async {
    try {
      _player1.setAsset('assets/audio/C-do.mp3');
      _player1.setClip(start: Duration(seconds: 0), end: Duration(seconds: 1));
      _player2.setAsset('assets/audio/C-re.mp3');
      _player2.setClip(start: Duration(seconds: 0), end: Duration(seconds: 1));

      _player1.play();
      // Wait 500ms, then start the second note (overlapping)
      Future.delayed(Duration(milliseconds: 500), () {
        _player2.play();
      });


    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error playing audio: $e')),
      );
    }
  }

  @override
  void dispose() {
    _player1.dispose();
    _player2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Melody Ear Trainer')),
      body: Center(
        child: ElevatedButton(
          onPressed: _playTwoNotes,
          child: const Text('Play C-do then C-re'),
        ),
      ),
    );
  }
}


