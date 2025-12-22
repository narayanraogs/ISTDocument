import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:ist_document/variables.dart';

class ReorderContent extends StatefulWidget {
  List<String> contentType;
  List<String> content;
  List<String> captions;
  List<String> filenames;
  List<bool> landscape;
  final VoidCallback cancel;
  final Function(
      List<String> contentType,
      List<String> content,
      List<String> captions,
      List<String> filenames,
      List<bool> landscape) callback;

  ReorderContent(this.contentType, this.content, this.captions, this.filenames,
      this.landscape, this.cancel, this.callback);

  @override
  State<ReorderContent> createState() => StateReorderContent();
}

class StateReorderContent extends State<ReorderContent> {
  List<Widget> _widgets = [];

  @override
  Widget build(BuildContext context) {
    getChildren();
    return Column(
      children: [
        Expanded(
          child: ReorderableListView(children: _widgets, onReorder: _onReorder),
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  widget.callback(widget.contentType, widget.content,
                      widget.captions, widget.filenames, widget.landscape);
                },
                label: Text("Save"),
                icon: Icon(Icons.save),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  widget.cancel();
                },
                label: Text("Cancel"),
                icon: Icon(Icons.cancel_outlined),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _onReorder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final type = widget.contentType.removeAt(oldIndex);
    widget.contentType.insert(newIndex, type);

    final val = widget.content.removeAt(oldIndex);
    widget.content.insert(newIndex, val);

    final cap = widget.captions.removeAt(oldIndex);
    widget.captions.insert(newIndex, cap);

    final file = widget.filenames.removeAt(oldIndex);
    widget.filenames.insert(newIndex, file);

    final land = widget.landscape.removeAt(oldIndex);
    widget.landscape.insert(newIndex, land);

    setState(() {});
  }

  void getChildren() {
    _widgets = [];
    for (int i = 0; i < widget.contentType.length; i++) {
      switch (widget.contentType[i].toLowerCase()) {
        case "text":
          var child = SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Icon(Icons.text_format, size: 60),
                MarkdownBody(
                  data: widget.content[i],
                  shrinkWrap: true,
                ),
              ],
            ),
          );
          var card = getCard(child, Colors.lightBlue, i);
          _widgets.add(card);
        case "image":
          var child = SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Icon(Icons.image, size: 60),
                Image.memory(base64Decode(widget.content[i]), width: 120),
                Text("Image: ${widget.captions[i]}")
              ],
            ),
          );
          var card = getCard(child, Colors.blueGrey, i);
          _widgets.add(card);
        case "table":
        case "excel":
          var noOfLines = widget.content[i].split("\n").length;
          var child = SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Icon(Icons.table_chart, size: 60),
                Text("Table: ${widget.captions[i]} ",
                    style: const TextStyle(fontSize: 18.0)),
                Text("No Of Lines: $noOfLines",
                    style: const TextStyle(fontSize: 16.0)),
              ],
            ),
          );
          var card = getCard(child, Colors.lightGreen, i);
          _widgets.add(card);
        case "code":
        case "file":
          var child = SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Icon(Icons.upload_file_sharp, size: 60),
                Text("Filename: ${widget.filenames[i]}"),
              ],
            ),
          );
          var card = getCard(child, Colors.amberAccent, i);
          _widgets.add(card);
      }
    }
  }

  Widget getCard(Widget child, Color color, int index) {
    var sizedBox = SizedBox(
      key: ValueKey(index),
      width: 300,
      height: 200,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          color: color,
          elevation: 10,
          child: InkWell(
            onTap: () {},
            child: child,
          ),
        ),
      ),
    );
    return sizedBox;
  }
}
