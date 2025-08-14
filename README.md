# MCQ Checker App

A Flutter application that captures or selects images of MCQ answer sheets and sends them to an n8n webhook for automated processing using Google Cloud Vision API.

## Features

- **Camera Integration**: Take photos directly within the app
- **Gallery Selection**: Choose existing images from device gallery
- **Webhook Integration**: Automatically sends images to your n8n workflow
- **Real-time Results**: Displays processed MCQ results from the webhook
- **Cross-platform**: Works on both Android and iOS

## Prerequisites

1. **Flutter SDK**: Ensure you have Flutter installed and configured
2. **n8n Workflow**: Your n8n workflow should be set up with:
   - Webhook node (receiving images)
   - Google Cloud Vision API node (OCR processing)
   - JavaScript code node (MCQ parsing)
   - Response handling

## Setup Instructions

### 1. Install Dependencies

```bash
flutter pub get
```

### 2. Platform-specific Setup

#### Android
- Camera and storage permissions are automatically added to `AndroidManifest.xml`
- No additional configuration needed

#### iOS
- Camera and photo library usage descriptions are automatically added to `Info.plist`
- No additional configuration needed

### 3. Configure Webhook URL

The app is configured to send images to:
```
https://savi-07.app.n8n.cloud/webhook-test/mcq-checker
```

To change this URL, modify the `_sendImageToWebhook` method in `lib/main.dart`.

### 4. Build and Run

```bash
# For Android
flutter run

# For iOS
flutter run -d ios

# For web
flutter run -d chrome
```

## How It Works

1. **Image Capture/Selection**: User takes a photo or selects from gallery
2. **Image Processing**: App prepares the image for webhook transmission
3. **Webhook Request**: Image is sent as multipart form data to n8n
4. **n8n Processing**: Your workflow processes the image using Google Cloud Vision
5. **Result Display**: Processed MCQ results are displayed in the app

## Expected n8n Workflow

Your n8n workflow should include:

1. **Webhook Node**: Receives POST requests with image files
2. **Google Cloud Vision Node**: Extracts text from the image
3. **JavaScript Code Node**: Parses MCQ answers using your provided code
4. **Response Node**: Returns structured JSON with name, roll number, and answers

## JavaScript Code for n8n

```javascript
// Extract the full text returned by Google Vision API
const text = $json.responses[0].fullTextAnnotation.text;

// Match "Name" and "Roll No" from the OCR text
const nameMatch = text.match(/Name:\s*(.+)/i);
const rollMatch = text.match(/Roll\s*No:\s*(\d+)/i);

// Extract answers like "Q1: A", "Q2: C", etc.
const answers = {};
text.split('\n').forEach(line => {
  const match = line.match(/Q\s*(\d+):\s*([A-D])/i);
  if (match) {
    answers[match[1]] = match[2].toUpperCase();
  }
});

// Output structured JSON
return {
  name: nameMatch ? nameMatch[1].trim() : null,
  rollNo: rollMatch ? rollMatch[1] : null,
  answers: answers
};
```

## Troubleshooting

### Common Issues

1. **Camera Permission Denied**: Ensure camera permissions are granted in device settings
2. **Image Upload Fails**: Check your n8n webhook URL and network connectivity
3. **Build Errors**: Run `flutter clean` and `flutter pub get` to resolve dependency issues

### Debug Mode

Enable debug mode to see detailed logs:
```bash
flutter run --debug
```

## Future Enhancements

- [ ] Local storage of MCQ results
- [ ] Result history and comparison
- [ ] Batch processing of multiple images
- [ ] Export results to various formats
- [ ] Offline mode with local OCR processing

## License

This project is open source and available under the MIT License.
