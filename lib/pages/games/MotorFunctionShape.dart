import 'package:flutter/material.dart';
import 'package:neuro_task/pages/games/motor_function.dart';


class MotorFunctionShape extends StatefulWidget {
  const MotorFunctionShape({super.key});

  @override
  State<MotorFunctionShape> createState() => _MotorFunctionShapeState();
}

class _MotorFunctionShapeState extends State<MotorFunctionShape> {
  @override
  Widget build(BuildContext context) {
    return const MotorFunction();
  }
}