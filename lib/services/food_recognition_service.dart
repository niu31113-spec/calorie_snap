import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../models/food_result.dart';

/// 大模型平台:阿里云百炼(通义千问-VL) 或 火山方舟(豆包-视觉)
enum AiProvider { aliyun, doubao }

extension AiProviderInfo on AiProvider {
  /// 平台展示名
  String get label {
    switch (this) {
      case AiProvider.aliyun:
        return '阿里云百炼(通义千问)';
      case AiProvider.doubao:
        return '火山方舟(豆包)';
    }
  }

  /// OpenAI 兼容端点
  String get endpoint {
    switch (this) {
      case AiProvider.aliyun:
        return 'https://dashscope.aliyuncs.com/compatible-mode/v1/chat/completions';
      case AiProvider.doubao:
        return 'https://ark.cn-beijing.volces.com/api/v3/chat/completions';
    }
  }

  /// 默认视觉模型名
  String get model {
    switch (this) {
      case AiProvider.aliyun:
        return 'qwen-vl-plus';
      case AiProvider.doubao:
        // 豆包视觉模型(火山方舟通用视觉入口)
        return 'doubao-vision-pro-32k-241028';
    }
  }

  /// 申请 API Key 的官网地址
  String get applyUrl {
    switch (this) {
      case AiProvider.aliyun:
        return 'https://bailian.console.aliyun.com';
      case AiProvider.doubao:
        return 'https://console.volcengine.com/ark';
    }
  }
}

/// 食物识别服务:把照片发给多模态大模型,返回食物名称与热量估算。
///
/// 同时支持「阿里云百炼(通义千问-VL)」与「火山方舟(豆包视觉)」,
/// 二者都是 OpenAI 兼容接口,只需切换 [provider] 即可。
class FoodRecognitionService {
  final String apiKey;
  final AiProvider provider;

  FoodRecognitionService({
    required this.apiKey,
    this.provider = AiProvider.aliyun,
  });

  bool get hasKey => apiKey.trim().isNotEmpty;

  /// 识别图片中的食物,返回 [MealResult]
  ///
  /// [imageBytes] 为图片字节数组(Web / 手机通用,由 image_picker 的
  /// XFile.readAsBytes() 提供)。
  Future<MealResult> recognize(Uint8List imageBytes) async {
    if (!hasKey) {
      throw Exception('未配置 API Key,请先在「我的」页面填写 API Key。');
    }

    final base64Image = base64Encode(imageBytes);
    final dataUri = 'data:image/jpeg;base64,$base64Image';

    const prompt = '''
你是一位营养师。请识别这张图片里的食物,估算每种食物的分量与营养。
只返回 JSON,不要任何多余文字,格式如下:
{
  "items": [
    {"name": "食物名称", "calories": 热量千卡数字, "protein": 蛋白质克, "carbs": 碳水克, "fat": 脂肪克}
  ]
}
如果图片里没有食物,返回 {"items": []}。
''';

    final body = {
      'model': provider.model,
      'messages': [
        {
          'role': 'user',
          'content': [
            {
              'type': 'image_url',
              'image_url': {'url': dataUri}
            },
            {'type': 'text', 'text': prompt}
          ]
        }
      ],
    };

    final resp = await http.post(
      Uri.parse(provider.endpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode(body),
    );

    if (resp.statusCode != 200) {
      throw Exception('识别失败(${resp.statusCode}):${utf8.decode(resp.bodyBytes)}');
    }

    final decoded = jsonDecode(utf8.decode(resp.bodyBytes));
    final content =
        decoded['choices']?[0]?['message']?['content']?.toString() ?? '';

    final items = _parseItems(content);
    return MealResult(
      time: DateTime.now(),
      items: items,
      imageBase64: base64Image,
    );
  }

  /// 从模型返回的文本里提取 JSON 并解析出食物列表
  List<FoodItem> _parseItems(String content) {
    try {
      final jsonStr = _extractJson(content);
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      final list = (map['items'] as List?) ?? [];
      return list
          .map((e) => FoodItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      // 解析失败时返回空列表,避免崩溃
      return [];
    }
  }

  /// 从可能带有 ```json ``` 包裹的文本中提取纯 JSON 段
  String _extractJson(String text) {
    var t = text.trim();
    final start = t.indexOf('{');
    final end = t.lastIndexOf('}');
    if (start >= 0 && end > start) {
      return t.substring(start, end + 1);
    }
    return t;
  }
}