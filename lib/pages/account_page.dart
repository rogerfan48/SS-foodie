import 'package:flutter/material.dart';
import 'package:foodie/services/theme.dart';
import 'package:provider/provider.dart';

class AccountPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset('assets/imgs/account.png', width: 75),
                  ElevatedButton(
                    onPressed: () {
                      // Login google account
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8), // 圓角
                      ),
                    ),
                    child: const Text('Log in with Google', style: TextStyle(fontSize: 20)),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 108,
              left: 16,
              right: 16,
              child: Column(
                children: [
                  Container(
                    height: 1, // 線條高度
                    color: Colors.black, // 線條顏色
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('瀏覽記錄', style: TextStyle(fontSize: 20)),
                      ElevatedButton(
                        onPressed: () {
                          // Jump to Browse Record
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.surface,
                          foregroundColor: Theme.of(context).colorScheme.onSurface,
                        ),
                        child: const Text('>', style: TextStyle(fontSize: 20)),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Container(
                    height: 1, // 線條高度
                    color: Colors.black, // 線條顏色
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('我的評論', style: TextStyle(fontSize: 20)),
                      ElevatedButton(
                        onPressed: () {
                          // Jump to My Review
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.surface,
                          foregroundColor: Theme.of(context).colorScheme.onSurface,
                        ),
                        child: const Text('>', style: TextStyle(fontSize: 20)),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Container(
                    height: 1, // 線條高度
                    color: Colors.black, // 線條顏色
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('模式', style: TextStyle(fontSize: 20)),
                      ElevatedButton(
                        onPressed: () {
                          context.read<ThemeService>().toggleTheme();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.surface,
                          foregroundColor: Theme.of(context).colorScheme.onSurface,
                        ),
                        child: const Text('淺色模式', style: TextStyle(fontSize: 20)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
