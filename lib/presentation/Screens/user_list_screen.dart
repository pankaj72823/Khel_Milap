import 'package:flutter/material.dart';
import 'package:khel_milap/presentation/Screens/chat_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../Provider/user_provider.dart';

class UserListScreen extends ConsumerStatefulWidget {
  const UserListScreen({super.key});

  @override
  ConsumerState<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends ConsumerState<UserListScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _selectedUsers = [];
  bool _showDropdown = false;
  final SupabaseClient _supabase = Supabase.instance.client;


  @override
  void initState() {
    super.initState();
    final user = _supabase.auth.currentUser;
    if (user != null) {
      loadChatPartners(user.id).then((loadedUsers) {
        setState(() {
          _selectedUsers = loadedUsers;
        });
      });
    }
  }

  Future<List<Map<String, dynamic>>> loadChatPartners(String userId) async {
    final response = await _supabase
        .from('chats')
        .select('sender_id, receiver_id')
        .or('sender_id.eq.$userId,receiver_id.eq.$userId');

    List<dynamic> data = response;
    Set<String> partnerIds = {};

    for (var chat in data) {
      if (chat['sender_id'] != userId) {
        partnerIds.add(chat['sender_id']);
      }
      if (chat['receiver_id'] != userId) {
        partnerIds.add(chat['receiver_id']);
      }
    }

    List<String> conditions = partnerIds.map((id) => "id.eq.$id").toList();
    String finalQuery = conditions.join(',');

    final userResponse = await _supabase
        .from('Users')
        .select('id, username')
        .or(finalQuery);

    List<dynamic> userData = userResponse;
    return userData.map((user) => {'id': user['id'], 'username': user['username']}).toList();
  }

  @override
  Widget build(BuildContext context) {
    final users = ref.watch(userProvider(_searchController.text));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select User'),
        backgroundColor: Colors.teal,
      ),
      body: GestureDetector(
        onTap: () {
          setState(() {
            _showDropdown = false;
          });
        },
        child: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey,
                                spreadRadius: 1,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _searchController,
                            decoration: const InputDecoration(
                              hintText: 'Search User',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 20),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _showDropdown = value.isNotEmpty;
                              });
                            },
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.search, color: Colors.teal),
                        onPressed: () {
                          setState(() {
                            _showDropdown = true;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                
                Expanded(
                  child: ListView.builder(
                    itemCount: _selectedUsers.length,
                    itemBuilder: (context, index) {
                      final user = _selectedUsers[index];
                      return ListTile(
                        tileColor: Colors.teal.withOpacity(0.1),
                        title: Text(
                          user['username'],
                          style: const TextStyle(color: Colors.teal),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                chatId: user['id'],
                                username: user['username'],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),

            if (_showDropdown)
              Positioned(
                top: 100,
                left: 20,
                right: 20,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: users.when(
                    data: (data) {
                      final matchingUsers = data.where((user) {
                        final username = user['username'].toLowerCase();
                        final searchText = _searchController.text.toLowerCase();
                        return username.contains(searchText);
                      }).toList();

                      if (matchingUsers.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text('No users found', style: TextStyle(color: Colors.grey)),
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: matchingUsers.length,
                        itemBuilder: (context, index) {
                          final user = matchingUsers[index];
                          return ListTile(
                            title: Text(
                              user['username'],
                              style: const TextStyle(color: Colors.black),
                            ),
                            onTap: () {
                              setState(() {
                                _showDropdown = false;
                                print("Hello");
                                if (!_selectedUsers.any((u) => u['id'] == user['id'])) {
                                  _selectedUsers.add({'id': user['id'], 'username': user['username']});
                                }
                                print("by");
                              });
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatScreen(
                                    chatId: user['id'],
                                    username: user['username'],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                    loading: () => const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (err, stack) => Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text('Error: $err', style: const TextStyle(color: Colors.red)),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
