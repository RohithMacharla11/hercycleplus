import 'package:flutter/material.dart';
import 'message_bubble.dart';
import 'input_field.dart';
import 'herai_service.dart';
import 'message_storage_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  List<Map<String, String>> _messages = [];
  bool _isLoading = false;
  String? _userName;

  @override
  void initState() {
    super.initState();
    _loadChat();
  }

  Future<void> _loadChat() async {
    _userName = await MessageStorageService.getUserName();
    _messages = await MessageStorageService.loadMessages();
    if (_messages.isEmpty) {
      if (_userName == null) {
        _messages.add({'sender': 'HerAI', 'text': "Hello! I’m HerAI, your women’s wellness assistant 💖. May I know your name?"});
      } else {
        _messages.add({'sender': 'HerAI', 'text': "Hi again, $_userName! 🌸 Ready to continue our wellness journey?"});
      }
    }
    setState(() {});
    _autoScroll();
  }

  Future<void> _sendMessage(String text) async {
    setState(() {
      _messages.add({'sender': 'user', 'text': text});
      _isLoading = true;
    });
    await MessageStorageService.saveMessages(_messages);
    _autoScroll();

    await Future.delayed(const Duration(milliseconds: 500));

    String aiReply;
    if (_userName == null) {
      _userName = text.split(' ').first;
      await MessageStorageService.setUserName(_userName!);
      aiReply = "Nice to meet you, $_userName! 🌸 Feel free to ask about cycles, PCOS, mental health, fitness, and wellness.";
    } else {
      aiReply = HerAIService.generateReply(text);
    }

    setState(() {
      _messages.add({'sender': 'HerAI', 'text': aiReply});
      _isLoading = false;
    });
    await MessageStorageService.saveMessages(_messages);
    _autoScroll();
  }

  void _autoScroll() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.pinkAccent.shade100,
        title: const Text('HerAI Assistant 🤖'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFFFF0F5),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(12),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  return MessageBubble(
                    isUser: msg['sender'] == 'user',
                    text: msg['text']!,
                  );
                },
              ),
            ),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(color: Colors.pinkAccent),
              ),
            InputField(onSend: _sendMessage),
          ],
        ),
      ),
    );
  }
}