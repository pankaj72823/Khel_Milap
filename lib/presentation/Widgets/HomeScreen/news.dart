// import 'package:flutter/material.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:khel_milap/presentation/Provider/news_provider.dart';
// import 'package:khel_milap/presentation/theme/theme.dart';
//
// class News extends ConsumerWidget{
//   const News({super.key});
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final newsList = ref.watch(newsProvider);
//     return newsList.when(
//                   data: (news) => ListView.builder(
//                       shrinkWrap: true,
//                   itemCount: news.length,
//                   itemBuilder: (contex, length){
//                   final story = news[length];
//                   return Card(
//                     child: ListTile(
//                       contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),  // Padding for the ListTile
//                       tileColor: AppTheme.primaryColor,  // White background for the tile
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8),  // Rounded corners for ListTile
//                       ),
//                       // leading: story.imageID != null
//                       //     ? ClipRRect(
//                       //   borderRadius: BorderRadius.circular(8),  // Rounded image if needed
//                       //   child: Image.network(
//                       //     '${dotenv.env['NEWS_BASE_URL']}/${story.imageID}',
//                       //     width: 50,
//                       //     height: 50,
//                       //     fit: BoxFit.cover,
//                       //   ),
//                       // )
//                       //     : null,  // If image ID is not available, don't display it
//                       title: Text(
//                         story.headline,
//                         style: TextStyle(
//                           fontSize: 16,  // Slightly larger text
//                           fontWeight: FontWeight.bold,  // Bold title for emphasis
//                           color: Colors.white,  // Dark text for contrast
//                         ),
//                       ),
//                       subtitle: Text(
//                         story.description,
//                         style: TextStyle(
//                           fontSize: 14,  // Slightly smaller text for subtitle
//                           color: Colors.white,  // Softer color for the subtitle
//                         ),
//                       ),
//                       onTap: () {
//                         // Add the onTap functionality (e.g., navigate to a detailed view)
//                       },
//                     ),
//
//                   );
//                   }
//                   ),
//                   loading: () => const Center(child: CircularProgressIndicator()),
//                   error: (error, stack) => Center(child: Text('Error: $error')),
//     );
//   }
//
// }