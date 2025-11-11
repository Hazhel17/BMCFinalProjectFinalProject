import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isCurrentUser;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isCurrentUser, // This boolean controls alignment and color
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // 1. Align right if I'm the sender, left if I'm not
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          // Max width is 70% of the screen width
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        // 2. Different color for me vs. them
        decoration: BoxDecoration(
          color: isCurrentUser ? Colors.green[400] : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          message,
          style: TextStyle(
            // Text color is white for the current user's deep purple bubble
            color: isCurrentUser ? Colors.white : Colors.black87,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}