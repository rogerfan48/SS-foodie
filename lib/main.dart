import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'app.dart';
import 'firebase_options.dart';
import 'repositories/restaurant_repo.dart';
import 'repositories/review_repo.dart';
import 'repositories/user_repo.dart';
import 'services/ai_chat.dart';
import 'services/auth_service.dart';
import 'services/navigation.dart';
import 'services/theme.dart';
import 'view_models/account_vm.dart';
import 'view_models/my_reviews_vm.dart';
import 'view_models/viewed_restaurants_vm.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        // 1. Repositories
        Provider<UserRepository>(create: (_) => UserRepository()),
        Provider<ReviewRepository>(create: (_) => ReviewRepository()),
        Provider<RestaurantRepository>(create: (_) => RestaurantRepository()),

        // 2. Firebase 服務實例
        Provider<FirebaseAuth>(create: (_) => FirebaseAuth.instance),
        Provider<GoogleSignIn>(create: (_) => GoogleSignIn()),

        // 3. Services
        ProxyProvider3<FirebaseAuth, GoogleSignIn, UserRepository, AuthService>(
          update:
              (_, auth, googleSignIn, userRepo, previous) =>
                  AuthService(auth, googleSignIn, userRepo),
        ),

        // 4. Global ViewModels & Notifiers
        ChangeNotifierProvider<ThemeService>(create: (_) => ThemeService()),
        ChangeNotifierProvider<AiChatService>(create: (_) => AiChatService()),
        ChangeNotifierProvider<AccountViewModel>(
          create: (context) => AccountViewModel(context.read<AuthService>()),
        ),

        // 5. Proxy ViewModels
        ChangeNotifierProxyProvider<AccountViewModel, MyReviewViewModel?>(
          create: (_) => null,
          update: (context, accountViewModel, previous) {
            final userId = accountViewModel.firebaseUser?.uid;
            if (userId == null) return null;
            return MyReviewViewModel(
              userId,
              context.read<ReviewRepository>(),
              context.read<RestaurantRepository>(),
            );
          },
        ),
        ChangeNotifierProxyProvider<AccountViewModel, ViewRestaurantsViewModel?>(
          create: (_) => null,
          update: (context, accountViewModel, previous) {
            final userId = accountViewModel.firebaseUser?.uid;
            if (userId == null) return null;
            return ViewRestaurantsViewModel(
              userId,
              context.read<UserRepository>(),
              context.read<RestaurantRepository>(),
            );
          },
        ),
      ],
      child: const FoodieApp(),
    ),
  );
}
