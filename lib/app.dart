import 'package:flutter/material.dart';
import 'package:foodie/services/auth_service.dart';
import 'package:foodie/view_models/account_vm.dart';
import 'package:provider/provider.dart';
import 'package:foodie/theme/theme.dart';
import 'package:foodie/services/ai_chat.dart';
import 'package:foodie/services/navigation.dart';
import 'package:foodie/services/theme.dart';
import 'package:foodie/pages/firestore_test_page/firestore_data_page.dart'; 

class FoodieApp extends StatelessWidget {
  const FoodieApp({super.key});

  @override
  Widget build(BuildContext context) {
    MaterialTheme theme = MaterialTheme();

    return MultiProvider(
      providers: [
        // Services
        Provider<NavigationService>(create: (_) => NavigationService()),
        Provider<AuthService>(create: (_) => AuthService()),
        
        // View Models & Notifiers
        ChangeNotifierProvider<ThemeService>(create: (_) => ThemeService()),
        ChangeNotifierProvider<AiChatService>(create: (_) => AiChatService()),
        ChangeNotifierProvider<AccountViewModel>(
          create: (context) => AccountViewModel(context.read<AuthService>()),
        ),
      ],
      child: Consumer<ThemeService>(
        builder: (context, themeService, child) {
          return MaterialApp.router(
            title: 'Foodie',
            theme: theme.light(),
            darkTheme: theme.dark(),
            themeMode: themeService.themeMode,
            routerConfig: routerConfig,
            restorationScopeId: 'app',
          );
        },
      ),
    );
  }
}

class TestFirebaseApp extends StatelessWidget {
  const TestFirebaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Foodie - Firestore Viewer',
      theme: MaterialTheme().light(),
      darkTheme: MaterialTheme().dark(),
      // instead of routerConfig, just show your FirestoreDataPage:
      home: const FirestoreDataPage(),
      // remove routerConfig/restorationScopeId if not needed here
    );
  }
}