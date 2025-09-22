import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';
import 'package:melody_ear_trainer/utils/colors.dart';
import '../utils/helper.dart';
//import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:io';
import 'mission.dart';
import '../providers/mapping_provider.dart';
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
      final args =
          ModalRoute.of(context)!.settings.arguments as CampaignArguments;
      final filename = args.CampaignFilename;
      _loading = true;
      _loadJsonFromFile(filename);
    }
  }

  Future<void> _loadJsonFromFile(String filename) async {
    final path = 'assets/mapping/$filename';
    try {
      final contents = await File(path).readAsString();
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
    final campArgs =
        ModalRoute.of(context)!.settings.arguments as CampaignArguments;
    final mappingProvider = Provider.of<MappingProvider>(context);
    final Map<String, Map<String, MissionInfo>> missions =
        mappingProvider.getMissions;

    return Scaffold(
      appBar: AppBar(),
      body:
          _loaded
              ? Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  headingRow(campArgs.CampaignName),
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
                          final shape =
                              (nodeValue['shape'] ?? 'Rectangle').toString();
                          final label = nodeValue['label'] as String?;
                          if (shape.toLowerCase() == 'circle') {
                            return circleWidget(label);
                          } else {
                            // Rectangle: interactive — push Mission
                            MissionInfo missionInfo =
                                missions[campArgs
                                    .CampaignID]![nodeValue['missionid']]!;
                            return rectangleWidget(context, missionInfo);
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

  Widget circleWidget(String? title) {
    String titleText = title ?? 'no title';
    //String infoText = info ?? '';
    return Container(
      width: 100,
      height: 100,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black,
        boxShadow: [BoxShadow(color: Colors.blue, spreadRadius: 1)],
      ),
      padding: EdgeInsets.all(8),
      child: Text(titleText, textAlign: TextAlign.center),
    );
  }

  Widget rectangleWidget(BuildContext context, MissionInfo missionInfo) {
    return InkWell(
      onTap: () {
        // create MissionArguments and navigate to Mission page
        Navigator.pushNamed(context, Mission.routeName, arguments: missionInfo);
      },
      child: Container(
        padding: EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          boxShadow: [BoxShadow(color: Colors.blue, spreadRadius: 1)],
        ),
        child: Text("Mission name: " +
          missionInfo.MissionName + '\nMode: ' + missionInfo.MissionMode,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
