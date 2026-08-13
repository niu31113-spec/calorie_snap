enum Gender { male, female }

enum ActivityLevel { sedentary, light, moderate, active, veryActive }

enum Goal { lose, maintain, gain }

/// 用户身体资料
class UserProfile {
  final double heightCm; // 身高(厘米)
  final double weightKg; // 体重(千克)
  final int age; // 年龄
  final Gender gender; // 性别
  final ActivityLevel activityLevel; // 活动水平
  final Goal goal; // 目标:减脂/维持/增肌

  UserProfile({
    required this.heightCm,
    required this.weightKg,
    required this.age,
    required this.gender,
    this.activityLevel = ActivityLevel.moderate,
    this.goal = Goal.maintain,
  });

  UserProfile copyWith({
    double? heightCm,
    double? weightKg,
    int? age,
    Gender? gender,
    ActivityLevel? activityLevel,
    Goal? goal,
  }) {
    return UserProfile(
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      activityLevel: activityLevel ?? this.activityLevel,
      goal: goal ?? this.goal,
    );
  }

  factory UserProfile.defaultProfile() => UserProfile(
        heightCm: 170,
        weightKg: 65,
        age: 25,
        gender: Gender.male,
      );

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        heightCm: (json['heightCm'] as num).toDouble(),
        weightKg: (json['weightKg'] as num).toDouble(),
        age: json['age'] as int,
        gender: Gender.values[json['gender'] as int],
        activityLevel: ActivityLevel.values[json['activityLevel'] as int? ?? 2],
        goal: Goal.values[json['goal'] as int? ?? 1],
      );

  Map<String, dynamic> toJson() => {
        'heightCm': heightCm,
        'weightKg': weightKg,
        'age': age,
        'gender': gender.index,
        'activityLevel': activityLevel.index,
        'goal': goal.index,
      };
}