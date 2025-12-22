import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:ist_document/helper_functions.dart';
import 'package:ist_document/add_image.dart';
import 'package:ist_document/add_pdf.dart';
import 'package:ist_document/add_table.dart';
import 'package:ist_document/add_text.dart';
import 'package:ist_document/structures.dart';
import 'package:ist_document/variables.dart';
import 'package:ist_document/reorder_content.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'add_excel.dart';

class AddContent extends StatefulWidget {
  final Global global;
  final bool textRequired;
  final bool tableRequired;
  final bool imageRequired;
  final bool pdfRequired;
  final bool fileContentRequired;
  final bool excelContentRequired;

  final String section;
  final int contentSize;

  const AddContent(
      this.global,
      this.section,
      this.textRequired,
      this.tableRequired,
      this.imageRequired,
      this.pdfRequired,
      this.fileContentRequired,
      this.excelContentRequired,
      this.contentSize,
      {super.key});

  @override
  State<AddContent> createState() => StateAddContent();
}

class StateAddContent extends State<AddContent> {
  List<Widget> _widgets = [];
  String _subMode = "";
  bool error = false;

  List<String> contentType = [];
  List<String> content = [];
  List<String> captions = [];
  List<String> filenames = [];
  List<bool> landscapes = [];
  bool layout = false;

  int _viewIndex = -1;
  int _editIndex = -1;

  @override
  void initState() {
    super.initState();
    _subMode = "";
    _viewIndex = -1;
    _editIndex = -1;
    sendRequest();
  }

