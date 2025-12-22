import 'package:flutter/material.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:ist_document/add_document.dart';
import 'package:ist_document/document_information.dart';
import 'package:ist_document/subsystem_information.dart';
import 'package:ist_document/variables.dart';
import 'package:ist_document/display_document_names.dart';

import 'add_content.dart';
import 'generate_pdf.dart';

class Breadcrumb extends StatelessWidget {
  final List<String> progressBar;
  final List<String> status;

  Breadcrumb({required this.progressBar, required this.status});

  @override
  Widget build(BuildContext context) {
    List<Widget> breadcrumbItems = [];
    int minLength = progressBar.length;
    // progressBar.length < status.length ? progressBar.length : status.length;
    for (int i = 0; i < minLength; i++) {
      Color textColor;
      switch (status[i].toLowerCase()) {
        case 'Not Started':
          textColor = Colors.grey;
        case 'Incomplete':
          textColor = Colors.yellow;
        case 'Complete':
        default:
          textColor = Colors.green;
      }

      breadcrumbItems.add(
        Text(
          progressBar[i],
          style: TextStyle(
            color: textColor,
            decoration:
                i == minLength - 1 ? TextDecoration.none : TextDecoration.none,
          ),
        ),
      );
      if (i == 0) {
        breadcrumbItems.add(const Text(" | "));
      } else {
        breadcrumbItems.add(const Text(" > "));
      }
    }
    return Row(children: breadcrumbItems);
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      title: 'IST Document Creator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'IST Document Creator v 1'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _selectedText = 'Select Document';
  String _mode = "";
  Global global = Global();
  final List<bool> _isExpanded = List<bool>.filled(5, false, growable: false);
  bool _hidden = false;

  void selectDocument() {
    _mode = "Information";
    _selectedText = "Document Information";
    setState(() {});
  }

  void documentList() {
    _mode = "";
    _selectedText = "Select Document";
    setState(() {});
  }

  void addDocument() {
    _mode = "Add";
    _selectedText = "Add Document";
    setState(() {});
  }

  void copyDocument() {
    _mode = "Copy";
    _selectedText = "Copy Document";
    setState(() {});
  }

  Widget getChild() {
    switch (_mode) {
      case "":
        return DisplayDocumentNames(
            global, selectDocument, addDocument, copyDocument);
      case "Information":
        return DocumentInformation(global);
      case "Subsystem":
        return SubsystemInformation(global);
      case "SignedPage":
        var signedpage = AddContent(global, "Information-SignedPage", false, false,
            true, false, false, false, 1,
            key: const Key("signedpage"));
        return signedpage;
      case "Introduction-Acronyms":
        var acronym = AddContent(global, "Introduction-Acronyms", false, true,
            false, false, false, false, 1,
            key: const Key("acronyms"));
        return acronym;
      case "Introduction-SubsystemIntro":
        var info = AddContent(global, "Introduction-SSIntroduction", true, true,
            true, false, false, true, 20,
            key: const Key("introduction"));
        return info;
      case "Introduction-SubsystemSpec":
        var spec = AddContent(global, "Introduction-SSSpecification", true,
            true, true, false, false, true, 20,
            key: const Key("spec"));
        return spec;
      case "Introduction-Telecommand":
        var tc = AddContent(global, "Introduction-Telecommand", true, true,
            false, false, false, true, 5,
            key: const Key("tc"));
        return tc;
      case "Introduction-Telemetry":
        var tm = AddContent(global, "Introduction-Telemetry", true, true, false,
            false, false, true, 5,
            key: const Key("tm"));
        return tm;
      case "Introduction-Pages":
        var pages = AddContent(global, "Introduction-Pages", false, false, true,
            false, false, false, 25,
            key: const Key("pages"));
        return pages;
      case "CheckoutDetails-Interface":
        var checkoutDetails = AddContent(global, "Checkout-Interface", true,
            true, true, false, false, true, 20,
            key: const Key("Interface"));
        return checkoutDetails;
      case "CheckoutDetails-SpecRequirements":
        var checkoutDetails = AddContent(
            global,
            "Checkout-SpecificRequirements",
            true,
            true,
            true,
            true,
            false,
            true,
            20,
            key: const Key("Specific"));
        return checkoutDetails;
      case "CheckoutDetails-SafetyRequirements":
        var checkoutDetails = AddContent(global, "Checkout-SafetyRequirements",
            true, true, true, true, false, true, 20,
            key: const Key("Safety"));
        return checkoutDetails;
      case "CheckoutDetails-TestPhilosophy":
        var checkoutDetails = AddContent(global, "Checkout-TestPhilosophy",
            true, true, true, false, false, true, 20,
            key: const Key("TestPhilosophy"));
        return checkoutDetails;
      case "CheckoutDetails-Clarification":
        var checkoutDetails = AddContent(
            global,
            "Checkout-SubsystemClarifications",
            true,
            false,
            false,
            true,
            false,
            true,
            10,
            key: const Key("Clarification"));
        return checkoutDetails;
      case "TestMatrix":
        var testMatrix = AddContent(
            global, "TestMatrix", false, false, false, true, false, true, 3,
            key: const Key("TestMatrix"));
        return testMatrix;
      case "TestPlan":
        var testPlan = AddContent(
            global, "TestPlans", true, true, false, false, false, true, 20,
            key: const Key("TestPlan"));
        return testPlan;
      case "TestProcedure":
        var testProc = AddContent(global, "TestProcedures", true, false, false,
            false, true, false, 50,
            key: const Key("TestProcedure"));
        return testProc;
      case "Annexure-EID":
        var annexure = AddContent(
            global, "Annexure-EID", true, false, false, true, false, false, 10,
            key: const Key("Annexure-EID"));
        return annexure;
      case "Annexure-TestResults":
        var annexure = AddContent(global, "Annexure-TestResultsFormat", true,
            true, true, true, false, true, 10,
            key: const Key("Annexure-TestRes"));
        return annexure;
      case "Generate":
        var generate = GeneratePdf(global);
        return generate;
      case "Add":
        return AddDocument(global, selectDocument, documentList, false);
      case "Copy":
        return AddDocument(global, selectDocument, documentList, true);
    }
    return const Text("Unknown Mode");
  }

  ExpansionPanel getExpansionPanel(String header, int index, List<String> title,
      List<String> mode, List<String> selected) {
    List<Widget> children = [];
    for (int i = 0; i < mode.length; i++) {
      children.add(
        ListTile(
          title: Text(title[i]),
          onTap: () {
            setState(() {
              _mode = mode[i];
              _selectedText = selected[i];
            });
          },
        ),
      );
    }
    var child = ExpansionPanel(
      isExpanded: _isExpanded[index],
      headerBuilder: (context, expanded) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            header,
            style: const TextStyle(
                color: Colors.black87,
                fontSize: 22,
                fontStyle: FontStyle.normal),
          ),
        );
      },
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
        child: Column(
          children: children,
        ),
      ),
    );
    return child;
  }

  Widget getSideBar(BuildContext context) {
    List<Widget> colChildren = [];
    List<ExpansionPanel> tiles = [];
    if ((_mode.isNotEmpty) && (_mode != "Add")) {
      tiles.add(
        getExpansionPanel(
            "Information",
            0,
            ["Document", "Subsystem", "Signed Page"],
            ["Information", "Subsystem","SignedPage"],
            ["Document Information", "Subsystem Information", "Upload Signed Page"]),
      );

      tiles.add(
        getExpansionPanel("Introduction", 1, [
          "Acronyms",
          "Subsystem Introduction",
          'Subsystem Specification',
          "Telecommand",
          "Telemetry",
          "Pages",
        ], [
          "Introduction-Acronyms",
          "Introduction-SubsystemIntro",
          "Introduction-SubsystemSpec",
          "Introduction-Telecommand",
          "Introduction-Telemetry",
          "Introduction-Pages",
        ], [
          "Acronyms",
          "Subsystem Introduction",
          "Subsystem Specification",
          "Telecommand",
          "Telemetry",
          "Pages",
        ]),
      );

      tiles.add(
        getExpansionPanel(
          "Checkout Details",
          2,
          [
            'Interface',
            'Specific Requirements',
            'Safety Requirements',
            'Test Philosophy',
            'Subsystem Clarification'
          ],
          [
            'CheckoutDetails-Interface',
            'CheckoutDetails-SpecRequirements',
            'CheckoutDetails-SafetyRequirements',
            'CheckoutDetails-TestPhilosophy',
            'CheckoutDetails-Clarification'
          ],
          [
            'Interface',
            'Specific Requirements',
            'Safety Requirements',
            'Test Philosophy',
            'Subsystem Clarification'
          ],
        ),
      );

      tiles.add(
        getExpansionPanel(
          "Test Details",
          3,
          [
            'Test Matrix',
            'Test Plan',
            'Test Procedure',
          ],
          [
            'TestMatrix',
            'TestPlan',
            'TestProcedure',
          ],
          [
            'Test Matrix',
            'Test Plan',
            'Test Procedure',
          ],
        ),
      );

      tiles.add(
        getExpansionPanel(
          "Annexure",
          4,
          [
            'EID Document',
            'Test Results Format',
          ],
          [
            'Annexure-EID',
            'Annexure-TestResults',
          ],
          [
            'EID',
            'Test Results',
          ],
        ),
      );

      colChildren.add(
        ExpansionPanelList(
          expansionCallback: (int index, bool expand) {
            for (int i = 0; i < _isExpanded.length; i++) {
              _isExpanded[i] = false;
            }
            _isExpanded[index] = expand;
            setState(() {});
          },
          children: tiles,
        ),
      );
      colChildren.add(const Divider());
      colChildren.add(
        ListTile(
          title: const Text(
            'Generate PDF',
            style: TextStyle(
                color: Colors.black87,
                fontSize: 22,
                fontStyle: FontStyle.normal),
          ),
          onTap: () {
            setState(() {
              _mode = "Generate";
            });
          },
        ),
      );
      colChildren.add(const Divider());
    }

    colChildren.add(ListTile(
      title: const Text(
        'Document Selector',
        style: TextStyle(
            color: Colors.black87, fontSize: 22, fontStyle: FontStyle.normal),
      ),
      onTap: () {
        documentList();
      },
    ));

    return Column(
      children: colChildren,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('IST Document Generator'),
            Text(_selectedText),
            const Text('SCG'),
          ],
        ),
      ),
      body: Center(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            double firstWidth = constraints.maxWidth * 0.18;
            double secondWidth = constraints.maxWidth * 0.8;
            List<Widget> children = [];
            if (_hidden) {
              secondWidth = constraints.maxWidth;
            }
            if (!_hidden) {
              children.add(
                SizedBox(
                  height: constraints.maxHeight,
                  width: firstWidth,
                  child: SingleChildScrollView(child: getSideBar(context)),
                ),
              );
              children.add(
                const VerticalDivider(),
              );
            }
            children.add(
              SizedBox(
                height: constraints.maxHeight,
                width: secondWidth,
                child: Column(
                  children: [
                    /*SizedBox(
                      height: constraints.maxHeight * 0.1,
                      width: secondWidth,
                      child: Breadcrumb(progressBar: [
                        global.documentName,
                        'Information',
                        'Introduction',
                        'Checkout Details',
                        'Test Details',
                        'Annexure'
                      ], status: const [
                        'Not Started',
                        'Incomplete',
                        'Complete',
                        'Not Started',
                        'Incomplete',
                        'Complete'
                      ]),
                    ),*/
                    SizedBox(
                      height: constraints.maxHeight * 0.9,
                      width: secondWidth,
                      child: Portal(child: getChild()),
                    )
                  ],
                ),
              ),
            );
            return SizedBox(
              height: constraints.maxHeight,
              width: constraints.maxWidth,
              child: Row(
                children: children,
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _hidden = !_hidden;
          });
        },
        tooltip: "Hide/Show Sidebar",
        child: Icon(
          (_hidden) ? Icons.arrow_circle_right : Icons.arrow_circle_left,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }
}
