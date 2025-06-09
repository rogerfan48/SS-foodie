import 'package:flutter/material.dart';
import 'package:foodie/services/ai_chat.dart';
import 'package:foodie/services/map_position.dart';
import 'package:foodie/view_models/account_vm.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:foodie/widgets/ai/ai_recommendation_button.dart';
import 'package:foodie/widgets/ai/recommended_restaurant_card.dart';

class AiPage extends StatefulWidget {
  const AiPage({super.key});

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 監聽 chat service 的變化，當有新訊息時滾動到底部
    final chat = context.watch<AiChatService>();
    if (chat.messages.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    final user = context.read<AccountViewModel>().firebaseUser;
    final chatService = context.read<AiChatService>();

    if (text.isEmpty || user == null || chatService.isLoading) return;

    final messageToSend = Message(text: text);
    _controller.clear();
    FocusScope.of(context).unfocus();

    await chatService.addMessage(messageToSend, user.uid);
  }

  @override
  Widget build(BuildContext context) {
    final chat = context.watch<AiChatService>();
    final user = context.watch<AccountViewModel>().firebaseUser;

    if (user == null) {
      return const Center(child: Text("Please log in to use AI assistant."));
    }

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              // 增加底部空間，避免被輸入框和推薦按鈕遮擋
              padding: const EdgeInsets.only(bottom: 130.0),
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                itemCount: chat.messages.length,
                itemBuilder: (context, index) {
                  final msg = chat.messages[index];
                  return _buildMessageItem(context, msg);
                },
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                // 增加一點漸變效果，讓 UI 更有層次感
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Theme.of(context).scaffoldBackgroundColor.withOpacity(0.0),
                      Theme.of(context).scaffoldBackgroundColor,
                      Theme.of(context).scaffoldBackgroundColor,
                    ],
                    stops: const [0, 0.4, 1],
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 35,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          AiRecommendationButton(msg: "推薦我一些晚餐選擇", userId: user.uid),
                          const SizedBox(width: 8),
                          AiRecommendationButton(msg: "附近有什麼好吃的？", userId: user.uid),
                          const SizedBox(width: 8),
                          AiRecommendationButton(msg: "我想吃點辣的", userId: user.uid),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 3,
                      textInputAction: TextInputAction.newline,
                      enabled: !chat.isLoading,
                      decoration: InputDecoration(
                        hintText: "Chat with AI...",
                        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                        suffixIcon: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            chat.isLoading
                                ? const Padding(
                                  padding: EdgeInsets.all(12.0),
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2.0),
                                  ),
                                )
                                : IconButton(
                                  // ✅ 按鈕在 loading 時會被禁用
                                  onPressed: chat.isLoading ? null : _sendMessage,
                                  icon: const Icon(Icons.send),
                                ),
                          ],
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageItem(BuildContext context, Message msg) {
    final isUser = msg.isUser;
    final theme = Theme.of(context);

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin:
            isUser
                ? const EdgeInsets.fromLTRB(64, 8, 0, 4)
                : const EdgeInsets.fromLTRB(0, 8, 64, 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isUser ? theme.colorScheme.primaryContainer : theme.colorScheme.tertiaryContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              msg.text,
              style: TextStyle(
                color:
                    isUser
                        ? theme.colorScheme.onPrimaryContainer
                        : theme.colorScheme.onTertiaryContainer,
              ),
            ),
            if (msg.recommendations.isNotEmpty) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 150,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: msg.recommendations.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final restaurant = msg.recommendations[index];
                    return RecommendedRestaurantCard(
                      restaurant: restaurant,
                      onTap: () {
                        final mapPositionService = context.read<MapPositionService>();
                        mapPositionService.updateId(restaurant.id);
                        context.go('/map');
                      },
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
