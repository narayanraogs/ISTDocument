import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../services/api_service.dart';

class GenerateScreen extends StatefulWidget {
  final bool isSignature;

  const GenerateScreen({super.key, required this.isSignature});

  @override
  State<GenerateScreen> createState() => _GenerateScreenState();
}

class _GenerateScreenState extends State<GenerateScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  String? _statusMessage;
  bool _isSuccess = false;

  Future<void> _generate() async {
    final appState = context.read<AppState>();
    if (appState.selectedDocument == null) return;

    setState(() {
      _isLoading = true;
      _statusMessage = "Generating ${widget.isSignature ? 'Signature Page' : 'Full PDF'}...";
      _isSuccess = false;
    });

    try {
      final response = widget.isSignature
          ? await _apiService.getSignaturePage(appState.clientId, appState.selectedDocument!)
          : await _apiService.compileDocument(appState.clientId, appState.selectedDocument!);

      if (response.ok && response.content.isNotEmpty) {
        _downloadPdf(response.content, widget.isSignature ? "Signature_Page.pdf" : "${appState.selectedDocument}.pdf");
        setState(() {
          _statusMessage = "Generation Successful! Download started.";
          _isSuccess = true;
        });
      } else {
        setState(() {
          _statusMessage = "Error: ${response.content}";
          _isSuccess = false;
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = "Error: $e";
        _isSuccess = false;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _downloadPdf(String base64Content, String fileName) {
    try {
      final bytes = base64Decode(base64Content);
      final blob = html.Blob([bytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute("download", fileName)
        ..click();
      html.Url.revokeObjectUrl(url);
    } catch (e) {
      debugPrint("Download failed: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.all(32),
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.isSignature ? Icons.draw : Icons.picture_as_pdf,
                size: 64,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 24),
              Text(
                widget.isSignature ? "Generate Signature Page" : "Generate Full Document",
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                "Click the button below to compile and download the ${widget.isSignature ? 'signature page' : 'complete document PDF'}.",
                 textAlign: TextAlign.center,
                 style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),
              if (_isLoading)
                const CircularProgressIndicator()
              else
                ElevatedButton.icon(
                  onPressed: _generate,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                  icon: const Icon(Icons.download),
                  label: const Text("Generate & Download"),
                ),
              if (_statusMessage != null) ...[
                const SizedBox(height: 24),
                Text(
                  _statusMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _isSuccess ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
