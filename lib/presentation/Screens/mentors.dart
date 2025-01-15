import 'dart:core';
import 'package:flutter/material.dart';
import 'package:khel_milap/presentation/Widgets/Mentor/mentor_card.dart';
import 'package:khel_milap/presentation/theme/theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Mentors extends StatefulWidget {
  const Mentors({super.key});

  @override
  State<Mentors> createState() => _MentorsState();
}

class _MentorsState extends State<Mentors> {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  List<Map<String, dynamic>> mentors = [];
  List<Map<String, dynamic>> filteredMentors = [];

  String? selectedRole = 'Sports';
  String selectedExperience = 'Experience';
  String selectedFees = 'Fees';

  final List<String> experienceLevels = ['Experience', '3+ ', '5+ ', '7+', '10+'];
  final List<String> feeRanges = ['Fees', '4000+', '7000+', '10000+'];
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
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    fetchMentors();
  }

  Future<void> fetchMentors() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await _supabaseClient.from('Mentors').select();
      final fetchedMentors = List<Map<String, dynamic>>.from(response);
      setState(() {
        mentors = fetchedMentors;
        applyFilters();
      });
    } catch (error) {
      print('Error fetching mentors: $error');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }



  void applyFilters() {
    setState(() {
      filteredMentors = mentors.where((mentor) {
        final sportsMatch = selectedRole == 'Sports' || mentor['sports'] == selectedRole;
        final experienceMatch = selectedExperience == 'Experience' ||
            mentor['experience'] >= int.parse(selectedExperience.replaceAll('+', ''));
        final feesMatch = selectedFees == 'Fees' ||
            mentor['fees'] >= int.parse(selectedFees.replaceAll('+', ''));
        return sportsMatch && experienceMatch && feesMatch;
      }).toList();
    });
  }

  String getMentorImagePath(String name) {
    final imagePath = name.toLowerCase().replaceAll(' ', '');
    final publicUrl = _supabaseClient.storage
        .from('Photos')
        .getPublicUrl('Mentors/$imagePath.jpeg');
    return publicUrl;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.lightTheme.appBarTheme.backgroundColor,
        title: Text('Mentors', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
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
                          value: selectedRole,
                          items: sports
                              .map((role) => DropdownMenuItem(
                            value: role,
                            child: Text(
                              role,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                          ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedRole = value!;
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
                          value: selectedExperience,
                          items: experienceLevels
                              .map((role) => DropdownMenuItem(
                            value: role,
                            child: Text(
                              role,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                          ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedExperience = value!;
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
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
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
                          value: selectedFees,
                          items: feeRanges
                              .map((role) => DropdownMenuItem(
                            value: role,
                            child: Text(
                              role,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                          )).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedFees = value!;
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
            child: isLoading
                ? Center(
              child: CircularProgressIndicator(
                color: AppTheme.secondaryColor,
              ),
            )
                : ListView.builder(
              itemCount: filteredMentors.length,
              itemBuilder: (context, index) {
                final mentor = filteredMentors[index];
                return MentorCard(
                  name: mentor['name']!,
                  sports: mentor['sports']!,
                  experience: mentor['experience']!,
                  fees: mentor['fees']!,
                  imageUrl: getMentorImagePath(mentor['name']!),
                );
              },
            ),
          ),

        ],
      ),
    );
  }
}
