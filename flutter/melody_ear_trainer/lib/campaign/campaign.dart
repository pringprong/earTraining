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
                      constrained: true,
                      boundaryMargin: EdgeInsets.all(5.0),
                      minScale: 0.01,
                      maxScale: 5.6,
                      child: GraphView.builder(
                        graph: graph,
                        algorithm: BuchheimWalkerAlgorithm(
                          builder,
                          TreeEdgeRenderer(builder),
                        ),
                        initialNode: ValueKey(1),
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
                          return myClipWidget(
                            missionInfo,
                            context,
                            generalProvider,
                            mappingProvider,
                          );
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

  getPath(String shape) {
    if (shape == "rectangle") {
      return RectangleClipper();
    } else if (shape == "houseshape") {
      return HouseShapeClipper();
    } else if (shape == "hexagon") {
      return HexagonClipper();
    } else if (shape == "trapezoid") {
      return TrapezoidClipper();
    } else if (shape == "octagon") {
      return OctagonClipper();
    } else if (shape == "diamond") {
      return DiamondClipper();
    } else if (shape == "starshape") {
      return StarShapeClipper();
    } else if (shape == "houseshape") {
      return HouseShapeClipper();
    } else {
      return RectangleClipper();
    }
  }

  getWidget(Widget myContainer, String shape) {
    switch (shape) {
      case "rectangle":
        return RectangleWidget(child: myContainer);
      case "houseshape":
        return HouseShapeWidget(child: myContainer);
      case "hexagon":
        return HexagonWidget(child: myContainer);
      case "trapezoid":
        return TrapezoidWidget(child: myContainer);
      case "octagon":
        return OctagonWidget(child: myContainer);
      case "diamond":
        return DiamondWidget(child: myContainer);
      case "starshape":
        return StarShapeWidget(child: myContainer);
      default:
        return RectangleWidget(child: myContainer);
    }
  }

  Widget myClipWidget(
    MissionInfo? missionInfo,
    BuildContext context,
    GeneralProvider generalProvider,
    MappingProvider mappingProvider,
  ) {
    final String shape =
        (missionInfo == null)
            ? campaignTreeShapes[""] ?? "circle"
            : campaignTreeShapes[missionInfo.MissionMode] ?? "circle";
    final double width =
        (missionInfo == null)
            ? campaignTreeWidth[""] ?? 100
            : campaignTreeWidth[shape] ?? 100;
    final double height =
        (missionInfo == null)
            ? campaignTreeHeight[""] ?? 100
            : campaignTreeHeight[shape] ?? 100;
    if (shape.toLowerCase() == 'circle' || missionInfo == null) {
      return circleWidget();
    }
    bool unlocked = getUnlocked(missionInfo);
    Color widgetColor = colorMap['darkBackground'] ?? Colors.white;
    Color borderColor = colorMap['lockedMissionColor'] ?? Colors.white;
    Widget myText = Text(
      'Pass previous\nmissions first',
      textAlign: TextAlign.center,
      style: TextStyle(color: Colors.white, fontSize: 16),
    );
    if (unlocked) {
      String missionStatus = objectBox.getSavedMissionStatus(
        missionInfo.MissionID,
      );
      borderColor = missionLevelStatusColor(missionStatus);
      myText = Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          missionInfo.MissionName,
          //  + '\n' + missionStatus
          textAlign: TextAlign.center,
          style: TextStyle(
            color: colorMap["buttonForegroundColor"] ?? Colors.white, fontSize: 16
          ),
        ),
      );
      widgetColor = colorMap['brightBackground'] ?? Colors.white;
    }
    dynamic myPath = getPath(shape);
    BorderPainter bp = BorderPainter(
      borderColor: borderColor,
      borderWidth: 10.0,
      path: myPath.getClip(Size(width, height)),
    );
    Container myContainer = Container(
      color: widgetColor,
      width: width,
      height: height,
      child: CustomPaint(painter: bp, child: Center(child: myText)),
    );
    if (!unlocked) {
      return getWidget(myContainer, shape);
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
        child: getWidget(myContainer, shape),
      );
    }
  }
}
