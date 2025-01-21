import 'package:flutter/material.dart';

class DrawInput {
  final TextEditingController lengthController;
  final TextEditingController diameterController;
  final TextEditingController angleController;
  final TextEditingController? crossAngleController;

  DrawInput({
    required this.lengthController,
    required this.diameterController,
    required this.angleController,
    this.crossAngleController,
  });

  Map<String, String> toMap() {
    return {
      'length': lengthController.text.isNotEmpty ? lengthController.text: '0',
      'diameter': diameterController.text.isNotEmpty ? diameterController.text: '0',
      'angle': angleController.text.isNotEmpty ? angleController.text: '0',
      if (crossAngleController != null)
        'crossAngle': crossAngleController!.text.isNotEmpty ? crossAngleController!.text: '0',
    };
  }

  Map<String, double> toDoubleMap() {
    return {
      'length': lengthController.text.isNotEmpty ? double.parse(lengthController.text): 0,
      'diameter': diameterController.text.isNotEmpty ? double.parse(diameterController.text): 0,
      'angle': angleController.text.isNotEmpty ? double.parse(angleController.text): 0,
      if (crossAngleController != null)
        'crossAngle': crossAngleController!.text.isNotEmpty ? double.parse(crossAngleController!.text): 0,
    };
  }

  static DrawInput fromMap(Map<String, dynamic> map) {
    return DrawInput(
      lengthController: TextEditingController(text: map['length'].toString()),
      diameterController: TextEditingController(text: map['diameter'].toString()),
      angleController: TextEditingController(text: map['angle'].toString()),
      crossAngleController: map.containsKey('crossAngle')
          ? TextEditingController(text: map['crossAngle'].toString())
          : null,
    );
  }

  static DrawInput fromType(bool is3D) {
    return DrawInput(
      lengthController: TextEditingController(),
      diameterController: TextEditingController(),
      angleController: TextEditingController(),
      crossAngleController: is3D
          ? TextEditingController()
          : null,
    );
  }
}