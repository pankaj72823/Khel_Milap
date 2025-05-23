import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:khel_milap/presentation/Screens/community.dart';
import 'package:khel_milap/presentation/Screens/mentors.dart';
import 'package:khel_milap/presentation/Screens/peer_matching.dart';
import 'package:khel_milap/presentation/Screens/profile.dart';
import 'package:khel_milap/presentation/Screens/user_list_screen.dart';
import 'package:khel_milap/presentation/Widgets/HomeScreen/live_updates.dart';
import 'package:khel_milap/presentation/theme/fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../Widgets/HomeScreen/ad_carousel.dart';

class HomeScreen extends StatefulWidget {
  final bool fromSignup;
  const HomeScreen({super.key, this.fromSignup = false});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _hasAskedPermission = false;

  @override
  void initState() {
    super.initState();
    if (widget.fromSignup) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleLocationPrompt();
      });
    }
  }

  Future<void> _handleLocationPrompt() async {
    if (_hasAskedPermission) return;
    _hasAskedPermission = true;

    final answer = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Enable Peer Matching?"),
        content: const Text(
          "Would you like to share your location to help find peers near you?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Yes"),
          ),
        ],
      ),
    );

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final userId = user.id;

    if (answer == true) {
      // setState(() => _loading = true);
      _showLoadingDialog();

      try {
        await Supabase.instance.client
            .from('Users')
            .update({'is_visible': true})
            .eq('id', userId);

        final permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          Navigator.pop(context);
          _showSnackBar("Location permission denied. Showing home screen.");
          return;
        }

        Position position = await Geolocator.getCurrentPosition(
            locationSettings: LocationSettings(
              accuracy: LocationAccuracy.best,
              distanceFilter: 0,
            ));
          await Supabase.instance.client
              .from('Users')
              .update({
              'latitude': position.latitude,
              'longitude': position.longitude,
               })
              .eq('id', userId);

          _showSnackBar("Location shared and updated successfully.");

      } catch (e) {
        _showSnackBar("Failed to update location: $e");
      } finally {
        Navigator.pop(context);
        // setState(() => _loading = false);
      }
    } else {
      await Supabase.instance.client
          .from('Users')
          .update({'is_visible': false})
          .eq('id', userId);

      _showSnackBar("You chose not to share your location.");
    }
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text("Updating location..."),
          ],
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading:ImageIcon(AssetImage('assets/logo_khel_milap.png'),size: 50,),
        title: const Align(
          alignment: Alignment.center,
          child: Text(
            'KhelMilap',
            style: TextStyle(color: Colors.white, fontSize: 30),
          ),
        ),
        actions: [
          GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                    builder: (context) => UserListScreen()
                ),
                );
              },
              child: ImageIcon(AssetImage('assets/chat.gif'),size: 40,)),
          const SizedBox(width: 10,),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle('Live Trial Updates'),
              Container(
                  height: 100,
                  width: double.infinity,
                  child: LiveUpdates()
              ),
              const SizedBox(height: 12),
              _sectionTitle('Sponsored Ads'),
              AdCarousel(
                ads: [
                  {'title': ' Unleash Your Potential', 'imagePath': 'assets/sports_ad.jpg'},
                  {'title': ' Train Like a Champion!', 'imagePath': 'assets/sports_ad2.jpeg'},
                  {'title': 'Play Strong, Play Smart!', 'imagePath': 'assets/sports_ad3.jpg'},
                  {'title': 'Champion\'s Choice', 'imagePath': 'assets/sports_ad4.jpeg'}
                ]

              ),
              const SizedBox(height: 16),
              _sectionTitle('Latest News'),
              // Container(
              //   height: 300,
              //   width: double.infinity,
              //   decoration: BoxDecoration(
              //     color: Colors.white,
              //     borderRadius: BorderRadius.circular(12),
              //     boxShadow: [
              //       BoxShadow(
              //         color: Colors.black12,
              //         spreadRadius: 1,
              //         blurRadius: 5,
              //         offset: Offset(0, 3),
              //       ),
              //     ],
              //   ),
              //   padding: EdgeInsets.all(16),
              //   child: News(),
              // ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 80,
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.all(24),

          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                offset: const Offset(0,20),
                blurRadius: 20,
              )
            ]
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            // selectedItemColor: AppTheme.primaryColor,
            // unselectedItemColor: AppTheme.primaryColor,
            children: [
              Column(
                children: [
                GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context, MaterialPageRoute(
                        builder: (context)=> PeerMatching(),
                      ),
                      );
                    },
                    child:
                    Image.asset(
                      'assets/peer.gif', height: 40, width: 50,
                    ),
                ),
                const Text('Peers', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),
                ],
              ),
              Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context, MaterialPageRoute(
                        builder: (context)=> const Mentors(),
                      ),
                      );
                    },
                    child:
                    Image.asset(
                      'assets/mentor.gif', height: 40, width: 50,
                    ),
                  ),
                  const Text('Mentors', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),
                ],
              ),
              Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      // Navigator.push(
                      //     context, MaterialPageRoute(
                      //     builder: (context)=> const HomeScreen(),
                      // ),
                      // );
                    },
                    child:
                    Image.asset(
                      'assets/home.gif', height: 40, width: 50,
                    ),
                  ),
                  const Text('Home', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),
                ],
              ),
              Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context, MaterialPageRoute(
                        builder: (context)=> const Community(),
                      ),
                      );
                    },
                    child:
                    Image.asset(
                      'assets/comm.gif', height: 40, width: 50,
                    ),
                  ),
                  const Text('Community', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),
                ],
              ),
              Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context, MaterialPageRoute(
                        builder: (context)=> Profile(),
                      ),
                      );
                    },
                    child:
                    Image.asset(
                      'assets/profile.gif', height: 40, width: 50,
                    ),
                  ),
                  const Text('Profile', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),
                ],
              ),
              // Image.asset('assets/mentor.gif', height: 50, width: 50,),
              // Image.asset('assets/home.gif', height: 50, width: 50,),
              // Image.asset('assets/comm.gif', height: 50, width: 50,),
              // Image.asset('assets/profile.gif', height: 50, width: 50,),

              // BottomNavigationBarItem(
              //   icon: Icon(Icons.supervised_user_circle_outlined),
              //   label: 'Mentors',
              // ),
              // BottomNavigationBarItem(
              //   icon: Icon(Icons.home),
              //   label: 'Home',
              // ),
              // BottomNavigationBarItem(
              //   icon: Icon(Icons.group_work),
              //   label: 'Community',
              // ),
              // BottomNavigationBarItem(
              //   icon: Icon(Icons.person),
              //   label: 'Profile',
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: AppFonts.headline1.copyWith(fontSize: 24),
      ),
    );
  }
}


