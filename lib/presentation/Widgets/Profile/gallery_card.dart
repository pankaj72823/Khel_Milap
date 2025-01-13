import 'package:flutter/material.dart';

import '../../theme/styles.dart';

class GalleryCard extends StatelessWidget {
  final String imagePath;

  const GalleryCard({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: AppStyles.cardDecoration,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(imagePath, fit: BoxFit.cover),
        ),
      ),
    );
  }
}