# MCQ Checker App Demo

## Overview
This Flutter app allows users to capture or select images of MCQ answer sheets and send them to an n8n webhook for automated processing.

## Features Demonstrated

### 1. Camera Integration
- **Live Camera Preview**: Shows real-time camera feed
- **Photo Capture**: Large blue camera button to take pictures
- **Permission Handling**: Automatically requests camera permissions

### 2. Gallery Integration
- **Image Selection**: Gallery button to choose existing images
- **File Picker**: Supports common image formats (JPG, PNG)

### 3. Webhook Communication
- **HTTP POST**: Sends images as multipart form data
- **Real-time Processing**: Shows loading state during upload
- **Response Handling**: Displays results or error messages

### 4. User Interface
- **Modern Design**: Material Design 3 with blue theme
- **Responsive Layout**: Adapts to different screen sizes
- **Status Feedback**: Clear indication of app state

## How to Test

### Prerequisites
1. **n8n Workflow**: Ensure your n8n workflow is running
2. **Webhook URL**: Verify the webhook endpoint is accessible
3. **Device**: Use a physical device with camera (emulator won't work)

### Testing Steps

1. **Launch the App**
   ```bash
   flutter run
   ```

2. **Grant Permissions**
   - Allow camera access when prompted
   - Allow photo library access when prompted

3. **Test Camera**
   - Point camera at an MCQ answer sheet
   - Tap the large blue camera button
   - Watch for processing indicator

4. **Test Gallery**
   - Tap the "Gallery" button
   - Select an existing MCQ image
   - Watch for processing indicator

5. **View Results**
   - Check the results section below the camera
   - Results show the parsed MCQ data from n8n
   - Errors are displayed in red with details

## Expected n8n Workflow

Your n8n workflow should:

1. **Receive Image**: Webhook node accepts POST with image file
2. **Process OCR**: Google Cloud Vision extracts text
3. **Parse MCQ**: JavaScript code processes the extracted text
4. **Return Results**: Structured JSON with name, roll number, and answers

## Sample MCQ Format

The app expects MCQ answer sheets with this format:
```
Name: John Doe
Roll No: 12345

Q1: A
Q2: B
Q3: C
Q4: D
Q5: A
```

## Troubleshooting

### Common Issues

1. **Camera Not Working**
   - Check device permissions
   - Ensure physical device (not emulator)
   - Restart app after granting permissions

2. **Image Upload Fails**
   - Verify webhook URL in `lib/config.dart`
   - Check n8n workflow status
   - Ensure network connectivity

3. **No Results Displayed**
   - Check n8n workflow execution
   - Verify JavaScript code node output
   - Check webhook response format

### Debug Information

Enable debug mode for detailed logs:
```bash
flutter run --debug
```

## Configuration

### Webhook URL
Edit `lib/config.dart` to change the webhook endpoint:
```dart
static const String webhookUrl = 'YOUR_WEBHOOK_URL_HERE';
```

### Image Settings
Adjust image processing parameters in the same file:
```dart
static const int maxImageSize = 10 * 1024 * 1024; // 10MB
static const List<String> supportedImageFormats = ['jpg', 'jpeg', 'png'];
```

## Next Steps

1. **Test with Real MCQ Sheets**: Use actual handwritten answer sheets
2. **Customize Parsing**: Modify the JavaScript code in n8n for your format
3. **Add Storage**: Implement local result storage
4. **Enhance UI**: Add result history and comparison features
5. **Batch Processing**: Handle multiple images at once

## Support

For issues or questions:
1. Check the README.md for setup instructions
2. Verify n8n workflow configuration
3. Test webhook endpoint independently
4. Check Flutter and device logs 