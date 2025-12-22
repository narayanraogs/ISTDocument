import 'package:flutter/material.dart';

class TextEditor extends StatefulWidget {
  final String initialValue;
  final ValueChanged<String> onChanged;

  const TextEditor({
    super.key,
    required this.initialValue,
    required this.onChanged,
  });

  @override
  State<TextEditor> createState() => _TextEditorState();
}

class _TextEditorState extends State<TextEditor> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _focusNode = FocusNode();
    _controller.addListener(() {
      widget.onChanged(_controller.text);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _insertFormatting(String startTag, [String? endTag]) {
    final text = _controller.text;
    final selection = _controller.selection;
    final newText = StringBuffer();
    
    // If no selection, just append at end or at cursor
    int start = selection.isValid ? selection.start : text.length;
    int end = selection.isValid ? selection.end : text.length;

    // Default to empty selection at end if invalid
    if (start < 0) start = text.length;
    if (end < 0) end = text.length;

    newText.write(text.substring(0, start));
    newText.write(startTag);
    newText.write(text.substring(start, end));
    newText.write(endTag ?? startTag); // If no endTag, use startTag (symmetric like **)
    newText.write(text.substring(end));

    _controller.value = TextEditingValue(
      text: newText.toString(),
      selection: TextSelection.collapsed(
        offset: start + startTag.length + (end - start), // Cursor at end of inserted content
      ),
    );
    // Request focus back to continue typing
    _focusNode.requestFocus();
  }

  // Inserts at start of line (like # or - )
  void _toggleLinePrefix(String prefix) {
    final text = _controller.text;
    final selection = _controller.selection;
    
    // Simple line finding for current selection
    // This is a naive implementation, good enough for single line edits or starts
    int cursor = selection.isValid ? selection.baseOffset : text.length;
    if (cursor < 0) cursor = text.length;

    // Find start of current line
    int lineStart = text.lastIndexOf('\n', cursor - 1);
    lineStart = (lineStart == -1) ? 0 : lineStart + 1;

    final newText = text.replaceRange(lineStart, lineStart, prefix);
    
    _controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: cursor + prefix.length),
    );
     _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outline),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Toolbar
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _ToolbarBtn(icon: Icons.format_bold, tooltip: 'Bold', onPressed: () => _insertFormatting('**')),
                  _ToolbarBtn(icon: Icons.format_italic, tooltip: 'Italic', onPressed: () => _insertFormatting('*')),
                  const VerticalDivider(width: 8, indent: 4, endIndent: 4),
                  _ToolbarBtn(icon: Icons.title, tooltip: 'Heading 1', onPressed: () => _toggleLinePrefix('# ')),
                  _ToolbarBtn(icon: Icons.text_fields, tooltip: 'Heading 2', onPressed: () => _toggleLinePrefix('## ')),
                  const VerticalDivider(width: 8, indent: 4, endIndent: 4),
                  _ToolbarBtn(icon: Icons.format_list_bulleted, tooltip: 'Bullet List', onPressed: () => _toggleLinePrefix('- ')),
                  _ToolbarBtn(icon: Icons.format_list_numbered, tooltip: 'Numbered List', onPressed: () => _toggleLinePrefix('1. ')),
                  _ToolbarBtn(icon: Icons.data_object, tooltip: 'Code Block', onPressed: () => _insertFormatting('```\n', '\n```')),
                   const VerticalDivider(width: 8, indent: 4, endIndent: 4),
                  _ToolbarBtn(icon: Icons.link, tooltip: 'Link', onPressed: () => _insertFormatting('[', '](url)')),
                ],
              ),
            ),
          ),
          // Editor
          TextField(
            controller: _controller,
            focusNode: _focusNode,
            maxLines: null,
            minLines: 8,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 13), // Monospace for code-like feel
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(12),
              hintText: 'Type markdown here...',
            ),
          ),
        ],
      ),
    );
  }
}

class _ToolbarBtn extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const _ToolbarBtn({required this.icon, required this.tooltip, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: 20),
      tooltip: tooltip,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        padding: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
    );
  }
}
