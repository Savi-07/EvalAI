import 'dart:math';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';
import 'package:http_parser/http_parser.dart';
import '../config.dart';
import '../models/mcq_result.dart';
import '../widgets/app_header.dart';
import '../widgets/result_popup.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  bool _isProcessing = false;
  MCQResponse? _lastResult;
  String? _errorMessage;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    // Check permissions when app starts
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    try {
      // Check current permission status
      final photosStatus = await Permission.photos.status;
      final storageStatus = await Permission.storage.status;
      final cameraStatus = await Permission.camera.status;

      // Request permissions if not granted
      if (photosStatus.isDenied) {
        await Permission.photos.request();
      }
      if (storageStatus.isDenied) {
        await Permission.storage.request();
      }
      if (cameraStatus.isDenied) {
        await Permission.camera.request();
      }

      // Also try to request media permissions for newer Android versions
      try {
        if (await Permission.photos.status.isDenied) {
          await Permission.photos.request();
        }
      } catch (e) {
        // Photos permission might not be available on older Android versions
      }

      // Force refresh permission status
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {}); // Trigger rebuild to update permission status display
    } catch (e) {
      // Handle permission check errors silently
    }
  }

  Future<void> _takePhoto() async {
    try {
      // Request camera permission only when needed
      final status = await Permission.camera.request();
      if (status.isDenied || status.isPermanentlyDenied) {
        setState(() {
          _errorMessage = 'Camera permission is required to take photos';
        });
        return;
      }

      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _errorMessage = null;
        });
        await _uploadImage();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to take photo: $e';
      });
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      // Check current permission status first
      PermissionStatus photosStatus = await Permission.photos.status;
      PermissionStatus storageStatus = await Permission.storage.status;

      // If photos permission is not granted, request it
      if (photosStatus.isDenied) {
        photosStatus = await Permission.photos.request();
      }

      // If photos permission is still denied, try storage permission as fallback
      if (photosStatus.isDenied || photosStatus.isPermanentlyDenied) {
        if (storageStatus.isDenied) {
          storageStatus = await Permission.storage.request();
        }
      }

      // If both permissions are denied, show error and guide user to settings
      if ((photosStatus.isDenied || photosStatus.isPermanentlyDenied) &&
          (storageStatus.isDenied || storageStatus.isPermanentlyDenied)) {
        setState(() {
          _errorMessage =
              'Storage permission is required to access images. Please grant permission in app settings.';
        });

        // Show dialog to guide user to settings
        if (mounted) {
          _showPermissionDialog();
        }
        return;
      }

      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _errorMessage = null;
        });
        await _uploadImage();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to pick image: $e';
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    // Show loading popup
    if (mounted) {
      _showLoadingPopup();
    }

    try {
      // Create multipart request
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(AppConfig.webhookUrl),
      );

      // Set content type header explicitly
      request.headers['Content-Type'] = 'multipart/form-data';

      // Add image file with proper MIME type
      final file = _selectedImage!;
      final stream = http.ByteStream(file.openRead());
      final length = await file.length();

      // Determine MIME type based on file extension
      String mimeType = 'image/jpeg'; // default
      final extension = file.path.split('.').last.toLowerCase();
      if (extension == 'png') {
        mimeType = 'image/png';
      } else if (extension == 'jpg' || extension == 'jpeg') {
        mimeType = 'image/jpeg';
      } else if (extension == 'webp') {
        mimeType = 'image/webp';
      }

      final multipartFile = http.MultipartFile(
        'image',
        stream,
        length,
        filename: 'answer_sheet.$extension',
        contentType: MediaType.parse(mimeType),
      );

      request.files.add(multipartFile);

      // Send request
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      // Hide loading popup
      if (mounted) {
        Navigator.of(context).pop();
      }

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(responseBody);
        setState(() {
          _lastResult = MCQResponse.fromJson(jsonResponse);
          _isProcessing = false;
        });

        // Show result popup
        if (mounted) {
          _showResultPopup();
        }
      } else {
        setState(() {
          _errorMessage =
              'Failed to upload image. Status: ${response.statusCode}\nResponse: $responseBody';
          _isProcessing = false;
        });
      }
    } catch (e) {
      // Hide loading popup on error
      if (mounted) {
        Navigator.of(context).pop();
      }

      setState(() {
        _errorMessage = 'Failed to upload image: $e';
        _isProcessing = false;
      });
    }
  }

  void _showLoadingPopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Loading Bar

                // const SizedBox(height: 30),
                // Cool Text
                const Text(
                  'Your time is very important to us.\nPlease wait while we ignore you.',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: 200,
                  height: 6,
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppConfig.primaryColor,
                    ),
                  ),
                ),
                // const Text(
                //   'Processing your answer sheet...',
                //   style: TextStyle(
                //     fontSize: 16,
                //     color: Colors.grey,
                //   ),
                // ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showResultPopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ResultPopup(
          result: _lastResult!,
          onClose: () {
            Navigator.of(context).pop();
            setState(() {
              _lastResult = null;
              _selectedImage = null;
            });
          },
        );
      },
    );
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Permission Required'),
          content: const Text(
            'This app needs access to your photos and storage to select images. Please grant the required permissions in app settings.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPermissionStatus() {
    return FutureBuilder<List<PermissionStatus>>(
      future: Future.wait([
        Permission.photos.status,
        Permission.storage.status,
        Permission.camera.status,
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final photosStatus = snapshot.data![0];
        final storageStatus = snapshot.data![1];
        final cameraStatus = snapshot.data![2];

        return Container(
          padding: const EdgeInsets.all(10),
          margin: const EdgeInsets.only(top: 10, left: 20, right: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info,
                color: Colors.blue.shade600,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
              
                child: Text(
                  'Photos: ${photosStatus.isGranted ? '✓' : '✗'} Camera: ${cameraStatus.isGranted ? '✓' : '✗'}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const AppHeader(),
      ),
      extendBodyBehindAppBar: false,
      // backgroundColor: Color(lin),
      
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
             Color.fromARGB(255, 255, 255, 255),
              Color.fromARGB(255, 0, 0, 0),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          // minimum: 21,
            // left: false,
            // right: false,
            // edgeinsets:min(a, b)
          // top: false,
          // minimum: EdgeInsets.only(top: 0),
          child: Column(
            children: [
              // App Header
              // const AppHeader(),
        
              // Permission Status Indicator (Debug)
              // _buildPermissionStatus(),
        
              // Main Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Upload Icon and Title
                      const SizedBox(height: 20),
                      Container(
                        width: 80,
                        height: 80,
                        decoration: const BoxDecoration(
                          color: AppConfig.primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.description,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Upload Answer Sheet',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Upload your answer sheet for instant evaluation',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
        
                      // Main Upload Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(30),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.grey.shade200,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.8),
                              spreadRadius: 1,
                              blurRadius: 5,
                              offset: const Offset(0, 5)
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Upload Icon
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: AppConfig.primaryColor.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.cloud_upload,
                                color: AppConfig.primaryColor,
                                size: 30,
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Drag & Drop',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Drop your answer sheet here or click to browse',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 30),
        
                            // Choose File Button
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton.icon(
                                onPressed:
                                    _isProcessing ? null : _pickFromGallery,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppConfig.primaryColor,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                icon: const Icon(Icons.add),
                                label: const Text(
                                  'Choose File',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
        
                      const SizedBox(height: 30),
        
                      // Alternative Upload Options
                      Row(
                        children: [
                          Expanded(
                            child: _buildAlternativeOption(
                              icon: Icons.camera_alt,
                              title: 'Take Photo',
                              onTap: _takePhoto,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildAlternativeOption(
                              icon: Icons.photo_library,
                              title: 'Upload Image',
                              onTap: _pickFromGallery,
                            ),
                          ),
                        ],
                      ),
        
                      const SizedBox(height: 30),
        
                      // Tips Section
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.blue.shade200,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: const BoxDecoration(
                                    color: Colors.blue,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.info,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Tips for best results:',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildTip('Ensure good lighting and clear image'),
                            _buildTip('Keep the sheet flat and unfolded'),
                            _buildTip('Supported formats: JPG, PNG'),
                          ],
                        ),
                      ),
        
                      // Error Display
                      if (_errorMessage != null)
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(top: 20),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlternativeOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: _isProcessing ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey.shade200,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: AppConfig.primaryColor,
              size: 32,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTip(String tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 8, right: 12),
            decoration: const BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              tip,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
