import 'package:flutter/material.dart';

class RestaurantWriteReviewPage extends StatefulWidget {
  const RestaurantWriteReviewPage({super.key});

  @override
  State<RestaurantWriteReviewPage> createState() => _RestaurantWriteReviewPageState();
}

class _RestaurantWriteReviewPageState extends State<RestaurantWriteReviewPage> {
  // 這裡可以加入 TextEditingController 等來管理表單狀態
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Specific review'),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(), // 向下收回
          )
        ],
        automaticallyImplyLeading: false, // 隱藏預設的返回按鈕
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          // 這裡根據您的設計圖 (CleanShot ... at 22.27.09) 建立表單 UI
          children: [
            // ... Specific review, Overall, Price ...
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                child: const Text('Submit'),
                onPressed: () {
                  // TODO: 執行提交評論的邏輯
                  // 提交後也可以用 Navigator.of(context).pop(); 關閉
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
