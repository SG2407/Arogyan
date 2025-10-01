import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:aarogyan/services/ocr/ocr_service.dart';
import 'package:aarogyan/services/ai/ai_service.dart';

class DoctorDocumentAnalysisTab extends StatefulWidget {
  const DoctorDocumentAnalysisTab({Key? key}) : super(key: key);

  @override
  State<DoctorDocumentAnalysisTab> createState() =>
      _DoctorDocumentAnalysisTabState();
}

class _DoctorDocumentAnalysisTabState extends State<DoctorDocumentAnalysisTab> {
  final OcrService _ocrService = OcrService();
  bool _isProcessing = false;
  String _extractedText = '';
  String _analysis = '';
  DocumentType _selectedType = DocumentType.labReport;

  Future<void> _processDocument(ImageSource source) async {
    final image = await _ocrService.pickImage(source: source);
    if (image == null) return;

    setState(() {
      _isProcessing = true;
      _extractedText = '';
      _analysis = '';
    });

    try {
      final text = await _ocrService.processImage(image, type: _selectedType);
      if (text.isEmpty) {
        _showError('Could not extract text from the document');
        return;
      }

      setState(() {
        _extractedText = text;
      });

      // Generate prompt for AI analysis
      final prompt = _ocrService.generatePromptForDoctor(text, _selectedType);
      final analysis = await AiService.getAiResponse(prompt, UserRole.doctor);

      setState(() {
        _analysis = analysis;
        _isProcessing = false;
      });
    } catch (e) {
      _showError('Error processing document: $e');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Medical Document Analysis',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<DocumentType>(
            value: _selectedType,
            decoration: InputDecoration(
              labelText: 'Document Type',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items: const [
              DropdownMenuItem(
                value: DocumentType.labReport,
                child: Text('Lab Report'),
              ),
              DropdownMenuItem(
                value: DocumentType.testResult,
                child: Text('Test Results'),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedType = value;
                });
              }
            },
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: _isProcessing
                    ? null
                    : () => _processDocument(ImageSource.camera),
                icon: const Icon(Icons.camera_alt),
                label: const Text('Take Photo'),
              ),
              ElevatedButton.icon(
                onPressed: _isProcessing
                    ? null
                    : () => _processDocument(ImageSource.gallery),
                icon: const Icon(Icons.photo_library),
                label: const Text('Upload Document'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: _isProcessing
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Analyzing document...'),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_extractedText.isNotEmpty) ...[
                          Text(
                            'Extracted Text:',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceVariant,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(_extractedText),
                          ),
                          const SizedBox(height: 24),
                        ],
                        if (_analysis.isNotEmpty) ...[
                          Text(
                            'Clinical Analysis:',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _analysis,
                              style: TextStyle(
                                color: colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
