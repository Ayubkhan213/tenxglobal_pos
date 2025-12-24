import 'package:flutter/material.dart';

class StepProgressColumn extends StatelessWidget {
  final int currentStep;
  final bool authenticated;
  final bool connected;

  const StepProgressColumn({
    super.key,
    required this.currentStep,
    required this.authenticated,
    required this.connected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _stepItem(1, "Authentication", currentStep == 0, authenticated),
        _verticalLine(currentStep > 0),
        _stepItem(2, "Printer Connection", currentStep == 1, connected),
      ],
    );
  }

  Widget _stepItem(int number, String title, bool active, bool done) {
    return Column(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: done
              ? Colors.green
              : active
                  ? const Color(0xFF1976D2)
                  : Colors.grey.shade300,
          child: done
              ? const Icon(Icons.check, color: Colors.white)
              : Text(
                  "$number",
                  style: TextStyle(
                    color: active ? Colors.white : Colors.grey.shade600,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
        const SizedBox(height: 10),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: active ? Colors.blue : Colors.grey.shade600,
            fontWeight: active ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _verticalLine(bool active) => Container(
        width: 3,
        height: 60,
        color: active ? Colors.green : Colors.grey.shade300,
        margin: const EdgeInsets.symmetric(vertical: 10),
      );
}
