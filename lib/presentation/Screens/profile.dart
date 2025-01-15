import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:khel_milap/presentation/Provider/user_id.dart';
import 'package:khel_milap/presentation/Screens/user_list_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:khel_milap/presentation/Widgets/Profile/gallery_card.dart';
import 'package:khel_milap/presentation/Widgets/Profile/joined_community_card.dart';
import 'package:khel_milap/presentation/theme/theme.dart';
import '../theme/styles.dart';

class Profile extends ConsumerStatefulWidget {
  const Profile({super.key});

  @override
  _Profile createState() => _Profile();
}

class _Profile extends ConsumerState<Profile> {
  final ImagePicker _picker = ImagePicker();
  final SupabaseClient supabase = Supabase.instance.client;
  List<String> galleryImages = [];
  String? profilePicUrl;
  final String photosBucket = 'Photos';
  @override
  void initState() {
    super.initState();
    Future.microtask( ()  async {
      galleryImages = [];
      await _fetchProfilePic();
      await _fetchGalleryImages();
      print("Galllery Images: $galleryImages");
    });

  }

  Future<void> _removeCommunity(String communityId) async {
    final userId = ref.watch(userIdProvider);
    try {
      await supabase
          .from('user_communities')
          .delete()
          .match({'user_id': "$userId", 'community_id': communityId});

      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Community removed successfully.')),
      );
    } catch (error) {
      print('Error removing community: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to remove community.')),
      );
    }
  }

  Future<void> _fetchProfilePic() async {
    final userId = ref.watch(userIdProvider);
    print("userId: $userId");
    final response = await supabase.from('Profile').select('profile_pic').eq('id', '$userId').single();
    if (response['profile_pic'] != null) {
      setState(() {
        profilePicUrl = supabase.storage.from('Photos').getPublicUrl('User/$userId/${response['profile_pic']}');
      });
    }
  }

  Future<void> _fetchGalleryImages() async {
    final userId = ref.watch(userIdProvider);

    final profileData = await supabase.from('Profile').select('gallery_images').eq('id', "$userId").single();
    print("Profile Data: $profileData");

    if(profileData['gallery_images']!=null) {
      List<String> existingGalleryImages = List<String>.from(
          profileData['gallery_images']);

      List<String> galleryUrls = [];

      for (var filePath in existingGalleryImages) {
        final publicUrl = supabase.storage.from('Photos').getPublicUrl(
            filePath);
        galleryUrls.add(publicUrl);
      }

      setState(() {
        galleryImages = galleryUrls;
      });
      print("Gallery Images URLs: $galleryImages");
    }
  }

  Future<void> _uploadImage(File imageFile, int index) async {
    final userId = ref.watch(userIdProvider);
    final fileName = 'gallery_${index + 1}.${imageFile.path.split('.').last}';
    final filePath = 'User/$userId/$fileName';

    try {
      List<String> existingGalleryImages = [];
      if(index!=0) {
        final profileData = await supabase.from('Profile').select(
            'gallery_images').eq('id', "$userId").single();
        existingGalleryImages = List<String>.from(
            profileData['gallery_images']);
        print(existingGalleryImages);
        print("Profile null : $profileData");
      }
        existingGalleryImages.add(filePath);

      await supabase.from('Profile').update({
        'gallery_images': existingGalleryImages,
      }).eq('id', "$userId");

      await supabase.storage.from('Photos').upload(filePath, imageFile);

      setState(() {
        galleryImages = existingGalleryImages.map((path) => supabase.storage.from('Photos').getPublicUrl(path)).toList();
      });

      print('Image uploaded successfully: $filePath');
    } catch (e) {
      print('Error uploading image: $e');
    }
  }


  Future<void> _pickAndUploadImage() async {
    if (galleryImages.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You can only upload up to 5 images.')),
      );
      return;
    }

    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      await _uploadImage(File(pickedFile.path), galleryImages.length);
    }
  }

  Future<List<Map<String, dynamic>>> _getUserCommunities() async {
    final userId = ref.watch(userIdProvider);
    final response = await Supabase.instance.client
        .from('user_communities')
        .select('community_id, Communities(title, perks, members)')
        .eq('user_id', "$userId");
    print(response);
    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(userIdProvider);
    final name = ref.watch(nameProvider);
    final List<dynamic> sports = ref.watch(sportsProvider)!.toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.lightTheme.appBarTheme.backgroundColor,
        title: Text(
          'Profile',
          style: AppTheme.lightTheme.textTheme.displayLarge?.copyWith(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SizedBox(height: 20),
              CircleAvatar(
                radius: 50,
                backgroundImage: profilePicUrl != null
                    ? NetworkImage(profilePicUrl!)
                    : AssetImage('assets/sports.jpg') as ImageProvider,
              ),
              SizedBox(height: 12),
              Text(
                name ?? 'User Name',
                style: AppTheme.lightTheme.textTheme.displayLarge,
              ),
              SizedBox(height: 16),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                alignment: WrapAlignment.center,
                children: sports.map((sport) {
                  return Container(
                    padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      sport,
                      style: TextStyle(color: Colors.black, fontSize: 16),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => UserListScreen()),
                      );
                    },
                    style: AppStyles.primaryButtonStyle,
                    child: Row(
                      children: [
                        Icon(Icons.chat, color: Colors.white),
                        SizedBox(width: 12),
                        Text('Chat'),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    style: AppStyles.primaryButtonStyle,
                    child: Row(
                      children: [
                        Icon(Icons.person_add, color: Colors.white),
                        SizedBox(width: 12),
                        Text('Connect'),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Card(
                margin: EdgeInsets.only(top: 16.0),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Gallery', style: AppTheme.lightTheme.textTheme.titleLarge),
                          IconButton(
                            icon: Icon(Icons.add_circle_outline, size: 32, color: Colors.blue),
                            onPressed: _pickAndUploadImage,
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      if (galleryImages.isNotEmpty)
                        SizedBox(
                          height: 200,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: galleryImages.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8.0),
                                child: GalleryCard(imagePath: galleryImages[index]),
                              );
                            },
                          ),
                        )
                      else
                        Text('No images available.'),
                    ],
                  ),
                ),
              ),
              Card(
                margin: EdgeInsets.only(top: 16.0),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Joined Communities',
                        style: AppTheme.lightTheme.textTheme.titleLarge,
                      ),
                      SizedBox(height: 10),
                      FutureBuilder(
                        future: _getUserCommunities(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return Text('No joined communities found.');
                          }
                          final joinedCommunities = snapshot.data!;
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: joinedCommunities.length,
                            itemBuilder: (context, index) {
                              final community = joinedCommunities[index];
                              return JoinedCommunityCard(
                                name: community['Communities']['title'],
                                members: community['Communities']['members'],
                                perks: community['Communities']['perks'],
                                userId: "$userId",
                                imagePath: Supabase.instance.client.storage
                                    .from('Photos')
                                    .getPublicUrl('Communities/${community['Communities']['title'].toLowerCase().replaceAll(' ', '')}.jpeg'),
                                onRemove: () => _removeCommunity(community['community_id']),
                                communityId: community['community_id'],
                              );
                            },
                          );
                        },
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
