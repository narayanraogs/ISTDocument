import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../data/subsystem_models.dart';
import '../providers/app_state.dart';
import '../services/api_service.dart';

class SubsystemInfoScreen extends StatefulWidget {
  const SubsystemInfoScreen({super.key});

  @override
  State<SubsystemInfoScreen> createState() => _SubsystemInfoScreenState();
}

class _SubsystemInfoScreenState extends State<SubsystemInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  // Controllers
  final _satelliteNameController = TextEditingController();
  final _satelliteClassController = TextEditingController();
  final _subsystemNameController = TextEditingController();
  
  Uint8List? _imageData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _satelliteNameController.dispose();
    _satelliteClassController.dispose();
    _subsystemNameController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final appState = context.read<AppState>();
    if (appState.selectedDocument == null) return;

    setState(() => _isLoading = true);

    final response = await _apiService.getSubsystemDetails(
        appState.clientId, appState.selectedDocument!);

    if (mounted) {
      if (response.ok) {
        _satelliteNameController.text = response.satelliteName;
        _satelliteClassController.text = response.satelliteClass;
        _subsystemNameController.text = response.subsystemName;
        
        if (response.satelliteImage.isNotEmpty) {
          try {
             _imageData = base64Decode(response.satelliteImage);
          } catch (e) {
            debugPrint('Error decoding image: $e');
          }
        }
      }
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result != null) {
      setState(() {
         _imageData = result.files.single.bytes;
      });
    }
  }

  Future<void> _saveData() async {
    if (!_formKey.currentState!.validate()) return;

    final appState = context.read<AppState>();
    if (appState.selectedDocument == null) return;

    final details = SubsystemDetails(
      satelliteName: _satelliteNameController.text,
      satelliteClass: _satelliteClassController.text,
      subsystemName: _subsystemNameController.text,
      satelliteImage: _imageData != null ? base64Encode(_imageData!) : '',
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Saving...')),
    );

    final result = await _apiService.addSubsystemDetails(
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
        constraints: const BoxConstraints(maxWidth: 600),
        padding: const EdgeInsets.all(24.0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                   Text(
                    'Subsystem Information',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 24),
                  
                  TextFormField(
                    controller: _satelliteNameController,
                    decoration: const InputDecoration(
                      labelText: 'Satellite Name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.satellite_alt),
                    ),
                    validator: (v) => v?.isEmpty == true ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: _satelliteClassController,
                    decoration: const InputDecoration(
                      labelText: 'Satellite Class',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.class_outlined),
                    ),
                    validator: (v) => v?.isEmpty == true ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: _subsystemNameController,
                    decoration: const InputDecoration(
                      labelText: 'Subsystem Name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.settings_input_component),
                    ),
                    validator: (v) => v?.isEmpty == true ? 'Required' : null,
                  ),
                  const SizedBox(height: 24),

                  _buildImageSection(),
                  
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

  Widget _buildImageSection() {
     return Column(
       crossAxisAlignment: CrossAxisAlignment.start,
       children: [
         Text('Satellite Image', style: Theme.of(context).textTheme.titleSmall),
         const SizedBox(height: 8),
         Container(
           height: 200,
           width: double.infinity,
           decoration: BoxDecoration(
             border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
             borderRadius: BorderRadius.circular(8),
             color: Theme.of(context).colorScheme.surfaceContainerHighest,
           ),
           child: _imageData != null
               ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.memory(
                    _imageData!,
                    fit: BoxFit.contain,
                  ),
                 )
               : Center(
                   child: Column(
                     mainAxisSize: MainAxisSize.min,
                     children: [
                       const Icon(Icons.image_not_supported_outlined, size: 48, color: Colors.grey),
                       const SizedBox(height: 8),
                       Text('No image selected', style: Theme.of(context).textTheme.bodyMedium),
                     ],
                   ),
                 ),
         ),
         const SizedBox(height: 8),
         OutlinedButton.icon(
           onPressed: _pickImage,
           icon: const Icon(Icons.upload),
           label: const Text('Browse Image'),
         ),
       ],
     );
  }
}
