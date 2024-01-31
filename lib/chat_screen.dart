import 'package:flutter/material.dart';
import 'irc_client.dart'; // Import the IRC client class

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<String> _messages = []; // List to store chat messages
  late IrcClient _ircClient;

  @override
  void initState() {
    super.initState();
    _ircClient = IrcClient(onMessage: _handleIrcMessage);
    _ircClient.connect();
  }

  void _handleIrcMessage(String message) {
    setState(() {
      _messages.add(message);
    });
  }

  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      _ircClient.sendMessage(_messageController.text);
      setState(() {
        _messages.add('You: ${_messageController.text}');
        _messageController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
      ),
      body: Column(
        children: [
          // Chat display area
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(_messages[index]),
                );
              },
            ),
          ),
          // Message input area
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    textInputAction: TextInputAction.send,
                    onSubmitted: (String message) {
                      _sendMessage();
                    },
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type your message...',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    _sendMessage();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _ircClient.dispose(); // Close the IRC connection
    super.dispose();
  }
}