// class HomeScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'KhelMilap',
//           style: Theme.of(context).textTheme.titleLarge,
//         ),
//         backgroundColor:  AppTheme.lightTheme.primaryColor,
//         elevation: 0,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Welcome Text
//             Text(
//               'Welcome, Player!',
//               style: Theme.of(context).textTheme.displayLarge,
//             ),
//             SizedBox(height: 16),
//
//             // Card Example
//             Card(
//               color: AppTheme.lightTheme.cardTheme.color,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               elevation: 4,
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Row(
//                   children: [
//                     Icon(Icons.sports_cricket, size: 40, color: AppTheme.lightTheme.primaryColor),
//                     const SizedBox(width: 16),
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Find Players Nearby',
//                           style: Theme.of(context).textTheme.titleLarge,
//                         ),
//                         SizedBox(height: 4),
//                         Text(
//                           'Discover and connect with players within 5km.',
//                           style: Theme.of(context).textTheme.bodyMedium,
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             SizedBox(height: 16),
//
//             // Button Example
//             ElevatedButton(
//               style: AppStyles.primaryButtonStyle,
//               onPressed: () {
//                 // Action for button
//               },
//               child: Text('Join a Community'),
//             ),
//             SizedBox(height: 16),
//
//             // Input Field Example
//             TextFormField(
//               decoration: AppStyles.inputDecoration('Search for a community'),
//             ),
//             SizedBox(height: 16),
//
//             // List Example
//             Expanded(
//               child: ListView(
//                 children: [
//                   ListTile(
//                     leading: Icon(Icons.sports_soccer, color:  AppTheme.lightTheme.primaryColor),
//                     title: Text(
//                       'Football Enthusiasts',
//                       style: Theme.of(context).textTheme.bodyLarge,
//                     ),
//                     subtitle: Text(
//                       'Join 200+ members in exciting football matches.',
//                       style: Theme.of(context).textTheme.bodyMedium,
//                     ),
//                   ),
//                   Divider(),
//                   ListTile(
//                     leading: Icon(Icons.sports_tennis, color: AppTheme.lightTheme.primaryColor),
//                     title: Text(
//                       'Tennis Champs',
//                       style: Theme.of(context).textTheme.bodyLarge,
//                     ),
//                     subtitle: Text(
//                       'Weekly tennis meetups for all skill levels.',
//                       style: Theme.of(context).textTheme.bodyMedium,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

