import 'package:flutter/material.dart';

class LocationDetailHeaderWidget extends StatelessWidget {
  final VoidCallback onClose;

  const LocationDetailHeaderWidget({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Konum Detayları',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        IconButton(icon: const Icon(Icons.close_rounded), onPressed: onClose),
      ],
    );
  }
}
