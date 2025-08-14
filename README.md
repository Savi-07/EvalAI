# 🧠 EvalAI - MCQ Checker App

A **cross-platform Flutter application** for smart exam evaluation. Capture or select images of MCQ answer sheets and get instant results via an integrated [n8n](https://n8n.io/) workflow powered by **Google Gemini**.

---

## 🚀 Features

- 📷 **Camera Integration**  
  Take photos of answer sheets directly in the app.

- 🖼️ **Gallery Selection**  
  Pick existing images from your device.

- 🌐 **Webhook Automation**  
  Images are sent to your n8n workflow for processing via a `/mcq-checker` webhook.

- 🤖 **AI-Powered Extraction**  
  Google Gemini model (`models/gemini-2.5-pro`) analyzes the image to extract:
  - Name  
  - Roll number  
  - Email  
  - Correct answers  
  - Total questions  
  - Marks obtained  
  - Percentage  

- 📦 **Structured Output Parsing**  
  AI output is validated against a defined JSON schema.

- ⚡ **Real-time Results**  
  App instantly receives parsed MCQ scores.

- 📧 **Automated Email Sending**  
  Sends a result email with pass/fail status based on percentage.

- 🎨 **Modern UI**  
  Responsive Material Design with a clean, intuitive interface.

- 🖥️ **Multi-platform**  
  Works on **Android**, **iOS**, **macOS**, **Windows**, **Linux**, and **Web**.

---

## 📁 Folder Structure

```
lib/
  ├── config.dart           # App configuration (webhook URL, settings)
  ├── main.dart             # App entry point
  ├── models/               # Data models (MCQ results, responses)
  ├── screens/              # UI screens (upload, results, etc.)
  └── widgets/              # Reusable UI components

assets/
  └── images/               # App icons and images

android/, ios/, macos/, linux/, windows/, web/
  └── Platform-specific setup and resources

quiz_automation.json        # n8n workflow definition
pubspec.yaml                # Dependencies and assets
README.md                   # Project documentation
LICENSE                     # MIT License
```

---

## 🛠️ Setup Instructions

1. **Install Dependencies**
   ```bash
   flutter pub get
   ```

2. **Configure Webhook and App Info**  
   Edit [`lib/config.dart`](lib/config.dart) and update the following fields:

   ```dart
   import 'package:flutter/material.dart';

   class AppConfig {
     // n8n Webhook Configuration
     static const String webhookUrl = 'YOUR_WEBHOOK_URL';

     // App Settings
     static const String appName = 'YOUR_APP_NAME';
     static const String appSubtitle = 'YOUR_APP_SUBTITLE';
     static const String appVersion = '1.0.0';

     // Camera Settings
     static const int maxImageSize = 10 * 1024 * 1024; // 10MB
     static const List<String> supportedImageFormats = ['jpg', 'jpeg', 'png'];

     // UI Settings
     static const double cameraPreviewAspectRatio = 4 / 3;
     static const Duration processingTimeout = Duration(seconds: 30);

     // Colors
     static const Color primaryColor = Colors.red;
     static const Color secondaryColor = Colors.blue;
   }
   ```

3. **Run the App**
   ```bash
   flutter run
   ```

---

## 🤖 How It Works (n8n Workflow Steps)

1. **Webhook**  
   Listens for a **POST** request on `/mcq-checker` and receives the image.

2. **Google Gemini Chat Model**  
   Uses `models/gemini-2.5-pro` to process the uploaded answer sheet image.

3. **Basic LLM Chain**  
   AI extracts required details from the image: name, roll number, email, answers, score, and percentage.

4. **Structured Output Parser**  
   Ensures AI output matches the expected JSON structure.

5. **Respond to Webhook**  
   Sends a JSON response back to the app with all extracted details.  
   If email is missing, uses a default email.

6. **Send a Message (Gmail)**  
   Emails the results to the extracted or default email address.  
   Includes pass/fail status depending on the percentage.

---

## 🔍 Visual Workflow Diagram

<img width="1058" height="505" alt="{46EC7F99-B9D1-4FB7-B4A5-9BCDE80C8A0A}" src="https://github.com/user-attachments/assets/c5b233dc-e401-4f1e-82c4-331386c113bd" />


---

## 📦 Tech Stack

- **Flutter** (Dart)
- **n8n** (Workflow Automation)
- **Google Gemini** (AI Processing)
- **Material Design**

---

## 🔮 Future Enhancements

- Local storage of MCQ results
- Result history and comparison
- Batch processing of multiple images
- Export results to various formats

---

## 📝 License

MIT License © 2025 Sahil Kumar Singh

---

> _Smart. Fast. Automated. Exams._
