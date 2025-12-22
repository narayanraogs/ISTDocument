import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:ist_document/helper_functions.dart';
import 'package:ist_document/structures.dart';
import 'package:ist_document/variables.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SubsystemInformation extends StatefulWidget {
  final Global global;

  const SubsystemInformation(this.global, {super.key});

  @override
  State<SubsystemInformation> createState() => StateSubsystemInformation();
}

class StateSubsystemInformation extends State<SubsystemInformation> {
  final _formKey = GlobalKey<FormState>();
  bool error = false;
  TextEditingController spacecraftClassController = TextEditingController();
  TextEditingController spacecraftNameController = TextEditingController();
  TextEditingController subsystemNameController = TextEditingController();
  Uint8List imageData = Uint8List.fromList([]);

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
        Uri.parse('${widget.global.url}/getSubsystemDetails'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(req.toJSON()),
      );

      if (response.statusCode == 200) {
        var ssDetails = SubsystemDetails.fromJson(
            jsonDecode(response.body) as Map<String, dynamic>);
        if (ssDetails.ok) {
          spacecraftClassController.text = ssDetails.satelliteClass;
          spacecraftNameController.text = ssDetails.satelliteName;
          subsystemNameController.text = ssDetails.subsystemName;
          imageData = base64Decode(ssDetails.satelliteImage);
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

  void addSubsystemDetails(BuildContext context) async {
    SubsystemDetailsRequest request = SubsystemDetailsRequest();
    request.id = widget.global.clientID;
    request.documentName = widget.global.documentName;
    request.satelliteName = spacecraftNameController.text;
    request.satelliteClass = spacecraftClassController.text;
    request.subsystemName = subsystemNameController.text;
    //request.satelliteImage = "data:image/png, ${base64Encode(imageData)}";
    request.satelliteImage = base64Encode(imageData);
    try {
      final response = await http.post(
        Uri.parse('${widget.global.url}/addSubsystemDetails'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(request.toJSON()),
      );

      if (response.statusCode == 200) {
        var ack =
            Ack.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
        if (ack.ok) {
          HelperFunctions.showMessage("Subsystem Details Added", false);
        } else {
          HelperFunctions.showMessage(ack.msg, true);
        }
      } else {
        HelperFunctions.showMessage("Cannot Add Details", true);
      }
    } on Exception catch (e) {
      debugPrint('$e');
      HelperFunctions.showMessage("Server Unavailable", true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Center(
          child: SizedBox(
            height: 600,
            width: 600,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.global.documentName,
                      style: const TextStyle(
                          color: Colors.green,
                          fontSize: 18,
                          fontStyle: FontStyle.normal),
                    ),
                    TextFormField(
                      controller: spacecraftNameController,
                      validator: (value) {
                        if ((value == null) || (value.isEmpty)) {
                          return 'Spacecraft Name Cannot be empty';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        hintText: 'Spacecraft Name',
                      ),
                    ),
                    TextFormField(
                      controller: spacecraftClassController,
                      validator: (value) {
                        if ((value == null) || (value.isEmpty)) {
                          return 'Spacecraft Class Cannot be empty';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        hintText: 'Spacecraft Class',
                      ),
                    ),
                    TextFormField(
                      controller: subsystemNameController,
                      validator: (value) {
                        if ((value == null) || (value.isEmpty)) {
                          return 'Subsystem Name Cannot be empty';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        hintText: 'Subsystem Name',
                      ),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            width: 250,
                            decoration: BoxDecoration(border: Border.all()),
                            child: Image.memory(
                              imageData,
                              errorBuilder: (context, obj, trace) {
                                return const Text("No Image found");
                              },
                            ),
                          ),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.open_in_browser),
                            onPressed: () async {
                              FilePickerResult? result =
                                  await FilePicker.platform.pickFiles(
                                      type: FileType.image, withData: true);
                              if (result != null) {
                                PlatformFile file = result.files.single;
                                imageData = file.bytes ?? Uint8List(0);
                                setState(() {});
                              }
                            },
                            label: const Text('Browse'),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.save),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          addSubsystemDetails(context);
                        }
                      },
                      label: const Text('Save'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
