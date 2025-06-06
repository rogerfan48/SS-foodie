import 'package:flutter/material.dart';
import 'package:foodie/services/ai_chat.dart';
import 'package:provider/provider.dart';

class AiPage extends StatefulWidget {
  const AiPage({Key? key}) : super(key: key);

  @override
  State<AiPage> createState() => _AiPageState();
}

class _AiPageState extends State<AiPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chat = context.watch<AiChatService>();
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              bottom: 100,
              left: 16,
              right: 16,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children:
                    chat.messages
                        .map(
                          (msg) => Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                msg,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
              ),
            ),
            Positioned(
              bottom: 30,
              left: 16,
              right: 16,
              child: Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: "Chat with AI",
                    suffixIcon: IconButton(
                      onPressed: () {
                        context.read<AiChatService>().addMessage(_controller.text);
                        _controller.clear();
                      },
                      icon: Icon(Icons.send),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(32)),
                    contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
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
