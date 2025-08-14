import 'package:flutter/material.dart';
import 'screens/upload_screen.dart';
import 'config.dart';

void main() {
  runApp(const MCQCheckerApp());
}

class MCQCheckerApp extends StatelessWidget {
  const MCQCheckerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      
      debugShowCheckedModeBanner: false,
      title: AppConfig.appName,
      
      theme: ThemeData(
        
        colorScheme: ColorScheme.fromSeed(seedColor: AppConfig.primaryColor),
        useMaterial3: true,
      ),
      home: const UploadScreen(),
    );
  }
}
