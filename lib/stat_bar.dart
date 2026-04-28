import 'package:flutter/material.dart';

class StatBar extends StatelessWidget {
  final String label;
  final double value;
  final double maxValue;
  final Color color;

  const StatBar({
    super.key,
    required this.label, 
    required this.value, 
    required this.maxValue, 
    required this.color
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label, 
                style: const TextStyle(fontWeight: FontWeight.bold)
              ),
              Text(
                "${value.toInt()} / ${maxValue.toInt()}", 
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: value / maxValue, 
            color: color,
            backgroundColor: color.withOpacity(0.2),
            minHeight: 12,
            borderRadius: BorderRadius.circular(5),
          ),
        ],
      ),
    );
  }
}