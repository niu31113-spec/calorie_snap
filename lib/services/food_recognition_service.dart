import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../models/food_result.dart';

/// 食物识别服务:把照片发给多模态大模型,返回食物名称与热量估算。
///
/// 默认使用「通义千问-VL」的 OpenAI 兼容接口。
/// 你也可以换成 Gemini / GPT-4o,只需改 [_endpoint] 和请求体格式。
class FoodRecognitionService {
  /// 阿里云百炼(通义千问)OpenAI 兼容端点
  static const String _endpoint =
      'https://dashscope.aliyuncs.com/compatible-mode/v1/chat/completions';
  static const String _model = 'qwen-vl-plus';

  final String apiKey;

  FoodRecognitionService({required this.apiKey});

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
      'model': _model,
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
      Uri.parse(_endpoint),
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
    if (t.contains('```')) {
      final start = t.indexOf('{');
      final end = t.lastIndexOf('}');
      if (start >= 0 && end > start) {
        return t.substring(start, end + 1);
      }
    }
    final start = t.indexOf('{');
    final end = t.lastIndexOf('}');
    if (start >= 0 && end > start) {
      return t.substring(start, end + 1);
    }
    return t;
  }
}