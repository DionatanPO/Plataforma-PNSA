import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StepIndicatorWidget extends StatelessWidget {
  final int currentStep;

  const StepIndicatorWidget({
    Key? key,
    required this.currentStep,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Etapa 1
        Expanded(
          child: Column(
            children: [
              Container(
                height: 2,
                color: currentStep >= 0 ? Colors.green : Colors.grey.shade400,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: currentStep >= 0 ? Colors.green : Colors.grey.shade400,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '1',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Fiel',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: currentStep >= 0 ? Colors.green : Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Etapa 2
        Expanded(
          child: Column(
            children: [
              Container(
                height: 2,
                color: currentStep >= 1 ? Colors.green : Colors.grey.shade400,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: currentStep >= 1 ? Colors.green : Colors.grey.shade400,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '2',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Lançamento',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: currentStep >= 1 ? Colors.green : Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}