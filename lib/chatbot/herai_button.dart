import 'package:flutter/material.dart';
import 'chat_screen.dart';

class HerAIButton extends StatelessWidget {
  const HerAIButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      label: const Text("Chat with HerAI 🤖"),
      onPressed: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => const ChatScreen(),
        );
      },
      backgroundColor: Colors.pinkAccent.shade100,
    );
  }
}
