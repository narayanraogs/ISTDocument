import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:ist_document/variables.dart';
import 'package:ist_document/helper_functions.dart';

class AddImage extends StatefulWidget {
  final Global global;
  final Function(Uint8List, String, bool) callback;
  final VoidCallback cancel;
  final Uint8List? data;
  final String? caption;
  final int editIndex;

  bool? isLandscape = false;

  AddImage(this.global, this.callback, this.cancel,
      {super.key, this.data, this.caption, required this.editIndex, this.isLandscape});

  @override
  State<AddImage> createState() => StateAddImage();
}

class StateAddImage extends State<AddImage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController imageCaptionController = TextEditingController();
  Uint8List _fileData = Uint8List(0);
  String _filename = 'Click Browse to upload Image';
  bool _landscape = false;



  @override
  void initState() {
    super.initState();
    imageCaptionController.text = widget.caption ?? "";
    _fileData = widget.data ?? Uint8List(0);
    _landscape = widget.isLandscape ?? false;
  }

  @override
  Widget build(BuildContext context) {
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
                        FilePickerResult? result = await FilePicker.platform
                            .pickFiles(type: FileType.any, withData: true);
                        if (result != null) {
                          PlatformFile pFile = result.files.single;
                          _filename = pFile.name;
                          _fileData = pFile.bytes ?? Uint8List(0);
                          setState(() {});
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
                child : Row(
                  children: [
                    Flexible(
                      child: TextFormField(
                        controller: imageCaptionController,
                        validator: (value) {
                          if ((value == null) || (value.isEmpty)) {
                            return 'Enter Caption for Image';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          hintText: 'Caption',
                        ),
                      ),
                    ),
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
            ],
          ),
          ),
              SizedBox(
                height: constraint.maxHeight * 0.66,
                width: constraint.maxWidth,
                child: Image.memory(
                  _fileData,
                  errorBuilder: (context, obj, trace) {
                    return const Text("Select Image to Preview");
                  },
                ),
              ),
              SizedBox(
                height: constraint.maxHeight * 0.1,
                width: constraint.maxWidth,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          widget.callback(
                              _fileData, imageCaptionController.text, _landscape);
                        }
                      },
                      label: const Text("Save"),
                      icon: const Icon(Icons.save),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        widget.cancel();
                      },
                      label: const Text("Cancel"),
                      icon: const Icon(Icons.cancel_outlined),
                    ),
                    if (widget.editIndex != -1)
                      ElevatedButton.icon(
                          onPressed:() {

                         HelperFunctions.downloadFile(imageCaptionController.text, 'png',_fileData);
                          },
                          icon: const Icon(Icons.download),
                          label: const Text("Download"))
                  ],
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
