import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

enum DocumentType {
  prescription,
  labReport,
  testResult,
  other
}

class OcrService {
  static final OcrService _instance = OcrService._internal();
  final ImagePicker _picker = ImagePicker();
  final TextRecognizer _textRecognizer = TextRecognizer();

  factory OcrService() {
    return _instance;
  }

  OcrService._internal();

  Future<String> processImage(XFile image, {DocumentType type = DocumentType.other}) async {
    try {
      final File imageFile = File(image.path);
      final InputImage inputImage = InputImage.fromFile(imageFile);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
      return recognizedText.text;
    } catch (e) {
      debugPrint('Error processing image: $e');
      return '';
    }
  }

  Future<XFile?> pickImage({ImageSource source = ImageSource.gallery}) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );
      return image;
    } catch (e) {
      debugPrint('Error picking image: $e');
      return null;
    }
  }

  String generatePromptForPatient(String text, DocumentType type) {
    switch (type) {
      case DocumentType.prescription:
        return '''As a patient-friendly medical assistant, please help me understand this prescription. 
Focus on:
1. Medications prescribed and their general purpose
2. Basic instructions on how to take them
3. Common side effects to be aware of
4. Important warnings or precautions
5. When to contact the doctor

Please explain in simple, non-technical language. DO NOT provide specific medical advice or change any prescribed instructions.

Here's the prescription text:
$text''';

      case DocumentType.labReport:
        return '''As a patient-friendly medical assistant, please help me understand this lab report. 
Focus on:
1. Basic explanation of what was tested
2. General meaning of the results
3. What normal ranges typically mean
4. When patients usually need this type of test
5. General lifestyle factors that might affect these results

Please explain in simple terms, avoiding medical jargon. DO NOT interpret specific results or provide medical advice.

Here's the lab report text:
$text''';

      case DocumentType.testResult:
        return '''As a patient-friendly medical assistant, please help me understand this test result. 
Focus on:
1. Basic explanation of what this test measures
2. General information about this type of test
3. Common reasons for getting this test
4. Lifestyle factors that might affect results
5. When to discuss results with a doctor

Please use simple language and avoid medical terminology. DO NOT interpret specific results or make recommendations.

Here's the test result text:
$text''';

      case DocumentType.other:
        return '''As a patient-friendly medical assistant, please help me understand this medical document. 
Focus on:
1. Type of document this appears to be
2. Basic explanation of its purpose
3. Key information a patient should know
4. General health concepts mentioned
5. What to discuss with healthcare providers

Please explain in simple terms. DO NOT provide specific medical advice or interpretations.

Here's the document text:
$text''';
    }
  }

  String generatePromptForDoctor(String text, DocumentType type) {
    switch (type) {
      case DocumentType.prescription:
        return '''As a medical professional's assistant, please analyze this prescription. 
Focus on:
1. Medications prescribed and their classes
2. Dosing regimens and duration
3. Potential drug interactions
4. Clinical considerations
5. Standard guidelines relevance

Please maintain medical accuracy and professional terminology. Include relevant medical references when possible.

Here's the prescription text:
$text''';

      case DocumentType.labReport:
        return '''As a medical professional's assistant, please analyze this lab report. 
Focus on:
1. Test parameters and their clinical significance
2. Result interpretation framework
3. Reference ranges and their context
4. Clinical correlation considerations
5. Follow-up testing indications

Please use medical terminology and cite relevant clinical guidelines where applicable.

Here's the lab report text:
$text''';

      case DocumentType.testResult:
        return '''As a medical professional's assistant, please analyze this test result. 
Focus on:
1. Test methodology and parameters
2. Clinical significance of results
3. Differential diagnostic considerations
4. Follow-up recommendations
5. Current guidelines context

Please maintain professional medical language and reference current medical literature when relevant.

Here's the test result text:
$text''';

      case DocumentType.other:
        return '''As a medical professional's assistant, please analyze this medical document. 
Focus on:
1. Document classification and purpose
2. Clinical relevance assessment
3. Key medical information
4. Healthcare protocol implications
5. Professional considerations

Please use appropriate medical terminology and reference relevant clinical guidelines.

Here's the document text:
$text''';
    }
  }

  void dispose() {
    _textRecognizer.close();
  }
}