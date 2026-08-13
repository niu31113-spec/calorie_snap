import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/food_result.dart';
import '../services/food_recognition_service.dart';
import '../services/health_calculator.dart';
import '../state/app_state.dart';

/// 拍照 / 选图 → 调用大模型识别 → 展示热量与建议
class RecognizePage extends StatefulWidget {
  const RecognizePage({super.key});

  @override
  State<RecognizePage> createState() => _RecognizePageState();
}

class _RecognizePageState extends State<RecognizePage> {
  final _picker = ImagePicker();
  Uint8List? _imageBytes;
  MealResult? _result;
  bool _loading = false;
  String? _error;

  Future<void> _pick(ImageSource source) async {
    setState(() {
      _error = null;
    });
    final x = await _picker.pickImage(source: source, imageQuality: 85);
    if (x == null) return;
    // XFile.readAsBytes() 在 Web 和手机上都可用,不依赖 dart:io
    final bytes = await x.readAsBytes();
    setState(() {
      _imageBytes = bytes;
      _result = null;
    });
    await _recognize();
  }

  Future<void> _recognize() async {
    final app = context.read<AppState>();
    if (app.apiKey.trim().isEmpty) {
      setState(() => _error = '还没有配置 API Key,请到「我的」页面填写。');
      return;
    }
    if (_imageBytes == null) return;

    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final service = FoodRecognitionService(apiKey: app.apiKey);
      final result = await service.recognize(_imageBytes!);
      if (result.items.isEmpty) {
        setState(() => _error = '没有识别到食物,换一张更清晰的照片试试。');
      } else {
        await app.addMeal(result);
        setState(() => _result = result);
      }
    } catch (e) {
      setState(() => _error = '$e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final target = HealthCalculator.dailyTarget(app.profile);

    return Scaffold(
      appBar: AppBar(title: const Text('拍照识别热量')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTodayCard(app.todayCalories, target),
            const SizedBox(height: 16),
            _buildImageArea(),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _loading ? null : () => _pick(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('拍照'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed:
                        _loading ? null : () => _pick(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('相册'),
                  ),
                ),
              ],
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
            if (_result != null) ...[
              const SizedBox(height: 16),
              _buildResult(_result!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTodayCard(double today, double target) {
    final ratio = target <= 0 ? 0.0 : (today / target).clamp(0.0, 1.0);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('今日摄入',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('${today.toStringAsFixed(0)} / ${target.toStringAsFixed(0)} 千卡',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: ratio, minHeight: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildImageArea() {
    if (_imageBytes == null) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text('拍一张或选一张食物照片开始识别',
              style: TextStyle(color: Colors.black54)),
        ),
      );
    }
    return Stack(
      alignment: Alignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.memory(_imageBytes!, height: 220, width: double.infinity,
              fit: BoxFit.cover),
        ),
        if (_loading)
          Container(
            height: 220,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.black45,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          ),
      ],
    );
  }

  Widget _buildResult(MealResult result) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('识别结果',
                style: Theme.of(context).textTheme.titleMedium),
            const Divider(),
            ...result.items.map((f) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(f.name),
                  subtitle: Text(
                      '蛋白 ${f.protein.toStringAsFixed(0)}g · 碳水 ${f.carbs.toStringAsFixed(0)}g · 脂肪 ${f.fat.toStringAsFixed(0)}g'),
                  trailing: Text('${f.calories.toStringAsFixed(0)} 千卡'),
                )),
            const Divider(),
            Align(
              alignment: Alignment.centerRight,
              child: Text('合计 ${result.totalCalories.toStringAsFixed(0)} 千卡',
                  style: Theme.of(context).textTheme.titleMedium),
            ),
          ],
        ),
      ),
    );
  }
}