import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../widgets/sidebar.dart';
import '../services/api_service.dart';
import 'document_info_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch state to decide layout
    var appState = context.watch<AppState>();

    // If no document is selected, show the selection dashboard
    // Otherwise show the editor layout
    if (appState.selectedDocument == null) {
      return const DashboardScreen();
    }

    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          if (appState.isSidebarVisible) const Sidebar(),
          
          // Vertical Divider
          if (appState.isSidebarVisible) const VerticalDivider(width: 1),

          // Main Content Area
          Expanded(
            child: Column(
              children: [
                // Top Bar (Breadcrumbs / Toggle Sidebar)
                _buildTopBar(context, appState),
                const Divider(height: 1),

                // Content View
                Expanded(
                  child: Container(
                    color: Theme.of(context).colorScheme.surface,
                    child: _buildContent(appState.currentRoute),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(String route) {
    switch (route) {
      case 'info_document':
        return const DocumentInfoScreen();
      // Add other cases here
      default:
        return Center(
          child: Text('Content for: $route'),
        );
    }
  }

  Widget _buildTopBar(BuildContext context, AppState state) {
    return SizedBox(
      height: 56,
      child: Row(
        children: [
          IconButton(
            icon: Icon(state.isSidebarVisible ? Icons.menu_open : Icons.menu),
            onPressed: () => state.toggleSidebar(),
            tooltip: 'Toggle Sidebar',
          ),
          const SizedBox(width: 16),
          // Breadcrumbs could go here
          Text(
            state.currentRoute.toUpperCase().replaceAll('_', ' '),
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const Spacer(),
          // User / Actions
          IconButton(
            icon: Icon(state.themeMode == ThemeMode.light
                ? Icons.dark_mode_outlined
                : Icons.light_mode_outlined),
            onPressed: () => state.toggleTheme(),
            tooltip: 'Toggle Theme',
          ),
          const SizedBox(width: 8),
          const CircleAvatar(
             radius: 16,
             child: Icon(Icons.person, size: 20),
          ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ApiService _apiService = ApiService();
  List<String> _allDocuments = [];
  List<String> _filteredDocuments = [];
  bool _isLoading = true;
  String _errorMessage = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchDocuments();
    _searchController.addListener(_filterDocuments);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchDocuments() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final appState = context.read<AppState>();
    final response = await _apiService.getAllDocumentNames(appState.clientId);

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (response.ok) {
          _allDocuments = response.documentNames;
          _filteredDocuments = _allDocuments;
        } else {
          _errorMessage = response.message;
        }
      });
    }
  }

  void _filterDocuments() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredDocuments = _allDocuments
          .where((doc) => doc.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IST Document Manager'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchDocuments,
            tooltip: 'Refresh',
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showAddDocumentDialog(context);
        },
        icon: const Icon(Icons.add),
        label: const Text('New Document'),
      ),
    );
  }

  void _showAddDocumentDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create New Document'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Document Name',
              hintText: 'Enter Project-Subsystem-version',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
            textCapitalization: TextCapitalization.words,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isEmpty) return;

                Navigator.pop(context); // Close dialog
                
                // Show loading indicator
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Creating document...')),
                );

                final appState = context.read<AppState>();
                final result = await _apiService.addDocument(appState.clientId, name);

                if (context.mounted) {
                   ScaffoldMessenger.of(context).hideCurrentSnackBar();
                   if (result.ok) {
                     ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(result.message), backgroundColor: Colors.green),
                     );
                     _fetchDocuments(); // Refresh list
                   } else {
                     ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(result.message), backgroundColor: Colors.red),
                     );
                   }
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: $_errorMessage'),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _fetchDocuments,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search documents...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
            ),
          ),
        ),

        // Document List
        Expanded(
          child: _filteredDocuments.isEmpty
              ? _buildEmptyState()
              : _buildDocumentGrid(),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.folder_open, size: 64, color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 16),
          Text(
            _allDocuments.isEmpty
                ? 'No documents found'
                : 'No matching documents',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Adapt grid count based on width
        int crossAxisCount = 1;
        if (constraints.maxWidth > 1200) {
          crossAxisCount = 4;
        } else if (constraints.maxWidth > 900) {
          crossAxisCount = 3;
        } else if (constraints.maxWidth > 600) {
          crossAxisCount = 2;
        }

        return GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 2.5, // Wider cards
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: _filteredDocuments.length,
          itemBuilder: (context, index) {
            final docName = _filteredDocuments[index];
            return Card(
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  context.read<AppState>().selectDocument(docName);
                },
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.description,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              docName,
                              style: Theme.of(context).textTheme.titleMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Tap to open',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
