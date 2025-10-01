import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

enum UserRole {
  doctor,
  patient,
}

class AiService {
  static String get _apiKey => dotenv.env['GRK_API_KEY'] ?? '';
  static const String _baseUrl =
      'https://api.groq.com/openai/v1/chat/completions';
  static const String _model = 'meta-llama/llama-4-scout-17b-16e-instruct';
  static http.Client? _client;

  static http.Client get client {
    _client ??= http.Client();
    return _client!;
  }

  static void dispose() {
    _client?.close();
    _client = null;
  }

  static Future<String> getAiResponse(String message, UserRole role) async {
    try {
      final response = await client.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {
              'role': 'system',
              'content': _getSystemPrompt(role),
            },
            {
              'role': 'user',
              'content': message,
            },
          ],
          'max_tokens': 500,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['choices'] != null &&
            data['choices'].isNotEmpty &&
            data['choices'][0]['message'] != null &&
            data['choices'][0]['message']['content'] != null) {
          return data['choices'][0]['message']['content'];
        } else {
          throw Exception('Invalid response format from AI service');
        }
      } else {
        final error = jsonDecode(response.body);
        print('AI Service Error: ${error.toString()}');
        throw Exception('Failed to get AI response: ${response.statusCode}');
      }
    } catch (e) {
      print('AI Service Exception: ${e.toString()}');
      return 'Sorry, I encountered an error. Please try again later. Error: ${e.toString()}';
    }
  }

  static String _getSystemPrompt(UserRole role) {
    switch (role) {
      case UserRole.doctor:
        return '''You are an advanced medical AI assistant designed to help healthcare professionals. 
Your role is to:
1. Provide evidence-based medical information and research
2. Assist in analyzing patient symptoms and diagnostic possibilities
3. Suggest treatment approaches based on current medical guidelines
4. Help with medical documentation and case analysis
5. NEVER make final diagnostic decisions
6. ALWAYS remind that final medical decisions must be made by the healthcare professional

Constraints:
- Only respond to medical queries
- Provide scientific references when possible
- Maintain medical accuracy and professional tone
- Flag any emergency situations
- Acknowledge limitations and uncertainties''';

      case UserRole.patient:
        return '''You are a friendly healthcare guide designed to help patients understand their health better. 
Your role is to:
1. Provide general health information in simple, understandable terms
2. Guide patients to seek appropriate medical care when needed
3. Explain common medical terms and procedures
4. Promote healthy lifestyle choices
5. NEVER provide specific medical diagnoses
6. NEVER prescribe medications or treatments

Constraints:
- Always encourage consulting healthcare providers for specific medical advice
- Use simple, non-technical language
- Emphasize the importance of professional medical care
- NEVER provide emergency medical advice
- Direct users to emergency services for urgent situations''';
    }
  }

  static bool isHealthRelatedQuery(String query) {
    // List of health-related keywords to filter queries
    final healthKeywords = [
      // General health
      'health',
      'medical',
      'doctor',
      'hospital',
      'symptoms',
      'pain',
      'disease',
      'treatment',
      'diagnosis',
      'medication',
      'therapy',
      'medicine',
      'clinic',
      'emergency',
      'prescription',
      'surgery',
      'exam',
      'test',
      'blood',
      'heart',
      'brain',
      'lung',
      'cancer',
      'diabetes',
      'allergy',
      'dental',
      'diet',
      'exercise',
      'nutrition',
      'wellness',
      'mental health',
      'anxiety',
      'depression',
      'vaccine',
      'virus',
      'infection',
      'injury',
      'specialist',
      'nurse',
      'pharmacy',
      'insurance',
      'appointment',

      // Common illnesses
      'flu',
      'fever',
      'cold',
      'cough',
      'headache',
      'migraine',
      'stomachache',
      'ulcer',
      'asthma',
      'hypertension',
      'stroke',
      'arthritis',
      'cholesterol',
      'obesity',
      'malaria',
      'typhoid',
      'tuberculosis',
      'hepatitis',
      'jaundice',
      'pneumonia',
      'covid',
      'covid-19',
      'coronavirus',
      'sars',
      'influenza',
      'eczema',
      'psoriasis',
      'bronchitis',
      'sinus',
      'tonsillitis',

      // Symptoms
      'nausea',
      'vomiting',
      'diarrhea',
      'constipation',
      'dizziness',
      'fatigue',
      'weakness',
      'shortness of breath',
      'palpitation',
      'swelling',
      'rash',
      'itching',
      'sore throat',
      'runny nose',
      'sneezing',
      'chills',
      'sweating',
      'loss of appetite',
      'weight loss',
      'blurred vision',
      'chest pain',
      'back pain',
      'joint pain',
      'muscle pain',
      'earache',
      'eye pain',
      'insomnia',

      // Treatments & Procedures
      'x-ray',
      'mri',
      'ct scan',
      'ultrasound',
      'biopsy',
      'dialysis',
      'chemotherapy',
      'radiation',
      'transplant',
      'vaccination',
      'physiotherapy',
      'rehabilitation',
      'checkup',
      'screening',
      'operation',
      'stitches',
      'bandage',
      'first aid',

      // Medicines & Substances
      'antibiotic',
      'analgesic',
      'antiviral',
      'antifungal',
      'antiseptic',
      'tablet',
      'capsule',
      'syrup',
      'injection',
      'ointment',
      'cream',
      'drops',
      'painkiller',
      'paracetamol',
      'ibuprofen',
      'aspirin',
      'insulin',

      // Body parts
      'eye',
      'ear',
      'nose',
      'throat',
      'mouth',
      'tooth',
      'skin',
      'bone',
      'muscle',
      'joint',
      'stomach',
      'kidney',
      'liver',
      'pancreas',
      'intestine',
      'spine',
      'nerves',

      // Miscellaneous
      'ambulance',
      'ward',
      'icu',
      'ot',
      'blood pressure',
      'sugar',
      'pulse',
      'oxygen',
      'therapy session',
      'counseling',
      'checkup',
      'health record',
      'symptom tracker',
    ];

    final lowerQuery = query.toLowerCase();
    return healthKeywords.any((keyword) => lowerQuery.contains(keyword));
  }
}
