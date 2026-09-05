import 'package:flutter/material.dart';

class NumberStepper extends StatelessWidget {
  final int value;
  final int minValue;
  final ValueChanged<int> onChanged;

  const NumberStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.minValue = 1,
  });

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF006859);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: value > minValue ? () => onChanged(value - 1) : null,
          icon: const Icon(Icons.remove_circle_outline),
          color: primaryColor,
        ),
        Text(
          '$value',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        IconButton(
          onPressed: () => onChanged(value + 1),
          icon: const Icon(Icons.add_circle_outline),
          color: primaryColor,
        ),
      ],
    );
  }
}