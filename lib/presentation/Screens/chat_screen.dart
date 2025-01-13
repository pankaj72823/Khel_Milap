import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:async/async.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String username;

  const ChatScreen({
    required this.chatId,
    required this.username,
    Key? key,
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final SupabaseClient _supabase = Supabase.instance.client;

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final message = _messageController.text.trim();
    final senderId = _supabase.auth.currentUser!.id;

    await _supabase.from('chats').insert({
      'sender_id': senderId,
      'receiver_id': widget.chatId,
      'message': message,
      'created_at': DateTime.now().toIso8601String(),
    });

    _messageController.clear();
  }


  Stream<List<Map<String, dynamic>>> _getChatStream() {
    final currentUserId = _supabase.auth.currentUser!.id;

    final sentMessagesStream = _supabase
        .from('chats')
        .stream(primaryKey: ['id'])
        .eq('sender_id', currentUserId)
        .order('created_at');

    final receivedMessagesStream = _supabase
        .from('chats')
        .stream(primaryKey: ['id'])
        .eq('receiver_id', currentUserId)
        .order('created_at');

    return StreamGroup.merge([sentMessagesStream, receivedMessagesStream]);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.username),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _getChatStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();
                final messages = snapshot.data!
                    .where((message) =>
                (message['sender_id'] == widget.chatId &&
                    message['receiver_id'] ==
                        _supabase.auth.currentUser!.id) ||
                    (message['receiver_id'] == widget.chatId &&
                        message['sender_id'] ==
                            _supabase.auth.currentUser!.id))
                    .toList();

                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isSentByMe =
                        message['sender_id'] == _supabase.auth.currentUser!.id;
                    return Align(
                      alignment: isSentByMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 4, horizontal: 8),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isSentByMe
                              ? Colors.blueAccent.withOpacity(0.8)
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          message['message'],
                          style: TextStyle(
                            color: isSentByMe ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: 'Type a message',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: _sendMessage,
              ),
            ],
          ),
        ],
      ),
    );
  }
}



// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
//
// class ChatScreen extends StatefulWidget {
//   final User user;
//
//   const ChatScreen({required this.user});
//
//   @override
//   _ChatScreenState createState() => _ChatScreenState();
// }
//
// class _ChatScreenState extends State<ChatScreen> {
//   final TextEditingController _messageController = TextEditingController();
//
//   void _sendMessage() async {
//     if (_messageController.text.isEmpty) return;
//
//     final message = _messageController.text;
//     final senderId = Supabase.instance.client.auth.currentUser!.id;
//
//     await Supabase.instance.client.from('chats').insert({
//       'sender_id': senderId,
//       'receiver_id': widget.user.id,
//       'message': message,
//     });
//
//     _messageController.clear();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text(widget.user.)),
//       body: Column(
//         children: [
//           Expanded(
//             child: StreamBuilder<List<Map<String, dynamic>>>(
//               stream: Supabase.instance.client
//                   .from('chats')
//                   .stream(['id'])
//                   .eq('receiver_id', widget.user.id)
//                   .order('created_at'),
//               builder: (context, snapshot) {
//                 if (!snapshot.hasData) return CircularProgressIndicator();
//                 final messages = snapshot.data!;
//                 return ListView.builder(
//                   itemCount: messages.length,
//                   itemBuilder: (context, index) {
//                     final message = messages[index];
//                     return ListTile(
//                       title: Text(message['message']),
//                       subtitle: Text(message['created_at']),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//           Row(
//             children: [
//               Expanded(
//                 child: TextField(
//                   controller: _messageController,
//                   decoration: InputDecoration(labelText: 'Type a message'),
//                 ),
//               ),
//               IconButton(
//                 icon: Icon(Icons.send),
//                 onPressed: _sendMessage,
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
