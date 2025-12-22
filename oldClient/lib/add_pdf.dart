import 'dart:convert';
import 'dart:typed_data';
import 'package:ist_document/helper_functions.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:ist_document/variables.dart';

class AddPdf extends StatefulWidget {
  final Global global;
  final Function(String, String, String, bool, bool) callback;
  final VoidCallback cancel;
  final String? pdfName;
  final String? fileData;
  final String? caption;
  final bool content;
  final int editIndex;
  final bool landscapeAllowed;
  bool? isLandscape = false;

  AddPdf(this.global, this.callback, this.cancel, this.content,
      this.landscapeAllowed,
      {super.key,
      this.fileData,
      this.pdfName,
      this.caption,
      required this.editIndex,
      this.isLandscape});

  @override
  State<AddPdf> createState() => StateAddPdf();
}

class StateAddPdf extends State<AddPdf> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _pdfCaptionController = TextEditingController();
  String _filename = 'Click Browse to upload PDF';
  Uint8List _filedata = Uint8List(0);
  bool _landscape = false;

  @override
  void initState() {
    super.initState();
    _pdfCaptionController.text = widget.pdfName ?? "";
    if (widget.fileData != null) {
      var fd = widget.fileData ?? '';
      _filedata =
          widget.content ? Uint8List.fromList(fd.codeUnits) : base64Decode(fd);
      _filename = widget.pdfName ?? '';
      _pdfCaptionController.text = widget.caption ?? '';
    }
    _landscape = widget.isLandscape ?? false;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    if (widget.content) {
      children.add(
        Flexible(
          child: TextFormField(
            controller: _pdfCaptionController,
            validator: (value) {
              if ((value == null) || (value.isEmpty)) {
                return 'Enter Caption for File';
              }
              return null;
            },
            decoration: const InputDecoration(
              hintText: 'Caption',
            ),
          ),
        ),
      );
    }

    List<Widget> rowChildren = [];
    rowChildren.add(
      Flexible(
        child: ElevatedButton.icon(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              if (widget.content) {
                widget.callback(String.fromCharCodes(_filedata), _filename,
                    _pdfCaptionController.text, widget.content, _landscape);
              } else {
                widget.callback(base64Encode(_filedata), _filename, '',
                    widget.content, _landscape);
              }
            }
          },
          label: const Text("Save"),
          icon: const Icon(Icons.save),
        ),
      ),
    );

    rowChildren.add(
      Flexible(
        child: ElevatedButton.icon(
          onPressed: () {
            widget.cancel();
          },
          label: const Text("Cancel"),
          icon: const Icon(Icons.cancel_outlined),
        ),
      ),
    );
    if (widget.landscapeAllowed) {
      rowChildren.add(
        Flexible(
          child: CheckboxListTile(
            value: _landscape,
            onChanged: (value) {
              _landscape = value ?? false;
              setState(() {});
            },
            controlAffinity: ListTileControlAffinity.leading,
            title: Text("Landscape"),
          ),
        ),
      );
    }
    if (widget.editIndex != -1) {
      rowChildren.add(
        Flexible(
          child: ElevatedButton.icon(
            onPressed: () {
              if (widget.content) {
                HelperFunctions.downloadFile(widget.pdfName!, 'tst',
                    Uint8List.fromList(widget.fileData!.codeUnits));
              } else {
                HelperFunctions.downloadFile(
                    widget.pdfName!, 'pdf', base64Decode(widget.fileData!));
              }
            },
            icon: const Icon(Icons.download),
            label: const Text("Download"),
          ),
        ),
      );
    }

    return Form(
      key: _formKey,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraint) {
          return Column(
            children: [
              SizedBox(
                height: constraint.maxHeight * 0.1,
                width: constraint.maxWidth,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(_filename),
                    ElevatedButton.icon(
                      onPressed: () async {
                        FilePickerResult? result =
                            await FilePicker.platform.pickFiles(
                          type: FileType.any,
                          withData: true,
                        );
                        if (result != null) {
                          PlatformFile pFile = result.files.single;
                          _filename = pFile.name;
                          if ((_filename.toLowerCase().endsWith('pdf') ||
                              _filename.toLowerCase().endsWith('tst'))) {
                            _filedata = pFile.bytes ?? Uint8List(0);
                            setState(() {});
                          }
                        } else {
                          HelperFunctions.showMessage(
                              "Only PDF and TST files supported", true);
                        }
                      },
                      label: const Text("Browse"),
                      icon: const Icon(Icons.open_in_browser),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: constraint.maxHeight * 0.1,
                width: constraint.maxWidth,
                child: Row(
                  children: children,
                ),
              ),
              SizedBox(
                height: constraint.maxHeight * 0.1,
                width: constraint.maxWidth,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: rowChildren,
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
