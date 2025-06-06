import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:foodie/theme/theme.dart';
import 'package:foodie/services/ai_chat.dart';
import 'package:foodie/services/navigation.dart';
import 'package:foodie/services/theme.dart';

class FoodieApp extends StatelessWidget {
  const FoodieApp({super.key});

  @override
  Widget build(BuildContext context) {
    MaterialTheme theme = MaterialTheme();

    return MultiProvider(
      providers: [
        Provider<NavigationService>(create: (_) => NavigationService()),
        ChangeNotifierProvider<ThemeService>(create: (_) => ThemeService()),
        ChangeNotifierProvider<AiChatService>(create: (_) => AiChatService()),
      ],
      child: Consumer<ThemeService>(
        builder: (context, themeService, child) {
          return MaterialApp.router(
            title: 'Foodie',
            theme: theme.light(),
            darkTheme: theme.dark(),
            themeMode: themeService.themeMode,
            routerConfig: routerConfig,
            // Allow the Navigator built by the MaterialApp to restore the navigation stack when app restarts
            restorationScopeId: 'app',
          );
        },
      ),
    );
  }
}
