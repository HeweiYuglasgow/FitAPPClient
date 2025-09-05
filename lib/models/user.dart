import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

/// User model
@JsonSerializable()
class User {
  final int? id;
  final String email;
  final String? name;
  final String? gender; // male, female
  @JsonKey(name: 'fitness_goal')
  final String? fitnessGoal; // muscle_gain, weight_loss, maintain
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  const User({
    this.id,
    required this.email,
    this.name,
    this.gender,
    this.fitnessGoal,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);

  /// 创建用户副本
  User copyWith({
    int? id,
    String? email,
    String? name,
    String? gender,
    String? fitnessGoal,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      gender: gender ?? this.gender,
      fitnessGoal: fitnessGoal ?? this.fitnessGoal,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// 判断用户信息是否完整
  bool get isProfileComplete {
    return name != null && 
           name!.isNotEmpty && 
           gender != null && 
           fitnessGoal != null;
  }

  /// 获取健身目标显示文本
  String get fitnessGoalDisplayText {
    switch (fitnessGoal) {
      case 'muscle_gain':
        return 'Gain muscle';
      case 'weight_loss':
        return 'loss weight';
      case 'maintain':
        return 'maintain weight';
      default:
        return 'unset';
    }
  }

  /// 获取性别显示文本
  String get genderDisplayText {
    switch (gender) {
      case 'male':
        return 'male';
      case 'female':
        return 'female';
      default:
        return 'unset';
    }
  }

  @override
  String toString() {
    return 'User(id: $id, email: $email, name: $name, gender: $gender, fitnessGoal: $fitnessGoal)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
        other.id == id &&
        other.email == email &&
        other.name == name &&
        other.gender == gender &&
        other.fitnessGoal == fitnessGoal;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        email.hashCode ^
        name.hashCode ^
        gender.hashCode ^
        fitnessGoal.hashCode;
  }
}