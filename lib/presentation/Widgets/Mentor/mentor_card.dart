import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:khel_milap/presentation/theme/fonts.dart';
import 'package:khel_milap/presentation/theme/styles.dart';


class MentorCard extends StatelessWidget {
  final String name;
  final String sports;
  final int experience;
  final int fees;
  final String imageUrl;

  const MentorCard({
    super.key,
    required this.name,
    required this.sports,
    required this.experience,
    required this.fees,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {

    return Container(
      decoration: AppStyles.cardDecoration,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.white,
            radius: 30,
            child:ClipOval(
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                width: 100, // Adjust the size to match the CircleAvatar
                height: 100, // Adjust the size to match the CircleAvatar
                fit: BoxFit.cover,
                placeholder: (context, url) => CircularProgressIndicator(),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
            ),
           ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppFonts.headline1.copyWith(fontSize: 20)),
                Text(sports, style: AppFonts.bodyText),
                Text("$experience years exprience", style: AppFonts.bodyText),
                Text("₹$fees", style: AppFonts.bodyText.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: AppStyles.primaryButtonStyle,
            child: const Text('Contact'),
          ),
        ],
      ),
    );
  }
}
