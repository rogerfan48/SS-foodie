import 'package:flutter/material.dart';

class AiChatService with ChangeNotifier {
  List<String> _messages = [];

  List<String> get messages => _messages;

  void addMessage(String msg) {
    if (msg.isNotEmpty) {
      _messages.add(msg);
    }
    notifyListeners();
  }
}
