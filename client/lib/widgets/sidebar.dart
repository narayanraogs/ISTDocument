import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();
    var colorScheme = Theme.of(context).colorScheme;

    if (appState.selectedDocument == null) {
      return _buildNoDocumentState(context);
    }

    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        border: Border(
          right: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      child: Column(
        children: [
          // Header / Document Info
          _buildHeader(context, appState),
          const Divider(height: 1),

          // Scrollable Menu
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const SizedBox(height: 8),
                _buildExpansionTile(
                  context,
                  title: 'Information',
                  isExpanded: appState.expandedSections['Information'] ?? false,
                  onExpansionChanged: () => appState.toggleSection('Information'),
                  children: [
                    _buildNavItem(context, 'Document Information', 'info_document', Icons.info_outline),
                    _buildNavItem(context, 'Subsystem Information', 'info_subsystem', Icons.settings_input_component),
                    _buildNavItem(context, 'Signed Page', 'info_signed_page', Icons.draw),
                  ],
                ),
                _buildExpansionTile(
                  context,
                  title: 'Introduction',
                  isExpanded: appState.expandedSections['Introduction'] ?? false,
                  onExpansionChanged: () => appState.toggleSection('Introduction'),
                  children: [
                    _buildNavItem(context, 'Acronyms', 'intro_acronyms', Icons.abc),
                    _buildNavItem(context, 'Subsystem Intro', 'intro_subsystem_intro', Icons.article),
                    _buildNavItem(context, 'Subsystem Spec', 'intro_subsystem_spec', Icons.assignment),
                    _buildNavItem(context, 'Telecommand', 'intro_tc', Icons.upload),
                    _buildNavItem(context, 'Telemetry', 'intro_tm', Icons.download),
                    _buildNavItem(context, 'Pages', 'intro_pages', Icons.pages),
                  ],
                ),
                _buildExpansionTile(
                  context,
                  title: 'Checkout Details',
                  isExpanded: appState.expandedSections['Checkout Details'] ?? false,
                  onExpansionChanged: () => appState.toggleSection('Checkout Details'),
                  children: [
                    _buildNavItem(context, 'Interface', 'checkout_interface', Icons.cable),
                    _buildNavItem(context, 'Specific Reqs', 'checkout_specific_reqs', Icons.rule),
                    _buildNavItem(context, 'Safety Reqs', 'checkout_safety_reqs', Icons.health_and_safety),
                    _buildNavItem(context, 'Test Philosophy', 'checkout_test_philosophy', Icons.psychology),
                    _buildNavItem(context, 'Clarifications', 'checkout_clarifications', Icons.feedback),
                  ],
                ),
                _buildExpansionTile(
                  context,
                  title: 'Test Details',
                  isExpanded: appState.expandedSections['Test Details'] ?? false,
                  onExpansionChanged: () => appState.toggleSection('Test Details'),
                  children: [
                    _buildNavItem(context, 'Test Matrix', 'test_matrix', Icons.grid_on),
                    _buildNavItem(context, 'Test Plan', 'test_plan', Icons.calendar_today),
                    _buildNavItem(context, 'Test Procedure', 'test_procedure', Icons.list_alt),
                  ],
                ),
                _buildExpansionTile(
                  context,
                  title: 'Annexure',
                  isExpanded: appState.expandedSections['Annexure'] ?? false,
                  onExpansionChanged: () => appState.toggleSection('Annexure'),
                  children: [
                    _buildNavItem(context, 'EID Document', 'annexure_eid', Icons.extension),
                    _buildNavItem(context, 'Test Results', 'annexure_test_results', Icons.assessment),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1),
          // Bottom Actions
          ListTile(
            leading: const Icon(Icons.picture_as_pdf),
            title: const Text('Generate PDF'),
            onTap: () => appState.navigateTo('generate_pdf'),
            selected: appState.currentRoute == 'generate_pdf',
          ),
          ListTile(
            leading: const Icon(Icons.folder_open),
            title: const Text('Change Document'),
            onTap: () => appState.selectDocument(null), // Go back to dashboard/selection
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildNoDocumentState(BuildContext context) {
     var colorScheme = Theme.of(context).colorScheme;
     return Container(
      width: 250,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        border: Border(
           right: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      child: const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            "Select a document to view options",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ),
      ),
     );
  }

  Widget _buildHeader(BuildContext context, AppState state) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'IST Document',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            state.selectedDocument ?? 'No Document',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildExpansionTile(
    BuildContext context, {
    required String title,
    required bool isExpanded,
    required VoidCallback onExpansionChanged,
    required List<Widget> children,
  }) {
    // Custom Expansion Tile look
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        initiallyExpanded: isExpanded,
        onExpansionChanged: (_) => onExpansionChanged(),
        childrenPadding: const EdgeInsets.only(left: 12),
        backgroundColor: Colors.transparent,
        collapsedBackgroundColor: Colors.transparent,
        children: children,
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, String title, String routeId, IconData icon) {
    var appState = context.read<AppState>();
    var isSelected = appState.currentRoute == routeId;
    var colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(right: 12, bottom: 4),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          dense: true,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          selected: isSelected,
          selectedTileColor: colorScheme.secondaryContainer,
          selectedColor: colorScheme.onSecondaryContainer,
          leading: Icon(icon, size: 20),
          title: Text(title),
          onTap: () => appState.navigateTo(routeId),
        ),
      ),
    );
  }
}
