import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/models.dart';
import '../providers/app_state.dart';
import '../services/api_service.dart';

class DocumentInfoScreen extends StatefulWidget {
  const DocumentInfoScreen({super.key});

  @override
  State<DocumentInfoScreen> createState() => _DocumentInfoScreenState();
}

class _DocumentInfoScreenState extends State<DocumentInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  // Controllers
  final _documentNoController = TextEditingController();
  final _preparedByController = TextEditingController();
  final _reviewedByNameController = TextEditingController();
  final _reviewedByTitleController = TextEditingController();
  final _firstApproverNameController = TextEditingController();
  final _firstApproverTitleController = TextEditingController();
  final _secondApproverNameController = TextEditingController();
  final _secondApproverTitleController = TextEditingController();

  bool _eidRequired = true;
  bool _resultFormatRequired = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _documentNoController.dispose();
    _preparedByController.dispose();
    _reviewedByNameController.dispose();
    _reviewedByTitleController.dispose();
    _firstApproverNameController.dispose();
    _firstApproverTitleController.dispose();
    _secondApproverNameController.dispose();
    _secondApproverTitleController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final appState = context.read<AppState>();
    if (appState.selectedDocument == null) return;

    setState(() => _isLoading = true);

    final response = await _apiService.getDocumentDetails(
        appState.clientId, appState.selectedDocument!);

    if (mounted) {
      if (response.ok && response.details != null) {
        final d = response.details!;
        _documentNoController.text = d.documentNumber;
        _preparedByController.text = d.preparedBy;
        _reviewedByNameController.text = d.reviewedByName;
        _reviewedByTitleController.text = d.reviewedByTitle;
        _firstApproverNameController.text = d.firstApproverName;
        _firstApproverTitleController.text = d.firstApproverTitle;
        _secondApproverNameController.text = d.secondApproverName;
        _secondApproverTitleController.text = d.secondApproverTitle;
        _eidRequired = d.eidRequired;
        _resultFormatRequired = d.resultFormatRequired;
      }
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveData() async {
    if (!_formKey.currentState!.validate()) return;

    final appState = context.read<AppState>();
    if (appState.selectedDocument == null) return;

    final details = DocumentDetails(
      documentNumber: _documentNoController.text,
      preparedBy: _preparedByController.text,
      reviewedByName: _reviewedByNameController.text,
      reviewedByTitle: _reviewedByTitleController.text,
      firstApproverName: _firstApproverNameController.text,
      firstApproverTitle: _firstApproverTitleController.text,
      secondApproverName: _secondApproverNameController.text,
      secondApproverTitle: _secondApproverTitleController.text,
      eidRequired: _eidRequired,
      resultFormatRequired: _resultFormatRequired,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Saving...')),
    );

    final result = await _apiService.addDocumentDetails(
        appState.clientId, appState.selectedDocument!, details);

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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800),
        padding: const EdgeInsets.all(24.0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                   Text(
                    'Document Information',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 24),
                  
                  // Row 1
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _documentNoController,
                          decoration: const InputDecoration(
                            labelText: 'Document Number',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.numbers),
                          ),
                          validator: (v) => v?.isEmpty == true ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _preparedByController,
                          decoration: const InputDecoration(
                            labelText: 'Prepared By',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          validator: (v) => v?.isEmpty == true ? 'Required' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _buildSectionHeader('Reviewer'),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _reviewedByNameController,
                          decoration: const InputDecoration(
                            labelText: 'Name',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) => v?.isEmpty == true ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _reviewedByTitleController,
                          decoration: const InputDecoration(
                            labelText: 'Title',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) => v?.isEmpty == true ? 'Required' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _buildSectionHeader('First Approver'),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _firstApproverNameController,
                          decoration: const InputDecoration(
                            labelText: 'Name',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) => v?.isEmpty == true ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _firstApproverTitleController,
                          decoration: const InputDecoration(
                            labelText: 'Title',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) => v?.isEmpty == true ? 'Required' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _buildSectionHeader('Second Approver'),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _secondApproverNameController,
                          decoration: const InputDecoration(
                            labelText: 'Name',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) => v?.isEmpty == true ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _secondApproverTitleController,
                          decoration: const InputDecoration(
                            labelText: 'Title',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) => v?.isEmpty == true ? 'Required' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  SwitchListTile(
                    title: const Text('EID Required'),
                    value: _eidRequired,
                    onChanged: (v) => setState(() => _eidRequired = v),
                  ),
                  SwitchListTile(
                    title: const Text('Result Format Required'),
                    value: _resultFormatRequired,
                    onChanged: (v) => setState(() => _resultFormatRequired = v),
                  ),

                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      FilledButton.icon(
                        onPressed: _saveData,
                        icon: const Icon(Icons.save),
                        label: const Text('Save Details'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
