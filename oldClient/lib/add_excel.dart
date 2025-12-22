import 'dart:convert';
import 'dart:typed_data';
import 'package:ist_document/helper_functions.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:ist_document/variables.dart';
import 'package:excel/excel.dart';

class AddExcel extends StatefulWidget {
  final Global global;
  final Function(String, String, String, bool) callback;
  final VoidCallback cancel;
  final String? docName;
  final String? fileData;
  final String? caption;
  final int editIndex;
  final bool landscapeAllowed;
  bool? isLandscape = false;

  AddExcel(this.global, this.callback, this.cancel, this.landscapeAllowed,
      {super.key,
      this.fileData,
      this.docName,
      this.caption,
      required this.editIndex,
      this.isLandscape});

  @override
  State<AddExcel> createState() => StateAddExcel();
}

class StateAddExcel extends State<AddExcel> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController tablePathController = TextEditingController();
  TextEditingController tableCaptionController = TextEditingController();
  String _filename = 'Click Browse to upload XLSX File';
  Uint8List _filedata = Uint8List(0);
  List<DataColumn> _columns = [];
  List<DataRow> _rows = [];
  bool _landscape = false;

  @override
  void initState() {
    super.initState();
    _columns.add(
      const DataColumn(
        label: Text('Preview'),
      ),
    );
    tablePathController.text = widget.docName ?? "";
    if (widget.fileData != null) {
      var fd = widget.fileData ?? '';
      _filedata = base64Decode(fd);
      _filename = widget.docName ?? '';
      tableCaptionController.text = widget.caption ?? '';
      _landscape = widget.isLandscape ?? false;
      getTable();
    }


  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    List<Widget> rowChildren = [];
    rowChildren.add(
      Flexible(
        child: ElevatedButton.icon(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.callback(base64Encode(_filedata), _filename,
                  tableCaptionController.text, _landscape);
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
              HelperFunctions.downloadFile(
                  widget.docName!, 'xlsx', base64Decode(widget.fileData!));
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
                          if (_filename.toLowerCase().endsWith('xlsx')) {
                            _filedata = pFile.bytes ?? Uint8List(0);
                            getTable();
                            setState(() {});
                          }else {
                            HelperFunctions.showMessage(
                                "Only XLSX files supported", true);
                          }
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
                  ],
                ),
              ),
              SizedBox(
                height: constraint.maxHeight * 0.1,
                width: constraint.maxWidth,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: rowChildren,
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
            ],
          );
        },
      ),
    );
  }

 void getTable() {
    if (_filedata.isEmpty){
      return;
    }
    try {
      var excel = Excel.decodeBytes(_filedata);
      var table = excel.tables.keys.first;
      int noOfColumns = 0;
      int noOfRows = 0;
      noOfColumns = excel.tables[table]!.maxColumns;
      noOfRows = excel.tables[table]!.maxColumns;
      if ((noOfColumns == 0) || (noOfRows == 0)) {
        HelperFunctions.showMessage("File Improper", true);
        return;
      }
      _columns = [];
      _rows = [];
      var first = true;
      for (var row in excel.tables[table]!.rows) {
        if (first) {
          List<String> colNames = [];
          for (var cell in row) {
            colNames.add(cell?.value.toString() ?? "Header Missing");
          }
          for (int i = 0; i < colNames.length; i++) {
            _columns.add(
              DataColumn(label: Text(colNames[i])),
            );
          }
          first = false;
          continue;
        }
        List<String> values = [];
        List<DataCell> cells = [];
        for (var cell in row) {
          values.add(cell?.value.toString() ?? "");
        }
        for (int i = 0; i < values.length; i++) {
          cells.add(
            DataCell(Text(values[i])),
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
}
