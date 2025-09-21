import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';
import 'package:melody_ear_trainer/utils/colors.dart';
import 'utils/helper.dart';
//import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:io';

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
      final filename = args.filename;
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
    final args =
        ModalRoute.of(context)!.settings.arguments as CampaignArguments;
    String title = args.title;

    return Scaffold(
      appBar: AppBar(),
      body:
          _loaded
              ? Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  headingRow( title),
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
                          // decide which widget to show based on id
                          var a = node.key!.value as int?;
                          var nodes = json['nodes']!;
                          var nodeValue = nodes.firstWhere(
                            (element) => element['id'] == a,
                          );
                          return rectangleWidget(
                            nodeValue['label'] as String?,
                            nodeValue['info'] as String?,
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

  Widget rectangleWidget(String? title, String? info) {
    String titleText = title ?? 'no title';
    String infoText = info ?? '';
    return InkWell(
      onTap: () {
        print(title);
      },
      child: Container(
        padding: EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          boxShadow: [BoxShadow(color: Colors.blue, spreadRadius: 1)],
        ),
        child: Text(titleText + '\n' + infoText, textAlign: TextAlign.center),
      ),
    );
  }
}
