import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';
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
  var json = {
    'nodes': [
      {'id': 1, 'shape': 'Circle', 'label': 'Start'},
      {'id': 2, 'shape': 'Rectangle', 'label': 'Mission 1', 'info': '3 levels'},
    ],
    'edges': [
      {'from': 1, 'to': 2},
    ],
  };



  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as CampaignArguments;
    String title = args.title;
    String filename = args.filename;
    File file = File('assets/mapping/' + filename);



    return Scaffold(
      appBar: AppBar(),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Text(title),
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
                  // I can decide what widget should be shown here based on the id
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
      ),
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

  final Graph graph = Graph()..isTree = true;
  BuchheimWalkerConfiguration builder = BuchheimWalkerConfiguration();

  @override
  void initState() {
    var edges = json["edges"]!;
    edges.forEach((element) {
      var fromNodeId = element["from"];
      var toNodeId = element["to"];
      graph.addEdge(Node.Id(fromNodeId), Node.Id(toNodeId));
    });

    builder
      ..siblingSeparation = (30)
      ..levelSeparation = (30)
      ..subtreeSeparation = (30)
      ..orientation = (BuchheimWalkerConfiguration.ORIENTATION_TOP_BOTTOM);
    super.initState();
  }
}
