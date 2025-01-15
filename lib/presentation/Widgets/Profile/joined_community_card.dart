import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:khel_milap/presentation/theme/fonts.dart';

class JoinedCommunityCard extends StatelessWidget {
  final String name;
  final int members;
  final String perks;
  final String imagePath;
  final String userId;
  final String communityId;
  final VoidCallback onRemove; // onRemove function to handle the action

  const JoinedCommunityCard({
    super.key,
    required this.name,
    required this.members,
    required this.perks,
    required this.imagePath,
    required this.userId,
    required this.communityId,
    required this.onRemove, // Adding the onRemove callback
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          height: 180,
          width: 350,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Colors.grey,
                spreadRadius: 2,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 30,
                  child: ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: imagePath,
                      width: 70,
                      height: 70,
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
                      Text(
                        name,
                        style: AppFonts.headline1.copyWith(color: Colors.black, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Members: $members',
                        style: AppFonts.bodyText.copyWith(color: Colors.black),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Perks: $perks',
                        style: AppFonts.bodyText.copyWith(color: Colors.black),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.red), // Cross icon to remove
                  onPressed: onRemove, // Calling the onRemove function when pressed
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
