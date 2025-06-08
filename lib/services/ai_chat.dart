import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';

class AiChatService with ChangeNotifier {
  final List<Message> _messages = [];

  List<Message> get messages => _messages;

  Future<void> addMessage(Message msg, String id) async {
    if (msg.message.isNotEmpty) {
      _messages.add(msg);

      final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
        'recommendRestaurant',
      );
      final response = await callable.call({
        "messages": _messages.map((msg) => {"text": msg.message, "isUser": msg.isUser}).toList(),
        "userId": id,
      });
      final data = Map<String, dynamic>.from(response.data as Map);
      if (data['recommendRestaurantId'].isEmpty) {
        _messages.add(Message(message: data['question'], isUser: false));
      }
      else {
        _messages.add(Message(message: data['question'] + "\\split\\" + data['recommendRestaurantId'].join("\\split\\"), isUser: false, isLink: true));
      }
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
