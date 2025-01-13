// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:khel_milap/presentation/Provider/user_id.dart';
// import 'package:khel_milap/presentation/Screens/home_screen.dart';
// import 'package:khel_milap/presentation/Screens/signin.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
//
// class SplashScreen extends ConsumerWidget {
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final supabase = Supabase.instance.client;
//
//     return FutureBuilder(
//       future: supabase.auth.recoverSession(), // Check for active session
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const CircularProgressIndicator();
//         }
//         if (supabase.auth.currentSession != null) {
//           ref.read(userIdProvider.notifier).state = session
//           return HomeScreen();
//         } else {
//           // Otherwise, navigate to the login screen
//           return Signin();
//         }
//       },
//     );
//   }
// }


// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// // import 'package:nishabdvaani/Screens/signin.dart';
// // import 'package:nishabdvaani/Screens/signup.dart';
// // import 'package:nishabdvaani/Widgets/HomeScreen/welcome_widget.dart';
//
// class Welcome extends StatelessWidget{
//   const Welcome({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return WelcomeWidget(
//       child: Column(
//         children: [
//           Center(
//             child: Column(
//               children: [
//                 Image.asset(
//                   'assets/Home_Screen/temp_logo.png', height: 90,
//                 ),
//               ],
//             ),
//           ),
//           Flexible(
//             flex: 1,
//             child: Align(
//               alignment: Alignment.bottomRight,
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.all(32.0),
//                     child: GestureDetector(
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (e) => const SignIn(),
//                           ),
//                         );
//                       },
//                       child: Container(
//                         child: Text(
//                           'Sign in',
//                           style:
//                           GoogleFonts.openSans(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 26,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                   GestureDetector(
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (e) => Signup(),
//                         ),
//                       );
//                     },
//                     child: Container(
//                       height: 100,
//                       width: 180,
//                       decoration: const BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.only(
//                           topLeft: Radius.circular(50),
//                         ),
//                       ),
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
//                         child: Text(
//                           'Signup',
//                           style: GoogleFonts.openSans(fontWeight: FontWeight.bold, fontSize: 28),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           )
//         ],
//       ),
//     );
//   }
//
// }