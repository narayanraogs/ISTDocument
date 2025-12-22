import 'package:flutter/material.dart';
import 'package:ist_document/variables.dart';

class Introduction extends StatefulWidget {
  final Global global;

  const Introduction(this.global, {super.key});

  @override
  State<Introduction> createState() => StateIntroduction();
}

class StateIntroduction extends State<Introduction> {
  TextEditingController abstractController = TextEditingController();
  List<bool> isExpanded = [];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 7; i++) {
      isExpanded.add(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SizedBox(
        height: 600,
        width: 600,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                widget.global.documentName,
                style: const TextStyle(
                    color: Colors.green, fontSize: 18, fontStyle: FontStyle.normal),
              ),
              ExpansionPanelList(
                expansionCallback: (int index, bool expand) {
                  for (int i = 0; i < isExpanded.length; i++) {
                    isExpanded[i] = false;
                  }
                  isExpanded[index] = expand;
                  setState(() {});
                },
                children: [
                  ExpansionPanel(
                    isExpanded: isExpanded[0],
                    headerBuilder: (context, expanded) {
                      return Center(
                          child: Text(
                        "Abstract",
                        style: Theme.of(context).textTheme.headlineMedium,
                      ));
                    },
                    body: const Text("Autofilled"),
                  ),
                  ExpansionPanel(
                    isExpanded: isExpanded[1],
                    headerBuilder: (context, expanded) {
                      return Center(
                          child: Text(
                        "Acronyms",
                        style: Theme.of(context).textTheme.headlineMedium,
                      ));
                    },
                    body: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text("Upload csv for Acronyms"),
                          ElevatedButton.icon(
                              onPressed: null,
                              icon: const Icon(Icons.browser_updated),
                              label: const Text("Browse")),
                        ],
                      ),
                    ),
                  ),
                  ExpansionPanel(
                    isExpanded: isExpanded[2],
                    headerBuilder: (context, expanded) {
                      return Center(
                        child: Text(
                          "Subsystem Introduction",
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      );
                    },
                    body: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                              onPressed: null,
                              icon: const Icon(Icons.text_increase),
                              label: const Text("Add Text")),
                          ElevatedButton.icon(
                              onPressed: null,
                              icon: const Icon(Icons.image),
                              label: const Text("Add Image")),
                          ElevatedButton.icon(
                              onPressed: null,
                              icon: const Icon(Icons.table_chart),
                              label: const Text("Add Table")),
                        ],
                      ),
                    ),
                  ),
                  ExpansionPanel(
                    isExpanded: isExpanded[3],
                    headerBuilder: (context, expanded) {
                      return Center(
                        child: Text(
                          "Subsystem Specification",
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      );
                    },
                    body: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                              onPressed: null,
                              icon: const Icon(Icons.text_increase),
                              label: const Text("Add Text")),
                          ElevatedButton.icon(
                              onPressed: null,
                              icon: const Icon(Icons.image),
                              label: const Text("Add Image")),
                          ElevatedButton.icon(
                              onPressed: null,
                              icon: const Icon(Icons.table_chart),
                              label: const Text("Add Table")),
                        ],
                      ),
                    ),
                  ),
                  ExpansionPanel(
                    isExpanded: isExpanded[4],
                    headerBuilder: (context, expanded) {
                      return Center(
                          child: Text(
                            "Telecommand",
                            style: Theme.of(context).textTheme.headlineMedium,
                          ));
                    },
                    body: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text("Test"),
                          ElevatedButton.icon(
                              onPressed: null,
                              icon: const Icon(Icons.browser_updated),
                              label: const Text("Browse")),
                        ],
                      ),
                    ),
                  ),
                  ExpansionPanel(
                    isExpanded: isExpanded[5],
                    headerBuilder: (context, expanded) {
                      return Center(
                          child: Text(
                            "Telemetry",
                            style: Theme.of(context).textTheme.headlineMedium,
                          ));
                    },
                    body: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text("Test"),
                          ElevatedButton.icon(
                              onPressed: null,
                              icon: const Icon(Icons.browser_updated),
                              label: const Text("Browse")),
                        ],
                      ),
                    ),
                  ),
                  ExpansionPanel(
                    isExpanded: isExpanded[6],
                    headerBuilder: (context, expanded) {
                      return Center(
                          child: Text(
                            "Pages",
                            style: Theme.of(context).textTheme.headlineMedium,
                          ));
                    },
                    body: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text("Test"),
                          ElevatedButton.icon(
                              onPressed: null,
                              icon: const Icon(Icons.image),
                              label: const Text("Add Image")),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
                Padding(
          padding: const EdgeInsets.all(20.0),
          child: ElevatedButton.icon(
            onPressed: null,
            icon: const Icon(Icons.save),
            label: const Text("Save"),),
                )
            ],
          ),
        ),
      ),
    );
  }
}




/*
Widget build(BuildContext context) {
    return Card(
        child: SizedBox(
      width: 600,
      height: 600,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,

          ExpansionTile(
            title: Text("Specification"),
            children: [Text("Autofilled")],
          ),
          ExpansionTile(
            title: Text("Telecommand"),
            children: [Text("Autofilled")],
          ),
          ExpansionTile(
            title: Text("Telemetry"),
            children: [Text("Autofilled")],
          ),
          ExpansionTile(
            title: Text("Pages"),
            children: [Text("Autofilled")],
          ),
          ElevatedButton.icon(
            onPressed: null,
            icon: const Icon(Icons.save),
            label: const Text("Save"),
          ),
        ],
      ),
    ));
  }
 */
