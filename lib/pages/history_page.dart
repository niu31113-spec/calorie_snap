import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/food_result.dart';
import '../state/app_state.dart';

/// 历史饮食记录列表
class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final history = app.history;

    return Scaffold(
      appBar: AppBar(
        title: const Text('饮食历史'),
        actions: [
          if (history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: '清空记录',
              onPressed: () => _confirmClear(context, app),
            ),
        ],
      ),
      body: history.isEmpty
          ? const Center(
              child: Text('还没有记录,先去拍一张食物照片吧',
                  style: TextStyle(color: Colors.black54)),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: history.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                // 最新的排在最前面
                final meal = history[history.length - 1 - index];
                return _MealCard(meal: meal);
              },
            ),
    );
  }

  Future<void> _confirmClear(BuildContext context, AppState app) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('清空历史'),
        content: const Text('确定要删除所有饮食记录吗?此操作不可恢复。'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('取消')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('清空')),
        ],
      ),
    );
    if (ok == true) {
      await app.clearHistory();
    }
  }
}

class _MealCard extends StatelessWidget {
  final MealResult meal;
  const _MealCard({required this.meal});

  @override
  Widget build(BuildContext context) {
    final timeText = DateFormat('MM-dd HH:mm').format(meal.time);
    final names = meal.items.map((e) => e.name).join('、');
    final imageBytes = (meal.imageBase64 != null &&
            meal.imageBase64!.isNotEmpty)
        ? base64Decode(meal.imageBase64!)
        : null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageBytes != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(imageBytes,
                    width: 64, height: 64, fit: BoxFit.cover),
              )
            else
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.restaurant, color: Colors.black38),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(timeText,
                      style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 4),
                  Text(names.isEmpty ? '未识别' : names,
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text('${meal.totalCalories.toStringAsFixed(0)} 千卡',
                style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}