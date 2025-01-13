import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khel_milap/presentation/Provider/user_id.dart';
import 'package:khel_milap/presentation/Widgets/Community/community_card.dart';
import 'package:khel_milap/presentation/theme/theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/styles.dart';

class Community extends ConsumerStatefulWidget {
  const Community({super.key});

  @override
  _Community createState() => _Community();
}

class _Community extends ConsumerState<Community> {

  final SupabaseClient _supabaseClient = Supabase.instance.client;
  List<Map<String, dynamic>> communities = [];
  List<Map<String,dynamic>> filteredCommunities = [];
  String? selectedSports = 'Sports';
  String? selectedmember = 'Members';

  List<String> membersRange = ['Members', '70+', '100+', '150+', '200+'];
  final List<String> sports = [
    'Sports',
    'Cricket',
    'Badminton',
    'Football',
    'Tennis',
    'Volleyball',
    'Table Tennis',
    'Athletics',
    'Hockey',
  ];

  @override
  void initState(){
    super.initState();
    print("hello");
    fetchCommunities();
  }

  Future<void> fetchCommunities() async {
    try{
      final response = await _supabaseClient
          .from('Communities')
          .select();
      final fetchedCommunities = List<Map<String, dynamic>>.from(response);

      setState(() {
        communities = fetchedCommunities;
        applyFilters();
      });
    } catch(error){
      print("Error fetching: $error");
    }
  }

  void applyFilters(){
    setState(() {
      filteredCommunities = communities.where((community){
        final sports = selectedSports == 'Sports' || community['sports'] == selectedSports;
        final member = selectedmember == 'Members' ||
            community['members']>=int.parse(selectedmember!.replaceAll('+', ''));
        return sports && member;
    }).toList();
    });
  }

  String getCommunityImagePath(String title) {
    final imagePath = title.toLowerCase().replaceAll(' ', '');
    final publicUrl = _supabaseClient.storage
        .from('Photos')
        .getPublicUrl('Communities/$imagePath.jpeg');
    return publicUrl;
  }

  @override
  Widget build(BuildContext context) {
    print("Started");
    final  userId = ref.watch(userIdProvider);
    print("Started");
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.lightTheme.appBarTheme.backgroundColor,
        title: Text(
          'Sports Communities',
          style: AppTheme.lightTheme.textTheme.displayLarge?.copyWith(color: Colors.white),
        ),
        centerTitle: true,
        elevation: 4,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child:
              Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex:1,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedSports,
                          items: sports
                              .map((sport) => DropdownMenuItem(
                            value: sport,
                            child: Text(
                              sport,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                          ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedSports = value!;
                              applyFilters();
                            });
                          },
                          icon: Icon(
                            Icons.arrow_drop_down_circle,
                            color: AppTheme.secondaryColor,
                            size: 20,
                          ),
                          dropdownColor: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          style: TextStyle(fontSize: 16, color: Colors.black),
                          elevation: 5,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex:1,
                  child: Container(
                    width: 60,
                    height: 50,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedmember,
                          items: membersRange
                              .map((member) => DropdownMenuItem(
                            value: member,
                            child: Text(
                              member,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                          ))
                              .toList(),
                          onChanged: (val) {
                            setState(() {
                              selectedmember = val!;
                              applyFilters();
                            });
                          },
                          icon: Icon(
                            Icons.arrow_drop_down_circle,
                            color: AppTheme.secondaryColor,
                          ),
                          dropdownColor: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          style: TextStyle(fontSize: 16, color: Colors.black),
                          elevation: 5,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            ),
              Expanded(
                flex: 1,
              child: ListView.builder(
                itemCount: filteredCommunities.length,
                itemBuilder: (context, index){
                  final community = filteredCommunities[index];
                  return CommunityCard(
                      title: community['title'],
                      members: community['members'],
                      perks: community['perks'],
                      imagePath: getCommunityImagePath(community['title']),
                      userId: "$userId",
                      communityId: community['community_id'],
                      );
                },
              ),
              ),
              ],
      ),

    );
  }
}
