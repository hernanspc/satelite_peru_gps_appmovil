import 'package:flutter/material.dart';

class CustomShareButton extends StatelessWidget {
  final Future<void> Function() onPressed;
  final bool isLightMode;
  final String label;
  final IconData icon;

  const CustomShareButton({
    super.key,
    required this.onPressed,
    required this.isLightMode,
    this.label = 'Compartir',
    this.icon = Icons.share,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () async {
        await onPressed();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isLightMode ? Colors.purple : Colors.white,
        foregroundColor: isLightMode ? Colors.white : Colors.purple,
        iconColor: isLightMode ? Colors.white : Colors.purple,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 12,
        ),
      ),
      icon: Icon(
        icon,
        size: 20,
      ),
      label: Text(
        label,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
