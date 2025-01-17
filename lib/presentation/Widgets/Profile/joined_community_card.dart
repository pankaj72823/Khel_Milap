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
  final VoidCallback onRemove;

  const JoinedCommunityCard({
    super.key,
    required this.name,
    required this.members,
    required this.perks,
    required this.imagePath,
    required this.userId,
    required this.communityId,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        width: double.infinity,
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Image
              CircleAvatar(
                backgroundColor: Colors.white,
                radius: 30,
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: imagePath,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => CircularProgressIndicator(),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Text Section (Using Flexible)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    Text(
                      name,
                      style: AppFonts.headline1.copyWith(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                      maxLines: null, // Allow unlimited lines
                    ),
                    const SizedBox(height: 8),

                    // Members
                    Text(
                      'Members: $members',
                      style: AppFonts.bodyText.copyWith(color: Colors.black),
                      maxLines: null,
                    ),
                    const SizedBox(height: 4),

                    // Perks
                    Text(
                      'Perks: $perks',
                      style: AppFonts.bodyText.copyWith(color: Colors.black),
                      maxLines: null,
                    ),
                  ],
                ),
              ),

              // Remove Icon
              IconButton(
                icon: Icon(Icons.close, color: Colors.red),
                onPressed: onRemove,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
