import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';
import 'package:melody_ear_trainer/main.dart';
import 'package:melody_ear_trainer/utils/colors.dart';
import '../utils/helper.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'mission.dart';
import '../providers/mapping_provider.dart';
import '../providers/general_provider.dart';
import '../providers/theme_provider.dart';
import 'package:provider/provider.dart';

class campaignTree extends StatefulWidget {
  const campaignTree({super.key});

  static const String routeName = '/campaignTree';

  @override
  _campaignTreeState createState() => _campaignTreeState();
}

class _campaignTreeState extends State<campaignTree> {
  // JSON loaded from file (replaces the previous hardcoded `var json`)
  Map<String, dynamic> json = {'nodes': [], 'edges': []};
  bool _loaded = false;
  bool _loading = false;

  // Graph and layout config (made non-final so we can replace when loading)
  Graph graph = Graph()..isTree = true;
  BuchheimWalkerConfiguration builder = BuchheimWalkerConfiguration();

  @override
  void initState() {
    // configure layout
    builder
      ..siblingSeparation = (30)
      ..levelSeparation = (30)
      ..subtreeSeparation = (30)
      ..orientation = (BuchheimWalkerConfiguration.ORIENTATION_TOP_BOTTOM);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // load json once, using filename from the route arguments
    if (!_loaded && !_loading) {
      final args = ModalRoute.of(context)!.settings.arguments as CampaignInfo;
      final filename = args.CampaignFilename;
      _loading = true;
      _loadJsonFromFile(filename);
    }
  }

  Future<void> _loadJsonFromFile(String filename) async {
    final path = 'assets/mapping/$filename';
    final String contents = await rootBundle.loadString(path);
    try {
      final decoded = jsonDecode(contents) as Map<String, dynamic>;
      setState(() {
        json = decoded;
        _buildGraphFromJson();
        _loaded = true;
        _loading = false;
      });
    } catch (e) {
      // If file read fails, fall back to empty graph and log error
      debugPrint('Failed to read $path: $e');
      setState(() {
        json = {'nodes': [], 'edges': []};
        graph = Graph()..isTree = true;
        _loaded = true;
        _loading = false;
      });
    }
  }

  void _buildGraphFromJson() {
    graph = Graph()..isTree = true;
    final edges = json['edges'] ?? [];
    for (var element in edges) {
      final fromNodeId = element['from'];
      final toNodeId = element['to'];
      graph.addEdge(Node.Id(fromNodeId), Node.Id(toNodeId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final campArgs = ModalRoute.of(context)!.settings.arguments as CampaignInfo;
    final mappingProvider = Provider.of<MappingProvider>(context);
    final generalProvider = Provider.of<missionSettingsProvider>(context);
    final Map<String, MissionInfo> missions = mappingProvider.getMissions;
    //final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Melody ear trainer')),
      body:
          _loaded
              ? Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  campaignHeader(campArgs),
                  verticalSpacer(),
                  Expanded(
                    child: InteractiveViewer(
                      constrained: false,
                      boundaryMargin: EdgeInsets.all(100),
                      minScale: 0.01,
                      maxScale: 5.6,
                      child: GraphView(
                        graph: graph,
                        algorithm: BuchheimWalkerAlgorithm(
                          builder,
                          TreeEdgeRenderer(builder),
                        ),
                        paint:
                            Paint()
                              ..color = Colors.white
                              ..strokeWidth = 1
                              ..style = PaintingStyle.stroke,
                        builder: (Node node) {
                          // decide which widget to show based on id and shape
                          var a = node.key!.value as int?;
                          var nodesList = json['nodes'] as List<dynamic>;
                          var nodeValue = nodesList.firstWhere(
                            (element) => element['id'] == a,
                          );
                          // put new code here
                          // nodeValue['unlockedby'] may return a list of missionIDs
                          // and if so ['unlockedbyrelationship'] will be set
                          // to either "AND" or "OR"
                          // if these two values are set, then we need to look up all the
                          // items in the "unlockedby" list in bool objectBox.isMissionPassed(String missionID)
                          // which will produce a true or false result for each missionID
                          // the boolean values should then be combined into one final result
                          // using AND or OR depending on the value of "unlockedbyrelationship"
                          // we pass the result to the widget constructor
                          // if the value is true, then the widget is unlocked and
                          // we use the current code.
                          // if the value is false, the widget is locked, the widget constructor should:
                          // not display the label, just a "Mission Locked"
                          // set the color of the widget to grey
                          // and have no OnPressed reaction

                          // Evaluate unlocked state (optional keys: unlockedby, unlockedbyrelationship)
                          bool unlocked = true;
                          if (!context.watch<ThemeProvider>().unlockall) {
                            if (nodeValue.containsKey('unlockedby')) {
                              try {
                                final raw = nodeValue['unlockedby'];
                                final List<String> unlockedList =
                                    (raw is List)
                                        ? raw.map((e) => e.toString()).toList()
                                        : [raw.toString()];
                                final relationship =
                                    (nodeValue['unlockedbyrelationship'] ??
                                            'AND')
                                        .toString()
                                        .toUpperCase();

                                // Lookup each mission id via global objectBox.isMissionPassed(...) (synchronous)
                                List<bool> results = [];
                                for (final mid in unlockedList) {
                                  bool passed = false;
                                  try {
                                    passed = objectBox.isMissionPassed(mid);
                                  } catch (e) {
                                    // lookup failure -> treat as not passed
                                    debugPrint(
                                      'campaign.dart: isMissionPassed lookup error for "$mid": $e',
                                    );
                                    passed = false;
                                  }
                                  results.add(passed);
                                }
                                if (results.isEmpty) {
                                  unlocked = true;
                                } else if (relationship == 'AND') {
                                  unlocked = results.every((b) => b);
                                } else {
                                  // default OR
                                  unlocked = results.any((b) => b);
                                }
                              } catch (e) {
                                debugPrint(
                                  'campaign.dart: error evaluating unlockedby for node $nodeValue: $e',
                                );
                                unlocked =
                                    true; // fail-open to avoid accidentally hiding content
                              }
                            }
                          }
                          final shape =
                              (nodeValue['shape'] ?? 'Rectangle').toString();
                          final label = nodeValue['label'] as String?;
                          if (shape.toLowerCase() == 'circle') {
                            return circleWidget(label, unlocked);
                          } else {
                            // Rectangle: interactive — push Mission (if unlocked)
                            MissionInfo missionInfo =
                                missions[nodeValue['missionid']]!;
                            return rectangleWidget(
                              context,
                              missionInfo,
                              generalProvider,
                              mappingProvider,
                              unlocked,
                            );
                          }
                        },
                      ),
                    ),
                  ),
                ],
              )
              : Center(child: CircularProgressIndicator()),
    );
  }

