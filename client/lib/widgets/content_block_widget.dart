import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class ContentBlockWidget extends StatelessWidget {
  final Widget child;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onMoveUp;
  final VoidCallback? onMoveDown;
  final String typeLabel;
  final Color? color;

  const ContentBlockWidget({
    super.key,
    required this.child,
    required this.onEdit,
    required this.onDelete,
    this.onMoveUp,
    this.onMoveDown,
    required this.typeLabel,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: color ?? colorScheme.primary,
              width: 4,
            ),
          ),
        ),
        child: Column(
          children: [
            // Header
            Container(
              color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                   Chip(
                     label: Text(typeLabel, style: const TextStyle(fontSize: 10)),
                     visualDensity: VisualDensity.compact,
                     padding: EdgeInsets.zero,
                   ),
                   const Spacer(),
                   if (onMoveUp != null)
                     IconButton(icon: const Icon(Icons.arrow_upward), onPressed: onMoveUp, tooltip: 'Move Up', iconSize: 20),
                   if (onMoveDown != null)
                     IconButton(icon: const Icon(Icons.arrow_downward), onPressed: onMoveDown, tooltip: 'Move Down', iconSize: 20),
                   IconButton(icon: const Icon(Icons.edit), onPressed: onEdit, tooltip: 'Edit', iconSize: 20),
                   IconButton(icon: const Icon(Icons.delete), onPressed: onDelete, tooltip: 'Delete', color: colorScheme.error, iconSize: 20),
                ],
              ),
            ),
            const Divider(height: 1),
            // Content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(width: double.infinity, child: child),
            ),
          ],
        ),
      ),
    );
  }
}
