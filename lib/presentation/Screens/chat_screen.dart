import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/data_source/supabase_service.dart';

class ChatScreen extends StatefulWidget {
  final String receiverId;
  final String username;

  const ChatScreen({required this.receiverId, required this.username, Key? key})
      : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final SupabaseService _supabaseService = SupabaseService();

  List<Map<String, dynamic>> _messages = [];
  String? _receiverImagePath;
  String? _senderImagePath;
  Timer? _refreshTimer;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _initializeChat() async {
    await _fetchUserProfileImages();
    await _fetchMessages();

    _refreshTimer = Timer.periodic(const Duration(seconds: 1), (_) async {
      await _fetchMessages();
    });
  }

  Future<void> _fetchUserProfileImages() async {
    final senderId = Supabase.instance.client.auth.currentUser!.id;

    final senderImage = await _supabaseService.fetchUserProfileImage(senderId);
    final receiverImage =
    await _supabaseService.fetchUserProfileImage(widget.receiverId);

    setState(() {
      _senderImagePath = senderImage;
      _receiverImagePath = receiverImage;
    });
  }

  Future<void> _fetchMessages() async {
    try {
      final messages = await _supabaseService.fetchMessages(widget.receiverId);
      setState(() {
        _messages = messages;
      });
      _scrollToBottom();  // Scroll to the latest message
    } catch (e) {
      // Handle errors (e.g., log them)
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final senderId = Supabase.instance.client.auth.currentUser!.id;
    await _supabaseService.sendMessage(
      widget.receiverId,
      senderId,
      _messageController.text.trim(),
    );

    _messageController.clear();
    await _fetchMessages(); // Fetch new messages after sending
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.username),
        centerTitle: true,
        elevation: 2.0,  // A subtle shadow for the AppBar
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),  // Padding for the whole screen
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  final isSentByMe =
                      message['sender_id'] == Supabase.instance.client.auth.currentUser!.id;

                  return Row(
                    mainAxisAlignment:
                    isSentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                    children: [
                      if (!isSentByMe && _receiverImagePath != null)
                        CircleAvatar(
                          backgroundImage: FileImage(File(_receiverImagePath!)),
                        ),
                      const SizedBox(width: 8,),
                      if (!isSentByMe && _receiverImagePath == null)
                        const CircleAvatar(
                          child: Icon(Icons.person),
                        ),
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSentByMe ? Colors.blue : Colors.green.shade200,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.6), // Limit the width to 60% of the screen
                          child: Text(
                            message['message'],
                            style: TextStyle(
                              color: isSentByMe ? Colors.white : Colors.black,
                              fontSize: 16,
                            ),
                            softWrap: true, // Ensures text wraps
                            overflow: TextOverflow.visible, // Prevents text from overflowing
                          ),
                        ),
                      ),

                      const SizedBox(width: 8,),
                      if (isSentByMe && _senderImagePath != null)
                        CircleAvatar(
                          backgroundImage: FileImage(File(_senderImagePath!)),
                        ),

                      if (isSentByMe && _senderImagePath == null)
                        const CircleAvatar(
                          child: Icon(Icons.person),
                        ),
                    ],
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: TextField(
                        controller: _messageController,
                        maxLines: null,  // Allow multi-line messages
                        decoration: const InputDecoration(
                          hintText: 'Type a message...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                        ),
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _sendMessage,
                    icon: const Icon(Icons.send),
                    color: Colors.blue,
                    iconSize: 30,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
