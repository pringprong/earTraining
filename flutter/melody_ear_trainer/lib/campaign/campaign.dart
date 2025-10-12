import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';
import 'package:melody_ear_trainer/main.dart';
import 'package:melody_ear_trainer/utils/colors.dart';
import '../utils/helper.dart';
import '../utils/shapes.dart';
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
                          final String missionid =
                              (nodeValue['missionid'] ?? "").toString();
                          MissionInfo? missionInfo =
                              (missionid == "")
                                  ? null
                                  : missions[nodeValue['missionid']]!;
                          final String shape =
                              (missionInfo == null)
                                  ? campaignTreeShapes[""] ?? "circle"
                                  : campaignTreeShapes[missionInfo
                                          .MissionMode] ??
                                      "circle";
                          final double width =
                              (missionInfo == null)
                                  ? campaignTreeWidth[""] ?? 100
                                  : campaignTreeWidth[shape] ??
                                      100;
                          final double height =
                              (missionInfo == null)
                                  ? campaignTreeHeight[""] ?? 100
                                  : campaignTreeHeight[shape] ??
                                      100;
                          if (shape.toLowerCase() == 'circle' ||
                              missionInfo == null) {
                            return circleWidget();
                          }
                          bool unlocked = getUnlocked(missionInfo);
                          Widget internalContainer = internalWidget(
                            missionInfo,
                            unlocked,
                            width,
                            height
                          );
                          if (shape.toLowerCase() == 'diamond') {
                            return myDiamondWidget(
                              missionInfo,
                              context,
                              generalProvider,
                              mappingProvider,
                              internalContainer,
                              unlocked,
                            );
                          } else if (shape.toLowerCase() == 'hexagon') {
                            return myHexagonWidget(
                              missionInfo,
                              context,
                              generalProvider,
                              mappingProvider,
                              internalContainer,
                              unlocked,
                            );
                          } else if (shape.toLowerCase() == 'octagon') {
                            return myOctagonWidget(
                              missionInfo,
                              context,
                              generalProvider,
                              mappingProvider,
                              internalContainer,
                              unlocked,
                            );
                          } else if (shape.toLowerCase() == 'trapezoid') {
                            return myTrapezoidWidget(
                              missionInfo,
                              context,
                              generalProvider,
                              mappingProvider,
                              internalContainer,
                              unlocked,
                            );
                          } else if (shape.toLowerCase() == 'houseshape') {
                            return myHouseShapeWidget(
                              missionInfo,
                              context,
                              generalProvider,
                              mappingProvider,
                              internalContainer,
                              unlocked,
                            );
                          } else if (shape.toLowerCase() == 'starshape') {
                            return myStarShapeWidget(
                              missionInfo,
                              context,
                              generalProvider,
                              mappingProvider,
                              internalContainer,
                              unlocked,
                            );
                          } else {
                            return myRectangleWidget(
                              missionInfo,
                              context,
                              generalProvider,
                              mappingProvider,
                              internalContainer,
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

  bool getUnlocked(MissionInfo missionInfo) {
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
    if (context.watch<ThemeProvider>().unlockall) {
      return true;
    }
    final List<String> unlockedList = missionInfo.getMissionUnlockedBy();
    final relationship = missionInfo.getMissionUnlockedByRelationship();
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
    return unlocked;
  }

  Widget circleWidget() {
    return Container(
      width: 30,
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black,
        boxShadow: [BoxShadow(color: Colors.grey, spreadRadius: 1)],
      ),
    );
  }

  Widget internalWidget(
    MissionInfo missionInfo,
    bool unlocked,
    double width,
    double height,
  ) {
    if (!unlocked) {
      return Container(
        color: colorMap['lockedMissionColor'] ?? Colors.white,
        width: width,
        height: height,
        child: Center(
          child: Text(
            'Pass previous\nmissions first',
            textAlign: TextAlign.center,
            style: TextStyle(color: unlocked ? Colors.white : Colors.white70),
          ),
        ),
      );
    } else {
      String missionStatus = objectBox.getSavedMissionStatus(
        missionInfo.MissionID,
      );
      Color nodeColor = missionLevelStatusColor(missionStatus);
      return Container(
        color: nodeColor,
        width: width,
        height: height,
        child: Center(
          child: Text(
            missionInfo.MissionName,
            //  + '\n' + missionStatus
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colorMap["buttonForegroundColor"] ?? Colors.white,
            ),
          ),
        ),
      );
    }
  }

  Widget myDiamondWidget(
    MissionInfo missionInfo,
    BuildContext context,
    GeneralProvider generalProvider,
    MappingProvider mappingProvider,
    Widget internal,
    bool unlocked,
  ) {
    if (!unlocked) {
      return DiamondWidget(
        child: internal
      );
    } else {
      return InkWell(
        onTap: () {
          resetMissionBeforeMissionPage(
            generalProvider,
            mappingProvider,
            missionInfo,
          );
          Navigator.pushNamed(
            context,
            Mission.routeName,
            arguments: missionInfo,
          );
        },
        child: DiamondWidget(
          child: internal
        ),
      );
    }
  }

  // Widget myDiamondWidgetOld(
  //   BuildContext context,
  //   MissionInfo missionInfo,
  //   GeneralProvider generalProvider,
  //   MappingProvider mappingProvider,
  //   bool unlocked,
  // ) {
  //   String titleText =
  //       unlocked ? (missionInfo.MissionName) : 'Pass previous\nmissions first';
  //   Color fill =
  //       unlocked
  //           ? Colors.black
  //           : colorMap['lockedMissionColor'] ?? Colors.white;
  //   if (!unlocked) {
  //     return DiamondWidget(
  //       child: Container(
  //         color: fill,
  //         width: 200,
  //         height: 100,
  //         child: Center(
  //           child: Text(
  //             titleText,
  //             textAlign: TextAlign.center,
  //             style: TextStyle(color: unlocked ? Colors.white : Colors.white70),
  //           ),
  //         ),
  //       ),
  //     );
  //   } else {
  //     String missionStatus = objectBox.getSavedMissionStatus(
  //       missionInfo.MissionID,
  //     );
  //     Color nodeColor = missionLevelStatusColor(missionStatus);
  //     return InkWell(
  //       onTap: () {
  //         resetMissionBeforeMissionPage(
  //           generalProvider,
  //           mappingProvider,
  //           missionInfo,
  //         );
  //         Navigator.pushNamed(
  //           context,
  //           Mission.routeName,
  //           arguments: missionInfo,
  //         );
  //       },
  //       child: DiamondWidget(
  //         child: Container(
  //           color: nodeColor,
  //           width: 250,
  //           height: 150,
  //           child: Center(
  //             child: Text(
  //               missionInfo.MissionName,
  //               //  + '\n' + missionStatus
  //               textAlign: TextAlign.center,
  //               style: TextStyle(
  //                 color: colorMap["buttonForegroundColor"] ?? Colors.white,
  //               ),
  //             ),
  //           ),
  //         ),
  //       ),
  //     );
  //   }
  // }

  Widget myOctagonWidget(
    MissionInfo missionInfo,
    BuildContext context,
    GeneralProvider generalProvider,
    MappingProvider mappingProvider,
    Widget internal,
    bool unlocked,
  ) {
    if (!unlocked) {
      return OctagonWidget(
        child: internal
      );
    } else {
      return InkWell(
        onTap: () {
          resetMissionBeforeMissionPage(
            generalProvider,
            mappingProvider,
            missionInfo,
          );
          Navigator.pushNamed(
            context,
            Mission.routeName,
            arguments: missionInfo,
          );
        },
        child: OctagonWidget(
          child: internal
        ),
      );
    }
  }

  // Widget myOctagonWidgetOld(
  //   BuildContext context,
  //   MissionInfo missionInfo,
  //   GeneralProvider generalProvider,
  //   MappingProvider mappingProvider,
  //   bool unlocked,
  // ) {
  //   String titleText =
  //       unlocked ? (missionInfo.MissionName) : 'Pass previous\nmissions first';
  //   Color fill =
  //       unlocked
  //           ? Colors.black
  //           : colorMap['lockedMissionColor'] ?? Colors.white;
  //   double mywidth = 200;
  //   double myheight = 80;
  //   if (!unlocked) {
  //     return OctagonWidget(
  //       child: Container(
  //         color: fill,
  //         width: mywidth,
  //         height: myheight,
  //         child: Center(
  //           child: Text(
  //             titleText,
  //             textAlign: TextAlign.center,
  //             style: TextStyle(color: unlocked ? Colors.white : Colors.white70),
  //           ),
  //         ),
  //       ),
  //     );
  //   } else {
  //     String missionStatus = objectBox.getSavedMissionStatus(
  //       missionInfo.MissionID,
  //     );
  //     Color nodeColor = missionLevelStatusColor(missionStatus);
  //     return InkWell(
  //       onTap: () {
  //         resetMissionBeforeMissionPage(
  //           generalProvider,
  //           mappingProvider,
  //           missionInfo,
  //         );
  //         Navigator.pushNamed(
  //           context,
  //           Mission.routeName,
  //           arguments: missionInfo,
  //         );
  //       },
  //       child: OctagonWidget(
  //         child: Container(
  //           color: nodeColor,
  //           width: mywidth,
  //           height: myheight,
  //           child: Center(
  //             child: Text(
  //               missionInfo.MissionName,
  //               //  + '\n' + missionStatus
  //               textAlign: TextAlign.center,
  //               style: TextStyle(
  //                 color: colorMap["buttonForegroundColor"] ?? Colors.white,
  //               ),
  //             ),
  //           ),
  //         ),
  //       ),
  //     );
  //   }
  // }
  Widget myHexagonWidget(
    MissionInfo missionInfo,
    BuildContext context,
    GeneralProvider generalProvider,
    MappingProvider mappingProvider,
    Widget internal,
    bool unlocked,
  ) {
    if (!unlocked) {
      return HexagonWidget(
        child: internal
      );
    } else {
      return InkWell(
        onTap: () {
          resetMissionBeforeMissionPage(
            generalProvider,
            mappingProvider,
            missionInfo,
          );
          Navigator.pushNamed(
            context,
            Mission.routeName,
            arguments: missionInfo,
          );
        },
        child: HexagonWidget(
          child: internal
        ),
      );
    }
  }

  // Widget myHexagonWidget(
  //   BuildContext context,
  //   MissionInfo missionInfo,
  //   GeneralProvider generalProvider,
  //   MappingProvider mappingProvider,
  //   bool unlocked,
  // ) {
  //   String titleText =
  //       unlocked ? (missionInfo.MissionName) : 'Pass previous\nmissions first';
  //   Color fill =
  //       unlocked
  //           ? Colors.black
  //           : colorMap['lockedMissionColor'] ?? Colors.white;
  //   double mywidth = 200;
  //   double myheight = 80;
  //   if (!unlocked) {
  //     return HexagonWidget(
  //       child: Container(
  //         color: fill,
  //         width: mywidth,
  //         height: myheight,
  //         child: Center(
  //           child: Text(
  //             titleText,
  //             textAlign: TextAlign.center,
  //             style: TextStyle(color: unlocked ? Colors.white : Colors.white70),
  //           ),
  //         ),
  //       ),
  //     );
  //   } else {
  //     String missionStatus = objectBox.getSavedMissionStatus(
  //       missionInfo.MissionID,
  //     );
  //     Color nodeColor = missionLevelStatusColor(missionStatus);
  //     return InkWell(
  //       onTap: () {
  //         resetMissionBeforeMissionPage(
  //           generalProvider,
  //           mappingProvider,
  //           missionInfo,
  //         );
  //         Navigator.pushNamed(
  //           context,
  //           Mission.routeName,
  //           arguments: missionInfo,
  //         );
  //       },
  //       child: HexagonWidget(
  //         child: Container(
  //           color: nodeColor,
  //           width: mywidth,
  //           height: myheight,
  //           child: Center(
  //             child: Text(
  //               missionInfo.MissionName,
  //               //  + '\n' + missionStatus
  //               textAlign: TextAlign.center,
  //               style: TextStyle(
  //                 color: colorMap["buttonForegroundColor"] ?? Colors.white,
  //               ),
  //             ),
  //           ),
  //         ),
  //       ),
  //     );
  //   }
  // }

  Widget myTrapezoidWidget(
    MissionInfo missionInfo,
    BuildContext context,
    GeneralProvider generalProvider,
    MappingProvider mappingProvider,
    Widget internal,
    bool unlocked,
  ) {
    if (!unlocked) {
      return TrapezoidWidget(
        child: internal
      );
    } else {
      return InkWell(
        onTap: () {
          resetMissionBeforeMissionPage(
            generalProvider,
            mappingProvider,
            missionInfo,
          );
          Navigator.pushNamed(
            context,
            Mission.routeName,
            arguments: missionInfo,
          );
        },
        child: TrapezoidWidget(
          child: internal
        ),
      );
    }
  }

  // Widget myTrapezoidWidget(
  //   BuildContext context,
  //   MissionInfo missionInfo,
  //   GeneralProvider generalProvider,
  //   MappingProvider mappingProvider,
  //   bool unlocked,
  // ) {
  //   String titleText =
  //       unlocked ? (missionInfo.MissionName) : 'Pass previous\nmissions first';
  //   Color fill =
  //       unlocked
  //           ? Colors.black
  //           : colorMap['lockedMissionColor'] ?? Colors.white;
  //   double mywidth = 200;
  //   double myheight = 80;
  //   if (!unlocked) {
  //     return TrapezoidWidget(
  //       child: Container(
  //         color: fill,
  //         width: mywidth,
  //         height: myheight,
  //         child: Center(
  //           child: Text(
  //             titleText,
  //             textAlign: TextAlign.center,
  //             style: TextStyle(color: unlocked ? Colors.white : Colors.white70),
  //           ),
  //         ),
  //       ),
  //     );
  //   } else {
  //     String missionStatus = objectBox.getSavedMissionStatus(
  //       missionInfo.MissionID,
  //     );
  //     Color nodeColor = missionLevelStatusColor(missionStatus);
  //     return InkWell(
  //       onTap: () {
  //         resetMissionBeforeMissionPage(
  //           generalProvider,
  //           mappingProvider,
  //           missionInfo,
  //         );
  //         Navigator.pushNamed(
  //           context,
  //           Mission.routeName,
  //           arguments: missionInfo,
  //         );
  //       },
  //       child: TrapezoidWidget(
  //         child: Container(
  //           color: nodeColor,
  //           width: mywidth,
  //           height: myheight,
  //           child: Center(
  //             child: Text(
  //               missionInfo.MissionName,
  //               //  + '\n' + missionStatus
  //               textAlign: TextAlign.center,
  //               style: TextStyle(
  //                 color: colorMap["buttonForegroundColor"] ?? Colors.white,
  //               ),
  //             ),
  //           ),
  //         ),
  //       ),
  //     );
  //   }
  // }

  Widget myHouseShapeWidget(
    MissionInfo missionInfo,
    BuildContext context,
    GeneralProvider generalProvider,
    MappingProvider mappingProvider,
    Widget internal,
    bool unlocked,
   ) {
    if (!unlocked) {
      return HouseShapeWidget(
        child: internal
      );
    } else {
      return InkWell(
        onTap: () {
          resetMissionBeforeMissionPage(
            generalProvider,
            mappingProvider,
            missionInfo,
          );
          Navigator.pushNamed(
            context,
            Mission.routeName,
            arguments: missionInfo,
          );
        },
        child: HouseShapeWidget(
          child: internal
        ),
      );
    }
  }

  // Widget myHouseShapeWidget(
  //   BuildContext context,
  //   MissionInfo missionInfo,
  //   GeneralProvider generalProvider,
  //   MappingProvider mappingProvider,
  //   bool unlocked,
  // ) {
  //   String titleText =
  //       unlocked ? (missionInfo.MissionName) : 'Pass previous\nmissions first';
  //   Color fill =
  //       unlocked
  //           ? Colors.black
  //           : colorMap['lockedMissionColor'] ?? Colors.white;
  //   double mywidth = 150;
  //   double myheight = 60;
  //   if (!unlocked) {
  //     return HouseShapeWidget(
  //       child: Container(
  //         color: fill,
  //         width: mywidth,
  //         height: myheight,
  //         child: Center(
  //           child: Text(
  //             titleText,
  //             textAlign: TextAlign.center,
  //             style: TextStyle(color: unlocked ? Colors.white : Colors.white70),
  //           ),
  //         ),
  //       ),
  //     );
  //   } else {
  //     String missionStatus = objectBox.getSavedMissionStatus(
  //       missionInfo.MissionID,
  //     );
  //     Color nodeColor = missionLevelStatusColor(missionStatus);
  //     return InkWell(
  //       onTap: () {
  //         resetMissionBeforeMissionPage(
  //           generalProvider,
  //           mappingProvider,
  //           missionInfo,
  //         );
  //         Navigator.pushNamed(
  //           context,
  //           Mission.routeName,
  //           arguments: missionInfo,
  //         );
  //       },
  //       child: HouseShapeWidget(
  //         child: Container(
  //           color: nodeColor,
  //           width: mywidth,
  //           height: myheight,
  //           child: Center(
  //             child: Text(
  //               missionInfo.MissionName,
  //               //  + '\n' + missionStatus
  //               textAlign: TextAlign.center,
  //               style: TextStyle(
  //                 color: colorMap["buttonForegroundColor"] ?? Colors.white,
  //               ),
  //             ),
  //           ),
  //         ),
  //       ),
  //     );
  //   }
  // }

  Widget myStarShapeWidget(
    MissionInfo missionInfo,
    BuildContext context,
    GeneralProvider generalProvider,
    MappingProvider mappingProvider,
    Widget internal,
    bool unlocked,
  ) {
    if (!unlocked) {
      return StarShapeWidget(
        child: internal
      );
    } else {
      return InkWell(
        onTap: () {
          resetMissionBeforeMissionPage(
            generalProvider,
            mappingProvider,
            missionInfo,
          );
          Navigator.pushNamed(
            context,
            Mission.routeName,
            arguments: missionInfo,
          );
        },
        child: StarShapeWidget(
          child: internal
        ),
      );
    }
  }

  //   Widget myStarShapeWidget(
  //   BuildContext context,
  //   MissionInfo missionInfo,
  //   GeneralProvider generalProvider,
  //   MappingProvider mappingProvider,
  //   bool unlocked,
  // ) {
  //   String titleText =
  //       unlocked ? (missionInfo.MissionName) : 'Pass previous\nmissions first';
  //   Color fill =
  //       unlocked
  //           ? Colors.black
  //           : colorMap['lockedMissionColor'] ?? Colors.white;
  //   double mywidth = 250;
  //   double myheight = 90;
  //   if (!unlocked) {
  //     return StarShapeWidget(
  //       child: Container(
  //         color: fill,
  //         width: mywidth,
  //         height: myheight,
  //         child: Center(
  //           child: Text(
  //             titleText,
  //             textAlign: TextAlign.center,
  //             style: TextStyle(color: unlocked ? Colors.white : Colors.white70),
  //           ),
  //         ),
  //       ),
  //     );
  //   } else {
  //     String missionStatus = objectBox.getSavedMissionStatus(
  //       missionInfo.MissionID,
  //     );
  //     Color nodeColor = missionLevelStatusColor(missionStatus);
  //     return InkWell(
  //       onTap: () {
  //         resetMissionBeforeMissionPage(
  //           generalProvider,
  //           mappingProvider,
  //           missionInfo,
  //         );
  //         Navigator.pushNamed(
  //           context,
  //           Mission.routeName,
  //           arguments: missionInfo,
  //         );
  //       },
  //       child: StarShapeWidget(
  //         child: Container(
  //           color: nodeColor,
  //           width: mywidth,
  //           height: myheight,
  //           child: Center(
  //             child: Text(
  //               missionInfo.MissionName,
  //               //  + '\n' + missionStatus
  //               textAlign: TextAlign.center,
  //               style: TextStyle(
  //                 color: colorMap["buttonForegroundColor"] ?? Colors.white,
  //               ),
  //             ),
  //           ),
  //         ),
  //       ),
  //     );
  //   }
  // }

  Widget myRectangleWidget(
    MissionInfo missionInfo,
    BuildContext context,
    GeneralProvider generalProvider,
    MappingProvider mappingProvider,
    Widget internal,
    bool unlocked,
  ) {
    if (!unlocked) {
      return RectangleWidget(
        child: internal
      );
    } else {
      return InkWell(
        onTap: () {
          resetMissionBeforeMissionPage(
            generalProvider,
            mappingProvider,
            missionInfo,
          );
          Navigator.pushNamed(
            context,
            Mission.routeName,
            arguments: missionInfo,
          );
        },
        child: RectangleWidget(
          child: internal
        ),
      );
    }
  }

  // Widget rectangleWidget(
  //   BuildContext context,
  //   MissionInfo missionInfo,
  //   GeneralProvider generalProvider,
  //   MappingProvider mappingProvider,
  //   bool unlocked,
  // ) {
  //   String titleText =
  //       unlocked ? (missionInfo.MissionName) : 'Pass previous\nmissions first';
  //   Color fill =
  //       unlocked
  //           ? Colors.black
  //           : colorMap['lockedMissionColor'] ?? Colors.white;
  //   double mywidth = 150;
  //   double myheight = 60;
  //   if (!unlocked) {
  //     // Locked appearance: no interaction, greyed out, label "Mission Locked"
  //     return Container(
  //       padding: EdgeInsets.all(8),
  //       width: mywidth,
  //       height: myheight,
  //       decoration: BoxDecoration(
  //         borderRadius: BorderRadius.circular(4),
  //         color: fill,
  //         boxShadow: [BoxShadow(color: fill, spreadRadius: 1)],
  //       ),
  //       child: Center(
  //         child: Text(
  //           titleText,
  //           textAlign: TextAlign.center,
  //           style: TextStyle(color: Colors.white70),
  //         ),
  //       ),
  //     );
  //   }
  //   String missionStatus = objectBox.getSavedMissionStatus(
  //     missionInfo.MissionID,
  //   );
  //   Color nodeColor = missionLevelStatusColor(missionStatus);
  //   return InkWell(
  //     onTap: () {
  //       resetMissionBeforeMissionPage(
  //         generalProvider,
  //         mappingProvider,
  //         missionInfo,
  //       );
  //       Navigator.pushNamed(context, Mission.routeName, arguments: missionInfo);
  //     },
  //     child: Container(
  //       width: mywidth,
  //       height: myheight,
  //       padding: EdgeInsets.all(4),
  //       decoration: BoxDecoration(
  //         borderRadius: BorderRadius.circular(4),
  //         boxShadow: [BoxShadow(color: nodeColor, spreadRadius: 1)],
  //       ),
  //       child: Center(
  //         child: Text(
  //           missionInfo.MissionName,
  //           //  + '\n' + missionStatus
  //           textAlign: TextAlign.center,
  //           style: TextStyle(
  //             color: colorMap["buttonForegroundColor"] ?? Colors.white,
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }
}
