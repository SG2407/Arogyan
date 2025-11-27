import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:aarogyan/services/ocr/ocr_service.dart';
import 'package:aarogyan/services/ai/ai_service.dart';

class PatientDocumentAnalysisTab extends StatefulWidget {
  const PatientDocumentAnalysisTab({Key? key}) : super(key: key);

  @override
  State<PatientDocumentAnalysisTab> createState() =>
      _PatientDocumentAnalysisTabState();
}

class _PatientDocumentAnalysisTabState
    extends State<PatientDocumentAnalysisTab> {
  final OcrService _ocrService = OcrService();
  bool _isProcessing = false;
  String _extractedText = '';
  String _explanation = '';
  DocumentType _selectedType = DocumentType.prescription;

  Future<void> _processDocument(ImageSource source) async {
    final image = await _ocrService.pickImage(source: source);
    if (image == null) return;

    setState(() {
      _isProcessing = true;
      _extractedText = '';
      _explanation = '';
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
      final prompt = _ocrService.generatePromptForPatient(text, _selectedType);
      final explanation =
          await AiService.getAiResponse(prompt, UserRole.patient);

      setState(() {
        _explanation = explanation;
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Document Analysis'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/patient');
            }
          },
          tooltip: 'Go back',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                  value: DocumentType.prescription,
                  child: Text('Prescription'),
                ),
                DropdownMenuItem(
                  value: DocumentType.labReport,
                  child: Text('Lab Report'),
                ),
                DropdownMenuItem(
                  value: DocumentType.other,
                  child: Text('Other Medical Document'),
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
            if (_isProcessing)
              const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Processing document...'),
                  ],
                ),
              )
            else
              Column(
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
                  if (_explanation.isNotEmpty) ...[
                    Text(
                      'Simple Explanation:',
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
                        _explanation,
                        style: TextStyle(
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }
}
