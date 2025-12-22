import 'dart:convert';
import 'dart:typed_data';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:ist_document/structures.dart';
import 'package:ist_document/variables.dart';
import 'package:http/http.dart' as http;

class HelperFunctions {
  static Widget getTable(String value) {
    List<DataColumn> _columns = [];
    List<DataRow> _rows = [];
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
      showMessage("File Improper", true);
      _columns = [];
      _columns.add(
        const DataColumn(
          label: Text('Preview'),
        ),
      );
      _rows = [];
    }
    return DataTable(
      columns: _columns,
      rows: _rows,
    );
  }

  static void showMessage(String message, bool error) {
    rootScaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(
          message,
        ),
        backgroundColor: error ? Colors.redAccent : Colors.greenAccent,
      ),
    );
  }

  static void downloadFile(
      String documentName, String extension, Uint8List data) async {
    var ts = DateTime.now();
    var month =
        (ts.month.toString().length) == 1 ? '0${ts.month}' : '${ts.month}';
    var day = (ts.day.toString().length) == 1 ? '0${ts.day}' : '${ts.day}';
    var timeStamp = "${ts.year}-$month-$day";
    var hr = (ts.hour.toString().length) == 1 ? '0${ts.hour}' : '${ts.hour}';
    var min =
        (ts.minute.toString().length) == 1 ? '0${ts.minute}' : '${ts.minute}';
    var sec =
        (ts.second.toString().length) == 1 ? '0${ts.second}' : '${ts.second}';
    timeStamp = '${timeStamp}_$hr-$min-$sec';

    await FileSaver.instance.saveFile(
      name: "${documentName}_$timeStamp.$extension",
      bytes: data,
    );
    HelperFunctions.showMessage("File Downloaded", false);
  }

  static Future<String> checkServer(List<String> urls) async {
    for (String url in urls) {
      var ok = await checkURL(url);
      if (ok) {
        debugPrint(url);
        return url;
      }
    }
    return urls.first;
  }

  static Future<bool> checkURL(String url) async {
    ClientID req = ClientID();
    req.id = 'test';

    try {
      final response = await http
          .post(
            Uri.parse('$url/getAllDocumentNames'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(req.toJSON()),
          )
          .timeout(
            const Duration(seconds: 5),
          );

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}
