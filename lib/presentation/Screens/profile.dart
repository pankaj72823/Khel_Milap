import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:khel_milap/presentation/Provider/user_id.dart';
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


  Future<void> _fetchProfilePic() async {
    final userId = ref.watch(userIdProvider);
    print("userId: $userId");
    final response = await supabase.from('Profile').select('profile_pic').eq('id', '$userId').single();
    if (response != null && response['profile_pic'] != null) {
      setState(() {
        profilePicUrl = supabase.storage.from('Photos').getPublicUrl('User/$userId/${response['profile_pic']}');
      });
    }
  }

  // Future<void> _fetchGalleryImages() async {
  //   final userId = ref.watch(userIdProvider);
  //   String? path = "User/$userId";
  //   final response = await supabase.storage.from('Photos').list(path:path);
  //   print("Path: $User/$userId");
  //
  //   List<String> url = [];
  //   final profilePicFile = await supabase.from('Profile').select('profile_pic').eq('id', userId! as Object).single();
  //   print("response : $response");
  //   print(profilePicFile);
  //   setState(() {
  //     galleryImages = response
  //         .where((file) => !file.name.contains(profilePicFile['profile_pic'])) // Exclude profile picture
  //         .map((file) => supabase.storage.from('Photos').getPublicUrl(file.name))
  //         .toList();
  //   });
  //   print(galleryImages);
  // }
  //
  // // Future<String> _getUserId(WidgetRef ref) async {
  // //   final id = ref.watch(userIdProvider);
  // //   return id.toString();
  // // }
  //
  // Future<void> _uploadImage(File imageFile, int index) async {
  //   final userId = ref.watch(userIdProvider);
  //   // final timestamp = DateTime.now().millisecondsSinceEpoch;
  //   final fileName = 'gallery_${index+1}.${imageFile.path.split('.').last}';
  //   final filePath = 'User/$userId/$fileName';
  //
  //   try {
  //     await supabase.storage.from('Photos').upload(filePath, imageFile);
  //     setState(() {
  //       galleryImages.add(supabase.storage.from('Photos').getPublicUrl(filePath));
  //     });
  //   } catch (e) {
  //     print('Error uploading image: $e');
  //   }
  // }

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
        .select('community_id, Communities(name, perks, members)')
        .eq('user_id', "$userId");

    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.lightTheme.appBarTheme.backgroundColor,
        title: Text('Profile', style: AppTheme.lightTheme.textTheme.displayLarge?.copyWith(color: Colors.white)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/sports.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: profilePicUrl != null ? NetworkImage(profilePicUrl!) : AssetImage('assets/sports.jpg') as ImageProvider,
                  ),
                  SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Profile',
                        style: AppTheme.lightTheme.textTheme.displayLarge,
                      ),
                      Text(
                        'Sports Enthusiast',
                        style: AppTheme.lightTheme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {},
                    style: AppStyles.primaryButtonStyle,
                    child: Row(
                      children: [
                        Image.asset('assets/chat.gif', height: 50, width: 50, color: Colors.white),
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
                        Image.asset('assets/add_user.gif', height: 50, width: 50, color: Colors.white),
                        SizedBox(width: 12),
                        Text('Connect'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Gallery', style: AppTheme.lightTheme.textTheme.titleLarge),
                  IconButton(
                    icon: Icon(Icons.add_circle_outline, size: 32, color: Colors.blue),
                    onPressed: _pickAndUploadImage,
                  ),
                ],
              ),
            ),
            if (galleryImages.isNotEmpty)
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: galleryImages.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: GalleryCard(imagePath: galleryImages[index]),
                    );
                  },
                ),
              ),
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text('Highlights', style: AppTheme.lightTheme.textTheme.titleLarge),
                    FutureBuilder(
                        future: _getUserCommunities(),
                        builder: (context, snapshot){
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(child: Text('Error: ${snapshot.error}'));
                          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Center(child: Text('No joined communities found.'));
                          }

                          final joinedCommunities = snapshot.data!;
                          return ListView.builder(
                            itemCount: joinedCommunities.length,
                            itemBuilder: (context, index) {
                              final community = joinedCommunities[index];
                              return JoinedCommunityCard(
                                name: community['name'],
                                members: community['members'],
                                perks: community['perks'],
                                imagePath:  Supabase.instance.client.storage
                                    .from('Photos')
                                    .getPublicUrl('Communities/${community['name'].toLowerCase()}.jpeg'),
                              );
                            },
                          );
                        }
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:khel_milap/presentation/Widgets/Profile/gallery_card.dart';
// import 'package:khel_milap/presentation/Widgets/Profile/joined_community_card.dart';
// import 'package:khel_milap/presentation/theme/theme.dart';
// import '../theme/styles.dart';
//
// class Profile extends ConsumerStatefulWidget {
//   const Profile({super.key});
//
//   @override
//   _Profile createState() => _Profile();
// }
//
// class _Profile extends ConsumerState<Profile> {
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: AppTheme.lightTheme.appBarTheme.backgroundColor,
//         title: Text('Profile', style: AppTheme.lightTheme.textTheme.displayLarge?.copyWith(color: Colors.white)
//         ),
//         centerTitle: true,
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Container(
//               width: double.infinity,
//               height: 200,
//               decoration: BoxDecoration(
//                 image: DecorationImage(
//                   image: AssetImage('assets/sports.jpg'),
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Row(
//                 children: [
//                   CircleAvatar(
//                     radius: 40,
//                     backgroundImage: AssetImage('assets/sports.jpg'),
//                   ),
//                   SizedBox(width: 16),
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Athlete Profile',
//                         style: AppTheme.lightTheme.textTheme.displayLarge,
//                       ),
//                       Text(
//                         'Sports Enthusiast',
//                         style: AppTheme.lightTheme.textTheme.bodyMedium,
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16.0),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   ElevatedButton(
//                     onPressed: () {},
//                     style: AppStyles.primaryButtonStyle,
//                     child: Row(
//                       children: [
//                         Image.asset('assets/chat.gif',height: 50, width: 50, color: Colors.white,),
//                         SizedBox(width: 12,),
//                         Text('Chat'),
//                       ],
//                     ),
//                   ),
//                   ElevatedButton(
//                     onPressed: () {},
//                     style: AppStyles.primaryButtonStyle,
//                     child: Row(
//                       children: [
//                         Image.asset('assets/add_user.gif', height: 50, width: 50, color: Colors.white,),
//                         SizedBox(width: 12,),
//                         Text('Connect'),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Text('Gallery', style: AppTheme.lightTheme.textTheme.titleLarge),
//             ),
//             GalleryCard(imagePath: 'assets/sports.jpg'),
//             GalleryCard(imagePath: 'assets/sports.jpg'),
//
//             SingleChildScrollView(
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   children: [
//                      Text(
//                             'Highlights', style: AppTheme.lightTheme.textTheme.titleLarge
//                         ),
//                     JoinedCommunityCard(title: 'name', members: 20, perks: 'name', imagePath: 'assets/sports.jpg'),
//                     JoinedCommunityCard(title: 'name', members: 20, perks: 'name', imagePath: 'assets/sports.jpg'),
//                     JoinedCommunityCard(title: 'name', members: 20, perks: 'name', imagePath: 'assets/sports.jpg'),
//                     JoinedCommunityCard(title: 'name', members: 20, perks: 'name', imagePath: 'assets/sports.jpg'),
//                     JoinedCommunityCard(title: 'name', members: 20, perks: 'name', imagePath: 'assets/sports.jpg'),
//                     JoinedCommunityCard(title: 'name', members: 20, perks: 'name', imagePath: 'assets/sports.jpg'),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }