import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:ist_document/helper_functions.dart';
import 'package:ist_document/structures.dart';
import 'package:http/http.dart' as http;
import 'package:ist_document/variables.dart';

class AddDocument extends StatefulWidget {
  final Global global;
  final VoidCallback callback;
  final VoidCallback cancelCallback;
  final bool copy;

  const AddDocument(this.global, this.callback, this.cancelCallback, this.copy,
      {super.key});

  @override
  State<AddDocument> createState() => StateAddDocument();
}

class StateAddDocument extends State<AddDocument> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController documentNameController = TextEditingController();

  void sendRequest(String documentName, BuildContext context) async {
    var error = false;
    var message = "";
    DocumentRequest req = DocumentRequest();
    req.id = widget.global.clientID;
    req.name = documentName;
    try {
      final response = await http.post(
        Uri.parse('${widget.global.url}/addDocument'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(req.toJSON()),
      );

      if (response.statusCode == 200) {
        var ack =
            Ack.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
        if (ack.ok) {
          widget.global.documentName = documentName;
          widget.callback();
        } else {
          message = ack.msg;
          error = true;
        }
      } else {
        message = "Cannot Add Document";
        error = true;
      }
    } on Exception catch (e) {
      debugPrint('$e');
      message = "Server Unavailable";
      error = true;
    }
    if (error) {
      HelperFunctions.showMessage(message, error);
    }
  }

  void sendCopyRequest(String documentName, BuildContext context) async {
    var error = false;
    var message = "";
    CopyDocumentRequest req = CopyDocumentRequest();
    req.id = widget.global.clientID;
    req.oldName = widget.global.documentName;
    req.newName = documentName;
    try {
      final response = await http.post(
        Uri.parse('${widget.global.url}/copyDocument'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(req.toJSON()),
      );

      if (response.statusCode == 200) {
        var ack =
            Ack.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
        if (ack.ok) {
          widget.global.documentName = documentName;
          widget.callback();
        } else {
          message = ack.msg;
          error = true;
        }
      } else {
        message = "Cannot Copy Document";
        error = true;
      }
    } on Exception catch (e) {
      debugPrint('$e');
      message = "Server Unavailable";
      error = true;
    }
    if (error) {
      HelperFunctions.showMessage(message, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Center(
        child: SizedBox(
          width: 350,
          height: 200,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextFormField(
                  controller: documentNameController,
                  validator: (value) {
                    if ((value == null) || (value.isEmpty)) {
                      return 'Enter Document Name';
                    }
                    if (value.contains(" ")) {
                      return 'Document Name should be Unique and without Space';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    hintText: 'SatelliteName-SubsystemName-Version',
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            if (widget.copy) {
                              sendCopyRequest(
                                  documentNameController.text, context);
                            } else {
                              sendRequest(documentNameController.text, context);
                            }
                          }
                        },
                        label: (widget.copy)
                            ? const Text("Copy")
                            : const Text('Add'),
                        icon: (widget.copy)
                            ? const Icon(Icons.copy)
                            : const Icon(Icons.add),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          widget.cancelCallback();
                        },
                        label: const Text('Cancel'),
                        icon: const Icon(Icons.cancel_outlined),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
