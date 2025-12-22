import 'package:flutter/material.dart';
import 'package:ist_document/helper_functions.dart';
import 'package:ist_document/structures.dart';
import 'package:ist_document/variables.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';

class GeneratePdf extends StatefulWidget {
  final Global global;

  const GeneratePdf(this.global, {super.key});

  @override
  State<GeneratePdf> createState() => StateGeneratePdf();
}

class StateGeneratePdf extends State<GeneratePdf> {
  TextEditingController log = TextEditingController();
  bool busy = false;

  void sendRequest() async {
    log.text = "";
    busy = true;
    setState(() {});
    DocumentRequest req = DocumentRequest();
    req.id = widget.global.clientID;
    req.name = widget.global.documentName;
    try {
      final response = await http.post(
        Uri.parse('${widget.global.url}/compileDocument'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(req.toJSON()),
      );

      if (response.statusCode == 200) {
        var pdf = PDFResponse.fromJson(
            jsonDecode(response.body) as Map<String, dynamic>);
        if (pdf.ok) {
          log.text = "Success";
          HelperFunctions.downloadFile(
              widget.global.documentName, 'pdf', base64Decode(pdf.content));
        } else {
          HelperFunctions.showMessage("Unable to Generate PDF", true);
          log.text = "Failed to generate pdf";
          HelperFunctions.downloadFile(
              widget.global.documentName, 'log', base64Decode(pdf.content));
        }
      } else {
        HelperFunctions.showMessage("Request Error", true);
        log.text = "Request Error";
      }
    } on Exception catch (e) {
      debugPrint('$e');
      HelperFunctions.showMessage("Cannot connect to Server", true);
      log.text = "Cannot connect to server";
    }
    busy = false;
    setState(() {});
  }

  void sendSignRequest() async {
    log.text = "";
    busy = true;
    setState(() {});
    DocumentRequest req = DocumentRequest();
    req.id = widget.global.clientID;
    req.name = widget.global.documentName;
    try {
      final response = await http.post(
        Uri.parse('${widget.global.url}/getSignaturePage'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(req.toJSON()),
      );

      if (response.statusCode == 200) {
        var pdf = PDFResponse.fromJson(
            jsonDecode(response.body) as Map<String, dynamic>);
        if (pdf.ok) {
          log.text = "Success";
          HelperFunctions.downloadFile(
              '${widget.global.documentName}_sign', 'pdf', base64Decode(pdf.content));
        } else {
          HelperFunctions.showMessage("Unable to Generate PDF", true);
          log.text = "Failed to generate pdf";
          HelperFunctions.downloadFile(
              '${widget.global.documentName}_sign', 'log', base64Decode(pdf.content));
        }
      } else {
        HelperFunctions.showMessage("Request Error", true);
        log.text = "Request Error";
      }
    } on Exception catch (e) {
      debugPrint('$e');
      HelperFunctions.showMessage("Cannot connect to Server", true);
      log.text = "Cannot connect to server";
    }
    busy = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 300,
        height: 450,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              onPressed: (busy)
                  ? null
                  : () {
                sendSignRequest();
              },
              label: const Text("Generate Signature Page"),
              icon: const Icon(Icons.pending_actions_outlined),
            ),
            ElevatedButton.icon(
              onPressed: (busy)
                  ? null
                  : () {
                      sendRequest();
                    },
              label: const Text("Generate PDF"),
              icon: const Icon(Icons.download_for_offline_outlined),
            ),
            const Text('Generate Takes 2-3 minutes'),
            SingleChildScrollView(
                child: TextField(
              controller: log,
            ))
          ],
        ),
      ),
    );
  }
}
