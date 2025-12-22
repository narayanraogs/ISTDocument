import 'package:flutter/material.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:ist_document/variables.dart';
import 'package:markdown_editor_plus/markdown_editor_plus.dart';

class AddText extends StatefulWidget {
  final Global global;
  final Function(String) callback;
  final VoidCallback cancel;
  final String? content;

  const AddText(this.global, this.callback, this.cancel,
      {super.key, this.content});

  @override
  State<AddText> createState() => StateAddText();
}

class StateAddText extends State<AddText> {
  TextEditingController _controller = TextEditingController();
  bool _isMenuOpen = false;

  @override
  void initState() {
    super.initState();
    _controller.text = widget.content ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraint) {
        return Column(
          children: [
            SizedBox(
                height: constraint.maxHeight * 0.88,
                width: constraint.maxWidth,
                child: SingleChildScrollView(
                  child: SplittedMarkdownFormField(
                    controller: _controller,
                    minLines: 15,
                    maxLines: 15,
                  ),
                )),
            SizedBox(
              height: constraint.maxHeight * 0.1,
              width: constraint.maxWidth,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      widget.callback(_controller.text);
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
                              "Add Text",
                              style: TextStyle(fontStyle: FontStyle.italic),
                            ),
                            const Text(
                                "Add text provides a rich text editor to add text to the document"),
                            const Text(
                                "Avoid using Heading 1 and Heading 2 as they can change the document structure"),
                            const Text(
                                "Avoid using insert table and insert image in the rich text editor, use Add Table and Add Image from the software instead"),
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
            ),
          ],
        );
      },
    );
  }
}
