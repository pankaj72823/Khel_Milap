
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:khel_milap/presentation/theme/fonts.dart';
import 'package:khel_milap/presentation/theme/theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../theme/styles.dart';
import '../../theme/theme.dart';

class CommunityCard extends StatefulWidget {
  final String title;
  final int members;
  final String perks;
  final String imagePath;
  final String userId;
  final String communityId;

  const CommunityCard({
    super.key,
    required this.title,
    required this.members,
    required this.perks,
    required this.imagePath,
    required this.userId,
    required this.communityId,
  });

  @override
  State<CommunityCard> createState() => _CommunityCardState();
}

class _CommunityCardState extends State<CommunityCard> {
  final SupabaseClient _supabase = Supabase.instance.client;
  bool isJoined = false;

  @override
  void initState(){
    super.initState();
    _checkJoinStatus();
  }

  Future<void> _checkJoinStatus() async{
    final response = await _supabase
        .from('user_communities')
        .select('Joined/Not Joined')
        .eq('user_id', widget.userId)
        .eq('community_id', widget.communityId)
        .maybeSingle();

    setState(() {
      isJoined = response !=false;
    });
  }

  Future<void> _joinCommunity() async {
    if (!isJoined) {
      await Supabase.instance.client.from('user_communities').insert({
        'user_id': widget.userId,
        'community_id': widget.communityId,
      });

      await Supabase.instance.client
          .from('Communities')
          .update({'Joined/Not Joined': true})
          .eq('id', widget.communityId);
      setState(() {
        isJoined = true;
      });
    }
  }
    @override
    Widget build(BuildContext context) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
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
                  radius: 35,
                  child: ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: widget.imagePath,
                      width: 100,
                      // Adjust the size to match the CircleAvatar
                      height: 100,
                      // Adjust the size to match the CircleAvatar
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          CircularProgressIndicator(),
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
                        widget.title,
                        style: AppFonts.headline1.copyWith(color: Colors.black),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Members: ${widget.members}',
                        style: AppFonts.bodyText.copyWith(color: Colors.black),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Perks: ${widget.perks}',
                        style: AppFonts.bodyText.copyWith(color: Colors.black),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () async {
                          await _joinCommunity();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isJoined ? Colors.orange : AppTheme.primaryColor,
                            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        child: Text( isJoined ? 'Joined' : 'Join now'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

