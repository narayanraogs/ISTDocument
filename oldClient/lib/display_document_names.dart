import 'package:flutter/material.dart';
import 'package:ist_document/helper_functions.dart';
import 'package:ist_document/structures.dart';
import 'package:ist_document/variables.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DisplayDocumentNames extends StatefulWidget {
  final Global global;
  final VoidCallback selectDocumentCallback;
  final VoidCallback addDocumentCallback;
  final VoidCallback copyDocumentCallback;

  const DisplayDocumentNames(this.global, this.selectDocumentCallback,
      this.addDocumentCallback, this.copyDocumentCallback,
      {super.key});

  @override
  State<DisplayDocumentNames> createState() => StateDisplayDocumentNames();
}

class StateDisplayDocumentNames extends State<DisplayDocumentNames> {
  List<String> _allDocuments = [];
  List<String> _documents = [];
  String satNameSelected = '';
  String ssNameSelected = '';
  bool error = false;
  List<bool> selected = [];
  TextEditingController filter = TextEditingController();

  @override
  void initState() {
    super.initState();

    sendRequest();
  }

  void sendRequest() async {
    var url = await HelperFunctions.checkServer(urls);
    debugPrint('returned $url');
    widget.global.url = url;

    ClientID req = ClientID();
    req.id = widget.global.clientID;
    try {
      final response = await http.post(
        Uri.parse('${widget.global.url}/getAllDocumentNames'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(req.toJSON()),
      );

      if (response.statusCode == 200) {
        var docNames = GetAllDocumentsName.fromJson(
            jsonDecode(response.body) as Map<String, dynamic>);
        if (docNames.ok) {
          _allDocuments = docNames.documentNames;
          _documents = _allDocuments
              .where((value) => value.contains(filter.text))
              .toList();
          //  _satFilteredDocuments = _allDocuments.where((value) => value.contains(satFiltered.text));
        } else {
          error = true;
        }
      } else {
        error = true;
      }
    } on Exception catch (e) {
      debugPrint('$e');
      error = true;
    }
    setState(() {});
  }

  void copyDocument() {
    if (widget.global.documentName.isEmpty) {
      HelperFunctions.showMessage("No Document Selected", true);
      return;
    }
    widget.copyDocumentCallback();
  }

  void selectDocument() {
    if (widget.global.documentName.isEmpty) {
      HelperFunctions.showMessage("No Document Selected", true);
      return;
    }
    widget.selectDocumentCallback();
  }

  @override
  Widget build(BuildContext context) {
    List<String> satFilteredDocuments = [];
    satFilteredDocuments = _allDocuments
        .where((value) =>
            value.toLowerCase().contains(satNameSelected.toLowerCase()))
        .toList();

    _documents = satFilteredDocuments
        .where((value) =>
            value.toLowerCase().contains(ssNameSelected.toLowerCase()))
        .toList();

    List<Widget> children = [];
    if (error) {
      Text text = Text(
        "Unable to communicate with Server ${widget.global.url}",
        style: const TextStyle(color: Colors.redAccent),
      );
      children.add(text);
    } else {
      for (int i = 0; i < _documents.length; i++) {
        selected.add(false);
      }
      for (int i = 0; i < _documents.length; i++) {
        ListTile listTile = ListTile(
          title: Text(_documents[i]),
          selected: selected[i],
          selectedColor: Colors.deepPurpleAccent,
          onTap: () {
            for (int i = 0; i < _documents.length; i++) {
              selected[i] = false;
            }
            selected[i] = true;
            widget.global.documentName = _documents[i];
            setState(() {});
          },
        );
        children.add(listTile);
      }
    }

    List<DropdownMenuItem<String>> _satFiltered = [];
    _satFiltered.add(
      DropdownMenuItem(
        child: Text('All Satellites'),
        value: '',
      ),
    );
    List<String> tempSatNames = [];
    for (int i = 0; i < _allDocuments.length; i++) {
      var name = _allDocuments[i];
      var satName = name.split("-")[0];
      if (!tempSatNames.contains(satName)) {
        var temp = DropdownMenuItem<String>(
          child: Text(satName),
          value: satName,
        );
        tempSatNames.add(satName);
        _satFiltered.add(temp);
      }
    }

    List<DropdownMenuItem<String>> _ssFiltered = [];
    _ssFiltered.add(
      DropdownMenuItem(
        child: Text('All SubSystems'),
        value: '',
      ),
    );
    List<String> tempSSNames = [];
    for (int i = 0; i < _allDocuments.length; i++) {
      var name = _allDocuments[i];
      var temp = name.split("-");
      if (temp.length < 2) {
        continue;
      }
      var ssName = name.split("-")[1];
      if (!tempSSNames.contains(ssName)) {
        var temp = DropdownMenuItem<String>(
          child: Text(ssName),
          value: ssName,
        );
        tempSSNames.add(ssName);
        _ssFiltered.add(temp);
      }
    }

    return Center(
      child: SizedBox(
        width: 550,
        height: 600,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    DropdownButton(
                      value: satNameSelected,
                      items: _satFiltered,
                      onChanged: (value) {
                        setState(() {
                          satNameSelected = value ?? 'All';
                        });
                      },
                    ),
                    DropdownButton(
                      value: ssNameSelected,
                      items: _ssFiltered,
                      onChanged: (value) {
                        setState(() {
                          ssNameSelected = value ?? 'All';
                        });
                      },
                    ),
                  ],
                ),
                Expanded(
                  child: ListView(
                    children: children,
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: selectDocument,
                        icon: const Icon(Icons.check_box),
                        label: const Text("Select"),
                      ),
                      ElevatedButton.icon(
                        onPressed: copyDocument,
                        icon: const Icon(Icons.copy),
                        label: const Text("Copy"),
                      ),
                      ElevatedButton.icon(
                        onPressed: widget.addDocumentCallback,
                        icon: const Icon(Icons.add),
                        label: const Text("New"),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
