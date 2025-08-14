import 'package:flutter/material.dart';

class EvaluationProcessCard extends StatelessWidget {
  final int currentStep;

  const EvaluationProcessCard({
    super.key,
    this.currentStep = 1,
  });

  Widget _buildProcessStep(int stepNumber, String description,
      {bool isActive = false}) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: isActive ? Colors.blue : Colors.grey.shade300,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$stepNumber',
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey.shade700,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            description,
            style: TextStyle(
              fontSize: 16,
              color: isActive ? Colors.black87 : Colors.grey.shade700,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Evaluation Process',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          _buildProcessStep(1, 'Upload student\'s answer sheet',
              isActive: currentStep >= 1),
          const SizedBox(height: 16),
          _buildProcessStep(2, 'Upload correct answer sheet',
              isActive: currentStep >= 2),
          const SizedBox(height: 16),
          _buildProcessStep(3, 'Get results via email & app',
              isActive: currentStep >= 3),
        ],
      ),
    );
  }
}
