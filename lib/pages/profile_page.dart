import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user_profile.dart';
import '../services/health_calculator.dart';
import '../state/app_state.dart';

/// 个人资料页:身高体重、目标、API Key,以及健康指标展示
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _heightCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _apiKeyCtrl = TextEditingController();

  Gender _gender = Gender.male;
  ActivityLevel _activity = ActivityLevel.moderate;
  Goal _goal = Goal.maintain;
  bool _inited = false;

  @override
  void dispose() {
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    _ageCtrl.dispose();
    _apiKeyCtrl.dispose();
    super.dispose();
  }

  void _loadFrom(AppState app) {
    final p = app.profile;
    _heightCtrl.text = p.heightCm.toStringAsFixed(0);
    _weightCtrl.text = p.weightKg.toStringAsFixed(0);
    _ageCtrl.text = p.age.toString();
    _apiKeyCtrl.text = app.apiKey;
    _gender = p.gender;
    _activity = p.activityLevel;
    _goal = p.goal;
    _inited = true;
  }

  Future<void> _save(AppState app) async {
    final profile = UserProfile(
      heightCm: double.tryParse(_heightCtrl.text) ?? 170,
      weightKg: double.tryParse(_weightCtrl.text) ?? 65,
      age: int.tryParse(_ageCtrl.text) ?? 25,
      gender: _gender,
      activityLevel: _activity,
      goal: _goal,
    );
    await app.updateProfile(profile);
    await app.updateApiKey(_apiKeyCtrl.text.trim());
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('已保存')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    if (!_inited && app.loaded) _loadFrom(app);

    final bmi = HealthCalculator.bmi(app.profile);
    final tdee = HealthCalculator.tdee(app.profile);
    final target = HealthCalculator.dailyTarget(app.profile);

    return Scaffold(
      appBar: AppBar(title: const Text('我的')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHealthCard(bmi, tdee, target),
          const SizedBox(height: 16),
          _buildField('身高(cm)', _heightCtrl, TextInputType.number),
          _buildField('体重(kg)', _weightCtrl, TextInputType.number),
          _buildField('年龄', _ageCtrl, TextInputType.number),
          const SizedBox(height: 8),
          _buildGender(),
          const SizedBox(height: 8),
          _buildActivity(),
          const SizedBox(height: 8),
          _buildGoal(),
          const SizedBox(height: 16),
          _buildApiKey(),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => _save(app),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('保存'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthCard(double bmi, double tdee, double target) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('健康指标', style: Theme.of(context).textTheme.titleMedium),
            const Divider(),
            _row('BMI',
                '${bmi.toStringAsFixed(1)}(${HealthCalculator.bmiCategory(bmi)})'),
            _row('每日消耗 TDEE', '${tdee.toStringAsFixed(0)} 千卡'),
            _row('每日推荐摄入', '${target.toStringAsFixed(0)} 千卡'),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildField(
      String label, TextEditingController ctrl, TextInputType type) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: ctrl,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildGender() {
    return Row(
      children: [
        const Text('性别:'),
        const SizedBox(width: 12),
        ChoiceChip(
          label: const Text('男'),
          selected: _gender == Gender.male,
          onSelected: (_) => setState(() => _gender = Gender.male),
        ),
        const SizedBox(width: 8),
        ChoiceChip(
          label: const Text('女'),
          selected: _gender == Gender.female,
          onSelected: (_) => setState(() => _gender = Gender.female),
        ),
      ],
    );
  }

  Widget _buildActivity() {
    return DropdownButtonFormField<ActivityLevel>(
      value: _activity,
      decoration: const InputDecoration(
        labelText: '活动水平',
        border: OutlineInputBorder(),
      ),
      items: ActivityLevel.values
          .map((e) => DropdownMenuItem(
                value: e,
                child: Text(HealthCalculator.activityText(e)),
              ))
          .toList(),
      onChanged: (v) => setState(() => _activity = v ?? _activity),
    );
  }

  Widget _buildGoal() {
    return Row(
      children: Goal.values.map((g) {
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ChoiceChip(
            label: Text(HealthCalculator.goalText(g)),
            selected: _goal == g,
            onSelected: (_) => setState(() => _goal = g),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildApiKey() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildField('大模型 API Key', _apiKeyCtrl, TextInputType.text),
        const Padding(
          padding: EdgeInsets.only(left: 4, top: 4),
          child: Text(
            '用于拍照识别食物,基本免费。\n'
            '申请步骤:①打开阿里云百炼 bailian.console.aliyun.com '
            '②登录后在「API-KEY」页面创建 Key ③新用户有免费额度,拍照日常够用。\n'
            'Key 只保存在本机,不会上传。',
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ),
      ],
    );
  }
}