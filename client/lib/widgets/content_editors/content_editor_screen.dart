import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../../data/content_models.dart';
import '../../providers/app_state.dart';
import '../../services/api_service.dart';
import '../content_block_widget.dart';
import 'text_editor.dart';

// We can define other editors here or in separate files.
// For brevity, I'll put basic renderers here for now or placeholders.

class ContentEditorScreen extends StatefulWidget {
  final String subsectionKey;

  const ContentEditorScreen({super.key, required this.subsectionKey});

  @override
  State<ContentEditorScreen> createState() => _ContentEditorScreenState();
}

class _ContentEditorScreenState extends State<ContentEditorScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<ContentItem> _items = [];

  // Edit State
  ContentItem? _editingItem;
  int _editingIndex = -1;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didUpdateWidget(covariant ContentEditorScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.subsectionKey != widget.subsectionKey) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    final appState = context.read<AppState>();
    if (appState.selectedDocument == null) return;

    setState(() {
      _isLoading = true;
      _items = [];
      _editingItem = null;
      _editingIndex = -1;
    });

    final subsection = _mapRouteToSubsection(widget.subsectionKey);
    final response = await _apiService.getContent(
      appState.clientId,
      appState.selectedDocument!,
      subsection,
    );

    if (mounted) {
      setState(() {
        _items = response.items;
        _isLoading = false;
      });
    }
  }

  Future<void> _saveData() async {
    final appState = context.read<AppState>();
    if (appState.selectedDocument == null) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Saving...')));

    final subsection = _mapRouteToSubsection(widget.subsectionKey);
    final result = await _apiService.addContent(
      appState.clientId,
      appState.selectedDocument!,
      subsection,
      _items,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: result.ok ? Colors.green : Colors.red,
        ),
      );
    }
  }

  String _mapRouteToSubsection(String route) {
    // Simple heuristic: convert 'intro_acronyms' -> 'Introduction-Acronyms'
    // Depending on how previous developer did it, we might need a map.
    // Based on sidebar structure:
    // Information: info_
    // Introduction: intro_
    // Checkout: checkout_
    // Test: test_
    // Annexure: annexure_

    // The server expects "Introduction-Acronyms".
    // Let's create a map based on Sidebar titles.

    // Manual Mapping based on Sidebar.dart titles
    switch (route) {
      // Introduction
      case 'intro_acronyms':
        return 'Introduction-Acronyms';
      case 'intro_subsystem_intro':
        return 'Introduction-SSIntroduction';
      case 'intro_subsystem_spec':
        return 'Introduction-SSSpecification';
      case 'intro_tc':
        return 'Introduction-Telecommand';
      case 'intro_tm':
        return 'Introduction-Telemetry';
      case 'intro_pages':
        return 'Introduction-Pages';

      // Checkout Details
      case 'checkout_interface':
        return 'Checkout-Interface';
      case 'checkout_specific_reqs':
        return 'Checkout-SpecificRequirements';
      case 'checkout_safety_reqs':
        return 'Checkout-SafetyRequirements';
      case 'checkout_test_philosophy':
        return 'Checkout-TestPhilosophy';
      case 'checkout_clarifications':
        return 'Checkout-SubsystemClarifications';

      // Test Details
      case 'test_matrix':
        return 'TestMatrix';
      case 'test_plan':
        return 'TestPlans';
      case 'test_procedure':
        return 'TestProcedures';

      // Annexure
      case 'annexure_eid':
        return 'Annexure-EID';
      case 'annexure_test_results':
        return 'Annexure-TestResultsFormat';

      // Information
      case 'info_signed_page':
        return 'Information-SignedPage';

      default:
        return route; // Fallback
    }
  }

  void _addNewItem(ContentType type) {
    setState(() {
      _items.add(ContentItem(type: type));
      _editingIndex = _items.length - 1;
      _editingItem = _items.last;
    });
  }

  void _deleteItem(int index) {
    setState(() {
      _items.removeAt(index);
      if (_editingIndex == index) {
        _editingIndex = -1;
        _editingItem = null;
      } else if (_editingIndex > index) {
        _editingIndex--;
      }
    });
  }

  void _moveItem(int index, int delta) {
    final newIndex = index + delta;
    if (newIndex < 0 || newIndex >= _items.length) return;
    setState(() {
      final item = _items.removeAt(index);
      _items.insert(newIndex, item);
      // Adjust editing index if needed
      if (_editingIndex == index)
        _editingIndex = newIndex;
      else if (_editingIndex == newIndex)
        _editingIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Split View: List on left (or full), Editor dialog/pane on right?
    // Or simpler: List View, click edit to open Dialog.
    // Let's go with List View + Dialog for editing to keep it clean.

    // Actually, "In-place" editing or "Split" view is better for desktop.
    // But let's stick to the "List of Cards" for view mode, and "Dialog" for add/edit for simplicity first.
    // Wait, the user asked specifically about "Forms".
    // The previous implementation used a card-based layout.

    // If _editingItem is not null, show editor overlay or split screen?
    // Let's use a Split Screen approach if width allows, else overlay.

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 900;

        Widget contentList = ListView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 80), // Space for FAB
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _mapRouteToSubsection(widget.subsectionKey),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                ElevatedButton.icon(
                  onPressed: _saveData,
                  icon: const Icon(Icons.save),
                  label: const Text("Save All"),
                ),
              ],
            ),
            const Divider(),
            if (_items.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text("No content yet. Add some!"),
                ),
              ),

            for (int i = 0; i < _items.length; i++)
              ContentBlockWidget(
                key: ValueKey(
                  _items[i],
                ), // Using object identity as key? Better to have ID but index is okay if we are careful
                typeLabel: _items[i].typeString,
                onEdit: () {
                  setState(() {
                    _editingIndex = i;
                    _editingItem = _items[i]; // Reference copy
                  });
                  if (!isWide) _showEditDialog(context);
                },
                onDelete: () => _deleteItem(i),
                onMoveUp: i > 0 ? () => _moveItem(i, -1) : null,
                onMoveDown: i < _items.length - 1
                    ? () => _moveItem(i, 1)
                    : null,
                child: _buildItemPreview(_items[i]),
              ),
          ],
        );

        if (isWide && _editingItem != null) {
          return Row(
            children: [
              Expanded(flex: 1, child: contentList), // List takes less space
              const VerticalDivider(width: 1),
              Expanded(
                flex: 2,
                child: _buildEditorPane(),
              ), // Editor takes more space
            ],
          );
        }

        if (_editingItem != null && !isWide) {
          // In narrow mode, we might want to just show the list and use the dialog,
          // OR if we want to mimic the wide behavior, we could push a new route
          // or just show the pane full screen.
          // But based on previous logic, we use _showEditDialog for narrow screens.
          // However, the user asked for "Editor takes more screen space".
          // Let's stick to the dialog for narrow screens but make sure it uses full width/height.
        }

        return Scaffold(
          body: contentList,
          floatingActionButton: _editingItem == null ? _buildAddMenu() : null,
        );
      },
    );
  }

  // ... (AddMenu and ItemPreview remain same)

  List<ContentType> _getAllowedTypes() {
    // Map routes to allowed types to match old client behavior

    // Abstract, Telecommand, Telemetry, Pages -> Only Text?
    // Old client 'Introduction.dart':
    // Abstract -> Text ("Autofilled") - actually user can edit in new client? Old client says "Autofilled".
    // Acronyms -> "Upload csv" (So Table/Excel?) + Browse
    // Subsystem Intro -> Text, Image, Table
    // Subsystem Spec -> Text, Image, Table
    // Telecommand -> "Browse" (File?)
    // Telemetry -> "Browse" (File?)
    // Pages -> "Add Image"

    // Let's approximate based on Sidebar routes:

    switch (widget.subsectionKey) {
      case 'intro_abstract':
        return [ContentType.text]; // Usually autofilled but editable text
      case 'intro_acronyms':
        return [ContentType.table, ContentType.excel]; // CSV/Excel for acronyms
      case 'intro_subsystem_intro':
      case 'intro_subsystem_spec':
        return [
          ContentType.text,
          ContentType.image,
          ContentType.table,
          ContentType.excel,
        ];
      case 'intro_tc':
      case 'intro_tm':
        return [
          ContentType.text,
          ContentType.excel,
          ContentType.table,
        ]; // File uploads
      case 'intro_pages':
        return [ContentType.text, ContentType.image];
      // Checkout
      case 'checkout_interface':
        return [
          ContentType.text,
          ContentType.image,
          ContentType.table,
          ContentType.excel,
        ];
      case 'checkout_specific_reqs':
      case 'checkout_safety_reqs':
        return [
          ContentType.text,
          ContentType.image,
          ContentType.file,
          ContentType.table,
          ContentType.excel,
        ];
      case 'checkout_test_philosophy':
        return [
          ContentType.text,
          ContentType.image,
          ContentType.table,
          ContentType.excel,
        ];
      case 'checkout_clarifications':
        return [
          ContentType.text,
          ContentType.file,
          ContentType.table,
          ContentType.excel,
        ];
      // Test Details
      case 'test_matrix':
        return [ContentType.file, ContentType.table, ContentType.excel];
      case 'test_plan':
        return [ContentType.text, ContentType.excel, ContentType.table];
      case 'test_procedure':
        return [ContentType.text, ContentType.code]; // Procedures
      case 'info_signed_page':
        return [ContentType.image, ContentType.file];
      case 'annexure_eid':
        return [ContentType.text, ContentType.file];
      case 'annexure_test_results':
        return [
          ContentType.text,
          ContentType.image,
          ContentType.file,
          ContentType.table,
          ContentType.excel,
        ];
      default:
        // Default to everything if unsure
        return ContentType.values;
    }
  }

  Widget _buildAddMenu() {
    final allowed = _getAllowedTypes();

    return PopupMenuButton<ContentType>(
      icon: const Icon(Icons.add),
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(
          Theme.of(context).colorScheme.primaryContainer,
        ),
        foregroundColor: WidgetStatePropertyAll(
          Theme.of(context).colorScheme.onPrimaryContainer,
        ),
        padding: const WidgetStatePropertyAll(EdgeInsets.all(16)),
      ),
      onSelected: _addNewItem,
      itemBuilder: (context) {
        return [
          if (allowed.contains(ContentType.text))
            const PopupMenuItem(
              value: ContentType.text,
              child: Row(
                children: [
                  Icon(Icons.text_fields),
                  SizedBox(width: 8),
                  Text('Text'),
                ],
              ),
            ),
          if (allowed.contains(ContentType.image))
            const PopupMenuItem(
              value: ContentType.image,
              child: Row(
                children: [
                  Icon(Icons.image),
                  SizedBox(width: 8),
                  Text('Image'),
                ],
              ),
            ),
          if (allowed.contains(ContentType.table))
            const PopupMenuItem(
              value: ContentType.table,
              child: Row(
                children: [
                  Icon(Icons.table_chart),
                  SizedBox(width: 8),
                  Text('Table'),
                ],
              ),
            ),
          if (allowed.contains(ContentType.file))
            const PopupMenuItem(
              value: ContentType.file,
              child: Row(
                children: [
                  Icon(Icons.picture_as_pdf),
                  SizedBox(width: 8),
                  Text('PDF'),
                ],
              ),
            ),
          if (allowed.contains(ContentType.code))
            const PopupMenuItem(
              value: ContentType.code,
              child: Row(
                children: [
                  Icon(Icons.code),
                  SizedBox(width: 8),
                  Text('Code/Procedure'),
                ],
              ),
            ),
          if (allowed.contains(ContentType.excel))
            const PopupMenuItem(
              value: ContentType.excel,
              child: Row(
                children: [
                  Icon(Icons.grid_on),
                  SizedBox(width: 8),
                  Text('Excel'),
                ],
              ),
            ),
        ];
      },
    );
  }

  Widget _buildItemPreview(ContentItem item) {
    switch (item.type) {
      case ContentType.text:
        return MarkdownBody(
          data: item.value.isNotEmpty ? item.value : '(Empty Text)',
        );
      case ContentType.image:
        if (item.value.isEmpty) return const Text('No Image Selected');
        try {
          return Column(
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 200),
                child: Image.memory(base64Decode(item.value)),
              ),
              if (item.caption.isNotEmpty)
                Text(
                  item.caption,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ],
          );
        } catch (e) {
          return const Text('Invalid Image Data');
        }
      case ContentType.table:
        return Column(
          children: [
            const Icon(Icons.table_chart, size: 48, color: Colors.grey),
            Text('Table: ${item.caption}'),
            Text(
              item.value,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ],
        );
      default:
        // Generic preview for files/pdf
        return Column(
          children: [
            Icon(
              item.type == ContentType.file
                  ? Icons.picture_as_pdf
                  : Icons.data_object,
              size: 48,
              color: Colors.red.shade700,
            ),
            Text(
              item.fileName.isNotEmpty
                  ? item.fileName
                  : (item.type == ContentType.file
                        ? 'PDF Document'
                        : item.typeString),
            ),
            if (item.caption.isNotEmpty) Text(item.caption),
          ],
        );
    }
  }

  // ... (Editor Pane and Dialog remain same)

  Widget _buildEditorPane() {
    if (_editingIndex == -1) return const SizedBox.shrink();

    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                "Editing ${_editingItem!.type == ContentType.file ? 'PDF' : _editingItem!.typeString}",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    _editingIndex = -1;
                    _editingItem = null;
                  });
                },
              ),
            ],
          ),
          const Divider(height: 32),
          Expanded(
            child: SingleChildScrollView(
              child: _buildSpecificEditor(_editingItem!),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog.fullscreen(
          child: Scaffold(
            appBar: AppBar(
              title: Text(
                "Edit ${_editingItem!.type == ContentType.file ? 'PDF' : _editingItem!.typeString}",
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {});
                  },
                  child: const Text("Done"),
                ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: _buildSpecificEditor(_editingItem!),
              ),
            ),
          ),
        );
      },
    ).then((_) {
      setState(() {
        _editingIndex = -1;
        _editingItem = null;
      });
    });
  }

  Widget _buildSpecificEditor(ContentItem item) {
    // Common fields
    List<Widget> children = [];

    // Type Specific
    if (item.type == ContentType.text) {
      children.add(
        TextEditor(
          initialValue: item.value,
          onChanged: (v) {
            item.value = v;
          },
        ),
      );
      // Text doesn't need caption or landscape
    } else if (item.type == ContentType.image) {
      children.add(_buildImageEditor(item));
      _addCommonFields(children, item);
    } else if (item.type == ContentType.table) {
      children.add(_buildTableEditor(item));
      _addCommonFields(children, item);
    } else if (item.type == ContentType.file) {
      children.add(_buildPdfEditor(item));
      _addCommonFields(children, item);
    } else if (item.type == ContentType.code) {
      children.add(_buildFileEditor(item));
      _addCommonFields(children, item);
    } else if (item.type == ContentType.excel) {
      children.add(_buildExcelEditor(item));
      _addCommonFields(children, item);
    } else {
      children.add(
        TextField(
          controller: TextEditingController(text: item.value),
          maxLines: 5,
          onChanged: (v) => item.value = v,
          decoration: const InputDecoration(
            labelText: 'Raw Value / Content',
            border: OutlineInputBorder(),
          ),
        ),
      );
      _addCommonFields(children, item);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  // ... (Other Editors)

  // ... (File Editor)

  Widget _buildExcelEditor(ContentItem item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Excel Spreadsheet",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.green.shade200),
            borderRadius: BorderRadius.circular(4),
            color: Colors.green.shade50,
          ),
          child: Column(
            children: [
              Icon(Icons.grid_on, size: 48, color: Colors.green.shade700),
              const SizedBox(height: 8),
              Text(
                item.fileName.isNotEmpty
                    ? item.fileName
                    : "No Excel File Selected",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                item.value.isNotEmpty
                    ? "${(item.value.length / 1024).toStringAsFixed(1)} KB"
                    : "",
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () async {
            FilePickerResult? result = await FilePicker.platform.pickFiles(
              type: FileType.custom,
              allowedExtensions: ['xlsx'],
              withData: true,
            );

            if (result != null) {
              final file = result.files.single;
              if (file.bytes != null) {
                setState(() {
                  item.fileName = file.name;
                  item.value = base64Encode(file.bytes!);
                });
              }
            }
          },
          icon: const Icon(Icons.upload_file),
          label: const Text("Upload Excel (.xlsx)"),
        ),
      ],
    );
  }
  // ... (Common Fields, Image Editor, Table Editor)

  void _addCommonFields(List<Widget> children, ContentItem item) {
    children.add(const SizedBox(height: 24));
    children.add(
      TextField(
        controller: TextEditingController(text: item.caption),
        onChanged: (v) => item.caption = v,
        decoration: const InputDecoration(
          labelText: 'Caption',
          border: OutlineInputBorder(),
        ),
      ),
    );

    children.add(const SizedBox(height: 16));
    children.add(
      SwitchListTile(
        title: const Text("Landscape Mode"),
        value: item.isLandscape,
        onChanged: (v) => setState(() => item.isLandscape = v),
      ),
    );
  }

  Widget _buildImageEditor(ContentItem item) {
    Uint8List? imageData;
    if (item.value.isNotEmpty) {
      try {
        imageData = base64Decode(item.value);
      } catch (e) {
        // ignore error
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 300,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
            color: Colors.black12,
          ),
          child: imageData != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.memory(imageData, fit: BoxFit.contain),
                )
              : const Center(
                  child: Icon(Icons.image, size: 64, color: Colors.grey),
                ),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () async {
            FilePickerResult? result = await FilePicker.platform.pickFiles(
              type: FileType.image,
              withData: true,
            );
            if (result != null) {
              setState(() {
                item.value = base64Encode(result.files.single.bytes!);
              });
            }
          },
          icon: const Icon(Icons.upload),
          label: const Text("Select Image"),
        ),
      ],
    );
  }

  Widget _buildTableEditor(ContentItem item) {
    // ... (Previous Implementation)
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Table Content (CSV)",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(4),
            color: Colors.grey.shade100,
          ),
          child: Text(
            item.value.isEmpty ? "No CSV Loaded" : item.value,
            maxLines: 10,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontFamily: 'monospace'),
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () async {
            FilePickerResult? result = await FilePicker.platform.pickFiles(
              type: FileType.custom,
              allowedExtensions: ['csv'],
              withData: true,
            );

            if (result != null) {
              final bytes = result.files.single.bytes;
              if (bytes != null) {
                // Decode utf8
                try {
                  final String content = utf8.decode(bytes);
                  setState(() {
                    item.value = content;
                    // Auto-set filename if empty? could do but item.fileName logic isn't strictly used here
                  });
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Error reading CSV file")),
                  );
                }
              }
            }
          },
          icon: const Icon(Icons.table_view),
          label: const Text("Upload CSV"),
        ),
      ],
    );
  }

  Widget _buildPdfEditor(ContentItem item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "PDF Document",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.red.shade200),
            borderRadius: BorderRadius.circular(4),
            color: Colors.red.shade50,
          ),
          child: Column(
            children: [
              Icon(Icons.picture_as_pdf, size: 48, color: Colors.red.shade700),
              const SizedBox(height: 8),
              Text(
                item.fileName.isNotEmpty ? item.fileName : "No PDF Selected",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                item.value.isNotEmpty
                    ? "${(item.value.length / 1024).toStringAsFixed(1)} KB"
                    : "",
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () async {
            FilePickerResult? result = await FilePicker.platform.pickFiles(
              type: FileType.custom,
              allowedExtensions: ['pdf'],
              withData: true,
            );

            if (result != null) {
              final file = result.files.single;
              if (file.bytes != null) {
                setState(() {
                  item.fileName = file.name;
                  item.value = base64Encode(file.bytes!);
                });
              }
            }
          },
          icon: const Icon(Icons.upload_file),
          label: const Text("Upload PDF"),
        ),
      ],
    );
  }

  Widget _buildFileEditor(ContentItem item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Procedure/Code File",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blue.shade200),
            borderRadius: BorderRadius.circular(4),
            color: Colors.blue.shade50,
          ),
          child: Column(
            children: [
              const Icon(Icons.code, size: 48, color: Colors.blue),
              const SizedBox(height: 8),
              Text(
                item.fileName.isNotEmpty ? item.fileName : "No File Selected",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                item.value.isNotEmpty
                    ? "${(item.value.length / 1024).toStringAsFixed(1)} KB"
                    : "",
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () async {
            FilePickerResult? result = await FilePicker.platform.pickFiles(
              withData: true,
              // No specific restriction, allow 'any'
            );

            if (result != null) {
              final file = result.files.single;
              if (file.bytes != null) {
                setState(() {
                  item.fileName = file.name;
                  item.value = base64Encode(file.bytes!);
                });
              }
            }
          },
          icon: const Icon(Icons.file_upload),
          label: const Text("Upload Procedure/File"),
        ),
      ],
    );
  }
}
