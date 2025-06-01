import 'package:flutter/material.dart';
import 'package:melody_ear_trainer/providers/general_provider.dart';
import 'package:provider/provider.dart';
import 'dart:io';


class GeneralPage extends StatefulWidget {
  const GeneralPage({super.key});


  @override
  State<GeneralPage> createState() => _GeneralPageState();
}

class _GeneralPageState extends State<GeneralPage> {
  List<String> mappingKeys = [];
  List<String> instruments = [];

  @override
  void initState() {
    super.initState();
    loadMappingFiles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('General Settings')),
      body: Center(
        child:
          Column(
            children: [ 
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Select Key:'),
                  ),
                  DropdownButton<String>(
                    hint: Text('Select Key'),
                    value: context.watch<GeneralProvider>().selectedKey,
                    items: mappingKeys.map<DropdownMenuItem<String>>((String value) {
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
                ],
              ),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Select Instrument:'),
                  ),
                  DropdownButton<String>(
                    hint: Text('Select Instrument'),
                    value: context.watch<GeneralProvider>().selectedInstrument,
                    items: instruments.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        context.read<GeneralProvider>().updateSelectedInstrument(instrument: newValue);
                      }
                    },
                  ),
                ],
              ),
            ], // Children of Column
          ),
      ),
    );
  }

  Future<void> loadMappingFiles() async {
    // Load Mapping.txt and populate mappingKeys and instruments
    String mappingData = await File('assets/mapping/Mapping.txt').readAsString();
    List<String> lines = mappingData.split('\n');
    for (String line in lines) {
      List<String> parts = line.split('\t');
      if (parts.isNotEmpty && !mappingKeys.contains(parts[0])) {
        mappingKeys.add(parts[0]);
      }
      if (parts.length > 1 && !instruments.contains(parts[1])) {
        instruments.add(parts[1]);
      }
    }
    setState(() {});
  }
}
