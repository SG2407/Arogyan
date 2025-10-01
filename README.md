# Aarogyan: A Unified AI-Powered Medical &Wellness Platform 🏥

A modern healthcare assistance platform built with Flutter, designed to connect patients with doctors through an intuitive and accessible interface.

## Features ✨

- **Dual User Roles**: Separate interfaces for doctors and patients
- **AI-Powered Assistance**: Intelligent health-related queries and recommendations
- **OCR Integration**: Text recognition for medical documents
- **Speech-to-Text**: Voice input support for accessibility
- **Modern UI**: Clean and intuitive interface with material design
- **Secure Authentication**: Role-based authentication system

## Getting Started 🚀

### Prerequisites

- Flutter SDK (>=3.1.0)
- Dart SDK
- Android Studio / VS Code
- Git

### Installation

1. Clone the repository
```bash
git clone https://github.com/SG2407/Arogyan.git
```

2. Navigate to project directory
```bash
cd Arogyan
```

3. Install dependencies
```bash
flutter pub get
```

4. Set up environment variables
```bash
cp .env.example .env
```
Then edit `.env` file with your API keys and configuration.

5. Run the app
```bash
flutter run
```

## Tech Stack 💻

- **Framework**: Flutter
- **Language**: Dart
- **State Management**: Provider
- **Navigation**: GoRouter
- **AI Integration**: Groq API
- **ML Features**: Google ML Kit
- **UI Components**: Material Design, Custom Widgets

## Project Structure 📁

```
lib/
├── main.dart
├── models/
├── providers/
├── screens/
│   ├── auth/
│   ├── doctor/
│   ├── patient/
│   └── common/
├── services/
│   ├── ai/
│   ├── ocr/
│   └── speech/
└── widgets/
```

## Environment Variables 🔐

Create a `.env` file in the root directory with the following variables:
```
GRK_API_KEY=your_groq_api_key_here
```

## Contributing 🤝

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License 📄

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments 🙏

- Flutter team for the amazing framework
- Groq for AI capabilities
- Google ML Kit for OCR functionality
- All contributors and supporters

## Contact 📱

Project Link: [https://github.com/SG2407/Arogyan](https://github.com/SG2407/Arogyan)

---

<div align="center">
Made with ❤️ using Flutter
</div>
