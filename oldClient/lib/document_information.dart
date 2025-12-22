import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:ist_document/helper_functions.dart';
import 'package:ist_document/structures.dart';
import 'package:ist_document/variables.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DocumentInformation extends StatefulWidget {
  final Global global;

  const DocumentInformation(this.global, {super.key});

  @override
  State<DocumentInformation> createState() => StateDocumentInformation();
}

class StateDocumentInformation extends State<DocumentInformation> {
  final _formKey = GlobalKey<FormState>();
  bool error = false;
  bool _EIDReq = true;
  bool _resultFormat = true;
  Uint8List _fileData = Uint8List(0);
  TextEditingController documentNoController = TextEditingController();
  TextEditingController preparedByNameController = TextEditingController();
  TextEditingController reviewedByNameController = TextEditingController();
  TextEditingController reviewedByTitleController = TextEditingController();
  TextEditingController firstApproveNameController = TextEditingController();
  TextEditingController firstApproveTitleController = TextEditingController();
  TextEditingController secondApproveNameController = TextEditingController();
  TextEditingController secondApproveTitleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    sendRequest();
  }

  void sendRequest() async {
    DocumentRequest req = DocumentRequest();
    req.id = widget.global.clientID;
    req.name = widget.global.documentName;
    try {
      final response = await http.post(
        Uri.parse('${widget.global.url}/getDocumentDetails'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(req.toJSON()),
      );

      if (response.statusCode == 200) {
        var documentDetails = DocumentDetails.fromJson(
            jsonDecode(response.body) as Map<String, dynamic>);
        if (documentDetails.ok) {
          documentNoController.text = documentDetails.documentNumber;
          preparedByNameController.text = documentDetails.preparedBy;
          reviewedByNameController.text = documentDetails.reviewedByName;
          reviewedByTitleController.text = documentDetails.reviewedByTitle;
          firstApproveNameController.text = documentDetails.firstApproverName;
          firstApproveTitleController.text = documentDetails.firstApproverTitle;
          secondApproveNameController.text = documentDetails.secondApproverName;
          secondApproveTitleController.text =
              documentDetails.secondApproverTitle;
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

  void addDocumentDetails(BuildContext context) async {
    DocumentDetailsRequest request = DocumentDetailsRequest();
    request.id = widget.global.clientID;
    request.documentName = widget.global.documentName;
    request.documentNumber = documentNoController.text;
    request.preparedBy = preparedByNameController.text;
    request.reviewedByName = reviewedByNameController.text;
    request.reviewedByTitle = reviewedByTitleController.text;
    request.firstApproverName = firstApproveNameController.text;
    request.firstApproverTitle = firstApproveTitleController.text;
    request.secondApproverName = secondApproveNameController.text;
    request.secondApproverTitle = secondApproveTitleController.text;
    try {
      final response = await http.post(
        Uri.parse('${widget.global.url}/addDocumentDetails'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(request.toJSON()),
      );

      if (response.statusCode == 200) {
        var ack =
            Ack.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
        if (ack.ok) {
          HelperFunctions.showMessage("Document Details Added", false);
        } else {
          HelperFunctions.showMessage(ack.msg, true);
        }
      } else {
        HelperFunctions.showMessage("Cannot add Details", true);
      }
    } on Exception {
      HelperFunctions.showMessage("Server Not Available", true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Center(
        child: SizedBox(
          width: 600,
          height: 600,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Flexible(
                    child: ListView(
                      children: [
                        TextFormField(
                          controller: documentNoController,
                          validator: (value) {
                            if ((value == null) || (value.isEmpty)) {
                              return 'Enter Document Number';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            hintText: 'Document Number',
                          ),
                        ),
                        TextFormField(
                          controller: preparedByNameController,
                          validator: (value) {
                            if ((value == null) || (value.isEmpty)) {
                              return 'Prepared By Cannot be empty';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            hintText: 'Prepared By',
                          ),
                        ),
                        TextFormField(
                          controller: reviewedByNameController,
                          validator: (value) {
                            if ((value == null) || (value.isEmpty)) {
                              return 'Reviewed By Cannot be empty';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            hintText: 'Reviewed By Name',
                          ),
                        ),
                        TextFormField(
                          controller: reviewedByTitleController,
                          validator: (value) {
                            if ((value == null) || (value.isEmpty)) {
                              return 'Reviewed By title Cannot be empty';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            hintText: 'Reviewed By Title',
                          ),
                        ),
                        TextFormField(
                          controller: firstApproveNameController,
                          validator: (value) {
                            if ((value == null) || (value.isEmpty)) {
                              return 'First Approver Cannot be empty';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            hintText: 'First Approver Name',
                          ),
                        ),
                        TextFormField(
                          controller: firstApproveTitleController,
                          validator: (value) {
                            if ((value == null) || (value.isEmpty)) {
                              return 'First Approver title Cannot be empty';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            hintText: 'First Approver Title',
                          ),
                        ),
                        TextFormField(
                          controller: secondApproveNameController,
                          validator: (value) {
                            if ((value == null) || (value.isEmpty)) {
                              return 'Second Approver Cannot be empty';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            hintText: 'Second Approver Name',
                          ),
                        ),
                        TextFormField(
                          controller: secondApproveTitleController,
                          validator: (value) {
                            if ((value == null) || (value.isEmpty)) {
                              return 'Second Approver Title Cannot be empty';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            hintText: 'Second Approver Title',
                          ),
                        ),
                      ],
                    ),
                  ),
                  CheckboxListTile(
                    value: _EIDReq,
                    onChanged: (value) {
                      _EIDReq = value ?? true;
                      setState(() {});
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    title: const Text("EID Required"),
                  ),
                  CheckboxListTile(
                    value: _resultFormat,
                    onChanged: (value) {
                      _resultFormat = value ?? true;
                      setState(() {});
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    title: const Text("Result Format Required"),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.open_in_browser),
                        onPressed: () async {
                          FilePickerResult? result =
                              await FilePicker.platform.pickFiles(
                                  type: FileType.image, withData: true);
                          if (result != null) {
                            PlatformFile file = result.files.single;
                            _fileData = file.bytes ?? Uint8List(0);
                            setState(() {});
                          }
                        },
                        label: const Text('Upload Signed Page'),
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.save),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            addDocumentDetails(context);
                          }
                        },
                        label: const Text('Save'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
