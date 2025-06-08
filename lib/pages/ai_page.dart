import 'package:flutter/material.dart';
import 'package:foodie/services/ai_chat.dart';
import 'package:foodie/services/map_position.dart';
import 'package:foodie/view_models/account_vm.dart';
import 'package:foodie/view_models/all_restaurants_vm.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:foodie/widgets/ai/ai_recommendation_button.dart';

class AiPage extends StatefulWidget {
  const AiPage({Key? key}) : super(key: key);

  @override
  State<AiPage> createState() => _AiPageState();
}

class _AiPageState extends State<AiPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chat = context.watch<AiChatService>();
    final user = context.read<AccountViewModel>().firebaseUser;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
        );
      }
    });

    return user == null
        ? Center(child: Text("pls login"))
        : Scaffold(
          body: SafeArea(
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 16,
                  right: 16,
                  bottom: 120,
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(top: 16, bottom: 16),
                    itemCount: chat.messages.length,
                    itemBuilder: (context, index) {
                      final msg = chat.messages[index];
                      return Align(
                        alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                        child:
                            msg.isLink
                                ? Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.errorContainer,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: TextButton(
                                      onPressed: () {
                                        final item = context
                                            .read<AllRestaurantViewModel>()
                                            .restaurants
                                            .firstWhere((item) => item.restaurantId == msg.message);
                                        context.read<MapPositionService>().updatePosition(
                                          LatLng(item.latitude, item.longitude),
                                        );
                                        context.read<MapPositionService>().updateId(msg.message);
                                        context.go('/map');
                                      },
                                      child: Text(
                                        context
                                            .read<AllRestaurantViewModel>()
                                            .restaurants
                                            .firstWhere((item) => item.restaurantId == msg.message)
                                            .restaurantName, style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
                                      ),
                                    ),
                                  ),
                                )
                                : Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.primaryContainer,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      msg.message,
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                                      ),
                                    ),
                                  ),
                                ),
                      );
                    },
                  ),
                ),
                Positioned(
                  bottom: 85,
                  left: 16,
                  right: 16,
                  child: SizedBox(
                    height: 30,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        SizedBox(width: 8),
                        AiRecommendationButton(msg: "AI Recommendation 1", userId: user.uid),
                        SizedBox(width: 8),
                        AiRecommendationButton(msg: "AI Recommendation 2", userId: user.uid),
                        SizedBox(width: 8),
                        AiRecommendationButton(msg: "AI Recommendation 3", userId: user.uid),
                        SizedBox(width: 8),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 30,
                  left: 16,
                  right: 16,
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Chat with AI",
                      suffixIcon: IconButton(
                        onPressed: () async {
                          FocusScope.of(context).unfocus();
                          await context.read<AiChatService>().addMessage(
                            Message(message: _controller.text),
                            user.uid,
                          );
                          _controller.clear();
                        },
                        icon: Icon(Icons.send),
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(32)),
                      contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    ),
                    onSubmitted: (value) async {
                      await context.read<AiChatService>().addMessage(
                        Message(message: "8Nsa4q0LZMUO6b8wRPsr", isUser: false, isLink: true),
                        user.uid,
                      );
                      _controller.clear();
                    },
                  ),
                ),
              ],
            ),
          ),
        );
  }
}