  void sendRequest() async {
    ContentRequest req = ContentRequest();
    req.id = widget.global.clientID;
    req.documentName = widget.global.documentName;
    req.subsection = widget.section;
    try {
      final response = await http.post(
        Uri.parse('${widget.global.url}/getContent'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(req.toJSON()),
      );

      if (response.statusCode == 200) {
        var content = ContentResponse.fromJson(
            jsonDecode(response.body) as Map<String, dynamic>);
        if (content.ok) {
          var diff = content.contentType.length - content.landscape.length;
          for (int i = 0; i < diff; i++) {
            content.landscape.add(false);
          }
          populateContent(content.contentType, content.value, content.captions,
              content.fileName, content.landscape);
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

  void addContent(BuildContext context) async {
    AddContentRequest request = AddContentRequest();
    request.id = widget.global.clientID;
    request.documentName = widget.global.documentName;
    request.subsection = widget.section;
    request.noOfItems = contentType.length;
    request.contentType = contentType;
    request.captions = captions;
    request.value = content;
    request.fileName = filenames;
    request.landscape = landscapes;
    try {
      final response = await http.post(
        Uri.parse('${widget.global.url}/addContent'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(request.toJSON()),
      );

      if (response.statusCode == 200) {
        var ack =
            Ack.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
        if (ack.ok) {
          HelperFunctions.showMessage("Content Added", false);
        } else {
          HelperFunctions.showMessage(ack.msg, true);
        }
      } else {
        HelperFunctions.showMessage("Invalid Request", true);
      }
    } on Exception catch (e) {
      debugPrint('$e');
      HelperFunctions.showMessage("Server Unavailable", true);
    }
  }

  void populateContent(List<String> cType, List<String> value,
      List<String> caption, List<String> filename, List<bool> land) {
    contentType = [];
    content = [];
    captions = [];
    filenames = [];
    landscapes = [];
    _widgets = [];
    for (int i = 0; i < cType.length; i++) {
      switch (cType[i].toLowerCase()) {
        case "text":
          addText(value[i]);
        case "image":
          addImage(base64Decode(value[i]), caption[i], land[i]);
        case "table":
          addTable(value[i], caption[i], land[i]);
        case "file":
          addPdf(value[i], filename[i], caption[i], false, land[i]);
        case "code":
          addPdf(value[i], filename[i], caption[i], true, land[i]);
        case "excel":
          addExcel(value[i], filename[i], caption[i], land[i]);
      }
    }
  }

  void cancelAdd() {
    setState(() {
      _editIndex = -1;
      _viewIndex = -1;
      _subMode = "";
    });
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
            onTap: () {
              setState(() {
                _viewIndex = index;
                _editIndex = -1;
              });
            },
            child: child,
          ),
        ),
      ),
    );
    return sizedBox;
  }

  void addText(String value) {
    var child = SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.text_format, size: 60),
          MarkdownBody(
            data: value,
            shrinkWrap: true,
          ),
        ],
      ),
    );
    var sizedBox = getCard(child, Colors.lightBlue,
        _editIndex != -1 ? _editIndex : contentType.length);

    if (_editIndex != -1) {
      content[_editIndex] = value;
      _widgets[_editIndex] = sizedBox;
    } else {
      contentType.add("Text");
      content.add(value);
      captions.add('');
      filenames.add('');
      landscapes.add(false);
      _widgets.add(sizedBox);
    }
    _subMode = "";
    setState(() {
      _editIndex = -1;
    });
  }

  void addTable(String value, String caption, bool landscape) {
    var noOfLines = value.split("\n").length;
    var child = SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.table_chart, size: 60),
          Text("Table: $caption ", style: const TextStyle(fontSize: 18.0)),
          Text("No Of Lines: $noOfLines",
              style: const TextStyle(fontSize: 16.0)),
        ],
      ),
    );
    var sizedBox = getCard(child, Colors.lightGreen,
        _editIndex != -1 ? _editIndex : contentType.length);

    if (_editIndex != -1) {
      content[_editIndex] = value;
      captions[_editIndex] = caption;
      landscapes[_editIndex] = landscape;
      _widgets[_editIndex] = sizedBox;
    } else {
      contentType.add("Table");
      content.add(value);
      captions.add(caption);
      filenames.add('');
      landscapes.add(landscape);
      _widgets.add(sizedBox);
    }
    _subMode = "";
    setState(() {
      _editIndex = -1;
    });
  }

  void addImage(Uint8List data, String caption, bool landscape) {
    var child = SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.image, size: 60),
          Image.memory(data, width: 120),
          Text("Image: $caption")
        ],
      ),
    );
    var sizedBox = getCard(child, Colors.blueGrey,
        _editIndex != -1 ? _editIndex : contentType.length);

    if (_editIndex != -1) {
      content[_editIndex] = base64Encode(data);
      captions[_editIndex] = caption;
      landscapes[_editIndex] = landscape;
      _widgets[_editIndex] = sizedBox;
    } else {
      contentType.add("Image");
      content.add(base64Encode(data));
      captions.add(caption);
      filenames.add('');
      landscapes.add(landscape);
      _widgets.add(sizedBox);
    }
    _subMode = "";
    setState(() {
      _editIndex = -1;
    });
  }

  void addExcel(String value, String filename, String caption, bool landscape) {
    var child = SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.upload_file_sharp, size: 60),
          Text("Filename: $filename"),
        ],
      ),
    );
    var sizedBox = getCard(child, Colors.amberAccent,
        _editIndex != -1 ? _editIndex : contentType.length);

    if (_editIndex != -1) {
      content[_editIndex] = value;
      filenames[_editIndex] = filename;
      captions[_editIndex] = caption;
      _widgets[_editIndex] = sizedBox;
      landscapes[_editIndex] = landscape;
    } else {
      contentType.add("Excel");
      landscapes.add(landscape);
      filenames.add(filename);
      _widgets.add(sizedBox);
      content.add(value);
      captions.add(caption);
    }
    _subMode = "";
    setState(() {
      _editIndex = -1;
    });
  }

  void addPdf(String value, String filename, String caption,
      bool isContentReadable, bool landscape) {
    var child = SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.upload_file_sharp, size: 60),
          Text("Filename: $filename"),
        ],
      ),
    );
    var sizedBox = getCard(child, Colors.amberAccent,
        _editIndex != -1 ? _editIndex : contentType.length);

    if (_editIndex != -1) {
      content[_editIndex] = value;
      filenames[_editIndex] = filename;
      captions[_editIndex] = caption;
      _widgets[_editIndex] = sizedBox;
      landscapes[_editIndex] = landscape;
    } else {
      if (isContentReadable) {
        contentType.add("Code");
      } else {
        contentType.add("File");
      }
      landscapes.add(landscape);
      filenames.add(filename);
      _widgets.add(sizedBox);
      content.add(value);
      captions.add(caption);
    }
    _subMode = "";
    setState(() {
      _editIndex = -1;
    });
  }

  void deleteContent(int index) {
    if (index < 0 || index >= content.length) return;
    content.removeAt(index);
    contentType.removeAt(index);
    captions.removeAt(index);
    filenames.removeAt(index);
    landscapes.removeAt(index);
    var tempContent = content;
    var tempContentType = contentType;
    var tempCaptions = captions;
    var tempFilenames = filenames;
    var templand = landscapes;
    _viewIndex = -1;
    _editIndex = -1;
    populateContent(
        tempContentType, tempContent, tempCaptions, tempFilenames, templand);
    setState(() {});
  }

  Widget getChild(BuildContext context) {
    switch (_subMode) {
      case "":
        return getContent(context);
      case "Text":
        var text = '';
        if (_editIndex != -1) {
          text = content[_editIndex];
        }
        return AddText(
          widget.global,
          addText,
          cancelAdd,
          content: text,
        );
      case "Table":
        var table = '';
        var caption = '';
        if (_editIndex != -1) {
          table = content[_editIndex];
          caption = captions[_editIndex];
        }
        return AddTable(
          widget.global,
          addTable,
          cancelAdd,
          tableName: caption,
          filedata: table,
          editIndex: _editIndex,
          isLandscape: (_editIndex == -1) ? false : landscapes[_editIndex],
        );
      case "Image":
        var img = Uint8List(0);
        var caption = '';
        if (_editIndex != -1) {
          img = base64Decode(content[_editIndex]);
          caption = captions[_editIndex];
        }
        return AddImage(
          widget.global,
          addImage,
          cancelAdd,
          data: img,
          caption: caption,
          editIndex: _editIndex,
          isLandscape: (_editIndex == -1) ? false : landscapes[_editIndex],
        );
      case "Code":
        var name = '';
        var data = '';
        var caption = '';
        if (_editIndex != -1) {
          name = filenames[_editIndex];
          data = content[_editIndex];
          caption = captions[_editIndex];
        }
        return AddPdf(
          widget.global,
          addPdf,
          cancelAdd,
          _subMode == "Code",
          false,
          pdfName: name,
          fileData: data,
          editIndex: _editIndex,
          caption: caption,
        );
      case "File":
        var name = '';
        var data = '';
        var caption = '';
        if (_editIndex != -1) {
          name = filenames[_editIndex];
          data = content[_editIndex];
          caption = captions[_editIndex];
        }
        return AddPdf(
          widget.global,
          addPdf,
          cancelAdd,
          _subMode == "Code",
          true,
          pdfName: name,
          fileData: data,
          editIndex: _editIndex,
          isLandscape: (_editIndex == -1) ? false : landscapes[_editIndex],
          caption: caption,
        );
      case "Excel":
        var name = '';
        var data = '';
        var caption = '';
        if (_editIndex != -1) {
          name = filenames[_editIndex];
          data = content[_editIndex];
          caption = captions[_editIndex];
        }
        return AddExcel(
          widget.global,
          addExcel,
          cancelAdd,
          true,
          docName: name,
          fileData: data,
          editIndex: _editIndex,
          isLandscape: (_editIndex == -1) ? false : landscapes[_editIndex],
          caption: caption,
        );
    }
    return const Text("Unknown Mode");
  }

  Widget getContent(BuildContext context) {
    var first = LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Column(
          children: [
            SizedBox(
              height: constraints.maxHeight * 0.85,
              width: constraints.maxWidth,
              child: SingleChildScrollView(
                child: Wrap(
                  children: _widgets,
                ),
              ),
            ),
            const Divider(),
            SizedBox(
              height: constraints.maxHeight * 0.1,
              width: constraints.maxWidth,
              child: SingleChildScrollView(
                child: ButtonBar(
                  alignment: MainAxisAlignment.spaceEvenly,
                  children: getSecondLevelChildren(context),
                ),
              ),
            ),
          ],
        );
      },
    );
    var second = LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        Widget child = const Text('Unknown Type');
        if (_viewIndex == -2) {
          var child = ReorderContent(
              contentType, content, captions, filenames, landscapes, () {
            _viewIndex = -1;
            setState(() {});
          }, (a, b, c, d, e) {
            _viewIndex = -1;
            _editIndex = -1;
            populateContent(a, b, c, d, e);
            setState(() {});
          });
          return child;
        }
        switch (contentType[_viewIndex].toLowerCase()) {
          case "text":
            child = SingleChildScrollView(
                child: MarkdownBody(
              data: content[_viewIndex],
              softLineBreak: true,
            ));
          case "table":
            child = SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                //clipBehavior: Clip.hardEdge,
                child: Column(
                  children: [
                    HelperFunctions.getTable(content[_viewIndex]),
                  ],
                ),
              ),
            );
          //child = const Text("Table to be displayed here");
          case "image":
            child = Image.memory(base64Decode(content[_viewIndex]));
          case "file":
            child = SingleChildScrollView(
              child: Text('Filename: ${filenames[_viewIndex]}'),
            );
          case "code":
            child = SingleChildScrollView(
              child: Text('Test Procedure: ${filenames[_viewIndex]}'),
            );
          case "excel":
            child = SingleChildScrollView(
              child: Text('Filename: ${filenames[_viewIndex]}'),
            );
        }
        return Column(
          children: [
            SizedBox(
              height: constraints.maxHeight * 0.85,
              width: constraints.maxWidth,
              child: child,
            ),
            const Divider(),
            SizedBox(
              height: constraints.maxHeight * 0.1,
              width: constraints.maxWidth,
              child: SingleChildScrollView(
                child: ButtonBar(
                  alignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton.filledTonal(
                      onPressed: () {
                        setState(() {
                          _editIndex = _viewIndex;
                          _viewIndex = -1;
                          _subMode = contentType[_editIndex];
                        });
                      },
                      icon: const Icon(Icons.edit),
                      tooltip: "Edit",
                      hoverColor: Colors.green,
                    ),
                    IconButton.filledTonal(
                      onPressed: () {
                        setState(() {
                          deleteContent(_viewIndex);
                        });
                      },
                      icon: const Icon(Icons.delete),
                      tooltip: "Delete",
                      hoverColor: Colors.green,
                    ),
                    IconButton.filledTonal(
                      onPressed: () {
                        setState(() {
                          _viewIndex = -1;
                        });
                      },
                      icon: const Icon(Icons.cancel),
                      tooltip: "Hide",
                      hoverColor: Colors.green,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );

    var builder = LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      double firstWidth = 0.0;
      double secondWidth = 0.0;
      if (_viewIndex == -1) {
        firstWidth = constraints.maxWidth;
        secondWidth = 0.0;
      } else {
        firstWidth = constraints.maxWidth * 0.68;
        secondWidth = constraints.maxWidth * 0.27;
      }
      List<Widget> children = [];
      children.add(
        SizedBox(
          height: constraints.maxHeight,
          width: firstWidth,
          child: first,
        ),
      );
      if (_viewIndex != -1) {
        children.add(const VerticalDivider());
        children.add(
          SizedBox(
              height: constraints.maxHeight, width: secondWidth, child: second),
        );
      }
      return Row(
        children: children,
      );
    });
    return builder;
  }

  List<Widget> getSecondLevelChildren(BuildContext context) {
    List<Widget> children = [];
    if (widget.textRequired) {
      children.add(getIconButton(Icons.text_increase, "Add Text", "Text"));
    }
    if (widget.imageRequired) {
      children.add(getIconButton(Icons.image_outlined, "Add Image", "Image"));
    }
    /*if (widget.tableRequired) {
      children.add(getIconButton(Icons.table_chart, "Add Table", "Table"));
    }*/
    if (widget.pdfRequired) {
      children.add(getIconButton(Icons.file_present, "Add File", "File"));
    }
    if (widget.fileContentRequired) {
      children
          .add(getIconButton(Icons.attach_file_sharp, "Add Procedure", "Code"));
    }
    if ((widget.excelContentRequired) || (widget.tableRequired)) {
      children.add(
          getIconButton(Icons.table_chart_outlined, "Add Excel", "Excel"));
    }
    if (contentType.length > 1) {
      children.add(
        IconButton.filledTonal(
          onPressed: () {
            _viewIndex = -2;
            setState(() {});
          },
          icon: const Icon(Icons.reorder_rounded),
          tooltip: "Reorder",
          hoverColor: Colors.green,
        ),
      );
    }
    children.add(
      IconButton.filledTonal(
        onPressed: () {
          addContent(context);
        },
        icon: const Icon(Icons.save),
        tooltip: "Save",
        hoverColor: Colors.green,
      ),
    );
    return children;
  }

  Widget getIconButton(IconData icon, String tooltip, String mode) {
    var btn = IconButton.filledTonal(
      onPressed: () {
        if (content.length >= widget.contentSize) {
          HelperFunctions.showMessage("Content Limit Reached", true);
          return;
        }
        _subMode = mode;
        setState(() {});
      },
      icon: Icon(icon),
      tooltip: tooltip,
      hoverColor: Colors.green,
    );
    return btn;
  }

  @override
  Widget build(BuildContext context) {
    return getChild(context);
  }
}
