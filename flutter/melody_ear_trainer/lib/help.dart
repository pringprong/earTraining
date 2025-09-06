import 'package:flutter/material.dart';
import 'package:melody_ear_trainer/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'utils/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HelpPage extends StatefulWidget {
  const HelpPage({super.key});
  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  @override
  Widget build(BuildContext context) {
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
            setState(() {
            });
          },
          child: FittedBox(
            fit: BoxFit.fill,
            child: Text("Reset all settings to default", style: TextStyle(fontSize: 20)),
          ),
        ),
      ],
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
