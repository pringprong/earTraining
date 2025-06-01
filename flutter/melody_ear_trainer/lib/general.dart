import 'package:flutter/material.dart';
import 'package:melody_ear_trainer/providers/general_provider.dart';
import 'package:provider/provider.dart';

class GeneralPage extends StatefulWidget {
  const GeneralPage({super.key});

  @override
  State<GeneralPage> createState() => _GeneralPageState();
}

class _GeneralPageState extends State<GeneralPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('General Settings')),
      body: Center(
        child:
          Column(
            children: [ 
              DropdownButton<String>(
                hint: Text('Select Key'),
                value: context.watch<GeneralProvider>().selectedKey,
                items: <String>['C', 'D', 'E', 'F', 'G', 'A', 'B']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    context.read<GeneralProvider>().updateSelectedKey(newkey: newValue);
                  }
                },

              ),
            ], // Children of Column
          ),
      ),
    );
  }
}