  Widget circleWidget(String? title, bool unlocked) {
    String titleText =
        unlocked ? (title ?? 'no title') : 'Pass previous\nmissions first';
    Color fill = unlocked ? Colors.black : Colors.grey;
    return Container(
      width: 100,
      height: 100,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: fill,
        boxShadow: [BoxShadow(color: Colors.blue, spreadRadius: 1)],
      ),
      padding: EdgeInsets.all(8),
      child: Text(
        titleText,
        textAlign: TextAlign.center,
        style: TextStyle(color: unlocked ? Colors.white : Colors.white70),
      ),
    );
  }

  Widget rectangleWidget(
    BuildContext context,
    MissionInfo missionInfo,
    GeneralProvider generalProvider,
    MappingProvider mappingProvider,
    bool unlocked,
  ) {
    if (!unlocked) {
      // Locked appearance: no interaction, greyed out, label "Mission Locked"
      return Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: Colors.grey,
          boxShadow: [BoxShadow(color: Colors.grey.shade700, spreadRadius: 1)],
        ),
        child: Text(
          "Pass previous\nmissions first",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    // Unlocked behaviour (existing code)

    String missionStatus = objectBox.missionStatus(missionInfo.MissionID);
    Color nodeColor = missionLevelStatusColor(missionStatus);

    return InkWell(
      onTap: () {
        MissionSavedSettings? mss = objectBox
            .getMissionSavedSettingsByMissionID(missionInfo.MissionID);
        if (mss != null) {
          generalProvider.setKeyAndInstrument(mss.key, mss.instrument);
        }
        final lastLevel =
            mappingProvider.getLevelsForMission(missionInfo.MissionID).last;
        generalProvider.setNoteSelection(
          selectedKeys: lastLevel.Notes
        );
        // create MissionArguments and navigate to Mission page
        Navigator.pushNamed(context, Mission.routeName, arguments: missionInfo);
      },
      child: Container(
        padding: EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          boxShadow: [BoxShadow(color: nodeColor, spreadRadius: 1)],
        ),
        child: Text(
          "Mission: " +
              missionInfo.MissionName +
              '\nMode: ' +
              missionInfo.MissionMode +
              '\nStatus ' +
              missionStatus,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: colorMap["buttonForegroundColor"] ?? Colors.white,
          ),
        ),
      ),
    );
  }
}
