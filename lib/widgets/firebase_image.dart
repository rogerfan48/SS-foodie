import 'package:flutter/material.dart';
import 'package:foodie/services/storage_service.dart';
import 'package:provider/provider.dart';

class FirebaseImage extends StatelessWidget {
  final String? gsUri;
  final double? width;
  final double? height;
  final BoxFit fit;

  const FirebaseImage({
    super.key,
    required this.gsUri,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    // 從 Provider 獲取 StorageService
    final storageService = context.read<StorageService>();

    return FutureBuilder<String?>(
      // 調用 service 方法獲取下載連結
      future: storageService.getDownloadUrl(gsUri),
      builder: (context, snapshot) {
        // 正在加載
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(strokeWidth: 2.0));
        }
        // 獲取失敗或 URL 為空
        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          return const Icon(Icons.broken_image_outlined, color: Colors.grey);
        }
        // 成功獲取 URL，使用 Image.network 顯示
        final url = snapshot.data!;
        return Image.network(
          url,
          width: width,
          height: height,
          fit: fit,
          // 圖片加載過程中的佔位符
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(child: CircularProgressIndicator(strokeWidth: 2.0));
          },
          // 網路圖片加載失敗的佔位符
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.error_outline, color: Colors.red);
          },
        );
      },
    );
  }
}
