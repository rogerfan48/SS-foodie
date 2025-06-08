import 'package:flutter/material.dart';

class AiChatService with ChangeNotifier {
  final List<Message> _messages = [];

  List<Message> get messages => _messages;

  Future<void> addMessage(Message msg, String id) async {
    if (msg.message.isNotEmpty) {
      _messages.add(msg);
      final input = {
        "messages": _messages.map((msg) => {"text": msg.message, "isUser": msg.isUser}).toList(),
        "userId": id,
      };
      // final Map<String, dynamic> output = await AI(input);
      // if (output["question"] == "") {                       // isLink
      //   _messages.add(Message(message: output["recommendRestaurantId"].join(" "), isUser: false, isLink: true));
      // }
      // else {
      //   _messages.add(Message(message: output["question"], isUser: false));
      // }
    }
    notifyListeners();
  }
}

class Message {
  final String message;
  final bool isUser;
  final bool isLink;

  Message({required this.message, this.isUser = true, this.isLink = false});
}
