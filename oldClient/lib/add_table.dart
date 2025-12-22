import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:ist_document/helper_functions.dart';
import 'package:ist_document/variables.dart';

class AddTable extends StatefulWidget {
  final Global global;
  final Function(String, String, bool) callback;
  final VoidCallback cancel;
  final String? tableName;
  final String? filedata;
  final int editIndex;
  bool? isLandscape = false;

  AddTable(this.global, this.callback, this.cancel,
      {super.key,
      this.filedata,
      this.tableName,
      required this.editIndex,
      this.isLandscape});

  @override
  State<AddTable> createState() => StateAddTable();
}

class StateAddTable extends State<AddTable> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController tablePathController = TextEditingController();
  TextEditingController tableCaptionController = TextEditingController();
  String _fileData = '';
  String _filename = 'Click Browse to upload CSV File';
  List<DataColumn> _columns = [];
  List<DataRow> _rows = [];
  bool _landscape = false;
  bool _isMenuOpen = false;

  @override
  void initState() {
    super.initState();
    _columns.add(
      const DataColumn(
        label: Text('Preview'),
      ),
    );
    if ((widget.filedata != null) && (widget.filedata != '')) {
      _fileData = widget.filedata!;
      getTable(_fileData);
    }
    tableCaptionController.text = widget.tableName ?? '';
    _landscape = widget.isLandscape ?? false;
  }

  void getTable(String value) {
    try {
      List<String> rows = value.split("\n");
      var header = rows[0];
      var tempColNames = header.split(",");
      List<String> colNames = [];
      colNames.add("Sl. No");
      colNames.addAll(tempColNames);
      _columns = [];
      for (int i = 0; i < colNames.length; i++) {
        _columns.add(
          DataColumn(label: Text(colNames[i])),
        );
      }
      for (int i = 1; i < rows.length; i++) {
        if (rows[i].trim().isEmpty) {
          continue;
        }
        List<DataCell> cells = [];
        var columns = rows[i].split(",");
        cells.add(
          DataCell(Text('$i')),
        );
        for (int j = 0; j < columns.length; j++) {
          cells.add(
            DataCell(Text(columns[j])),
          );
        }
        _rows.add(
          DataRow(
            cells: cells,
          ),
        );
      }
    } on Exception catch (_) {
      HelperFunctions.showMessage("File Improper", true);
      _columns = [];
      _columns.add(
        const DataColumn(
          label: Text('Preview'),
        ),
      );
      _rows = [];
    }
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
                          _filename = result.files.single.name;
                          if (!_filename.toLowerCase().endsWith('csv')) {
                            HelperFunctions.showMessage(
                                "Only CSV Files Supported", true);
                            return;
                          }
                          var data = pFile.bytes ?? Uint8List(0);
                          _fileData = String.fromCharCodes(data);
                          getTable(_fileData);
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
                child: Row(
                  children: [
                    Flexible(
                      child: TextFormField(
                        controller: tableCaptionController,
                        validator: (value) {
                          if ((value == null) || (value.isEmpty)) {
                            return 'Enter Caption for Table';
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
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      DataTable(
                        columns: _columns,
                        rows: _rows,
                      ),
                    ],
                  ),
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
                          widget.callback(_fileData,
                              tableCaptionController.text, _landscape);
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
                          onPressed: () {
                            HelperFunctions.downloadFile(
                                tableCaptionController.text,
                                'csv',
                                Uint8List.fromList(_fileData.codeUnits));
                          },
                          icon: const Icon(Icons.download),
                          label: const Text("Download")),
                    PortalTarget(
                      visible: _isMenuOpen,
                      anchor: const Aligned(
                        follower: Alignment.bottomRight,
                        target: Alignment.topCenter,
                      ),
                      portalFollower: SizedBox(
                        height: 300,
                        width: 250,
                        child: Card(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              const Text(
                                "Add Table",
                                style: TextStyle(fontStyle: FontStyle.italic),
                              ),
                              const Text("Add Table takes a CSV file as Input"),
                              const Text(
                                  "Sl. No will be automatically added by the software"),
                              const Text(
                                  "First Line should be the headers of the table"),
                              const Text(
                                  "Merged Columns and Rows not supported yet"),
                              IconButton(
                                hoverColor: Colors.redAccent,
                                onPressed: () {
                                  setState(() {
                                    _isMenuOpen = false;
                                  });
                                },
                                icon: const Icon(Icons.close),
                              ),
                            ],
                          ),
                        ),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.info_outline),
                        onPressed: () {
                          setState(() {
                            _isMenuOpen = true;
                          });
                        },
                      ),
                    ),
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
