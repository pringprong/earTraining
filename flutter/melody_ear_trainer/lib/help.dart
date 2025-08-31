import 'package:flutter/material.dart';
import 'package:melody_ear_trainer/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'utils/colors.dart';

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
            ], // Children of Column
          ),
        ),
      ),
    );
  }
}
