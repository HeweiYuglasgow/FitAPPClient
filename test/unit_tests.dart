import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/models/user.dart';
import 'package:flutter_application_1/models/workout_plan.dart';
import 'package:flutter_application_1/models/exercise.dart';
import 'package:flutter_application_1/models/mood_record.dart';
import 'package:flutter_application_1/utils/validators.dart';
import 'package:flutter_application_1/utils/date_formatter.dart';

/// 单元测试
void main() {
  group('模型测试', () {
    test('用户模型测试', () {
      final user = User(
        id: 1,
        email: 'test@example.com',
        name: '测试用户',
        gender: 'male',
        fitnessGoal: 'muscle_gain',
      );

      expect(user.id, 1);
      expect(user.email, 'test@example.com');
      expect(user.isProfileComplete, true);
      expect(user.fitnessGoalDisplayText, '增肌');
      expect(user.genderDisplayText, '男');
    });

    test('运动动作模型测试', () {
      final exercise = Exercise(
        id: 1,
        name: '俯卧撑',
        sets: 3,
        reps: 15,
        restTime: 60,
        order: 1,
      );

      expect(exercise.name, '俯卧撑');
      expect(exercise.requirementText, '3组 x 15次');
      expect(exercise.restTimeText, '1分钟');
      expect(exercise.isRepBased, true);
      expect(exercise.isTimeBased, false);
    });

    test('情绪记录模型测试', () {
      final moodRecord = MoodRecord(
        id: 1,
        moodBefore: 'bad',
        moodAfter: 'good',
      );

      expect(moodRecord.moodBeforeDisplayText, '有点低落');
      expect(moodRecord.moodAfterDisplayText, '心情不错');
      expect(moodRecord.moodBeforeEmoji, '😔');
      expect(moodRecord.moodAfterEmoji, '😊');
      expect(moodRecord.isMoodImproved, true);
      expect(moodRecord.moodImprovementLevel, 2);
    });
  });

  group('验证器测试', () {
    test('邮箱验证测试', () {
      expect(Validators.validateEmail('test@example.com'), null);
      expect(Validators.validateEmail('invalid-email'), '邮箱格式不正确');
      expect(Validators.validateEmail(''), '请输入邮箱地址');
      expect(Validators.validateEmail(null), '请输入邮箱地址');
    });

    test('密码验证测试', () {
      expect(Validators.validatePassword('123456'), null);
      expect(Validators.validatePassword('12345'), '密码至少6位字符');
      expect(Validators.validatePassword(''), '请输入密码');
      expect(Validators.validatePassword(null), '请输入密码');
    });

    test('验证码验证测试', () {
      expect(Validators.validateVerificationCode('123456'), null);
      expect(Validators.validateVerificationCode('12345'), '验证码应为6位数字');
      expect(Validators.validateVerificationCode('abcdef'), '验证码格式不正确');
      expect(Validators.validateVerificationCode(''), '请输入验证码');
    });

    test('姓名验证测试', () {
      expect(Validators.validateName('张三'), null);
      expect(Validators.validateName('A'), '姓名至少2个字符');
      expect(Validators.validateName(''), '请输入姓名');
      expect(Validators.validateName('非常长的姓名超过二十个字符的测试'), '姓名不能超过20个字符');
    });

    test('确认密码验证测试', () {
      expect(Validators.validateConfirmPassword('123456', '123456'), null);
      expect(Validators.validateConfirmPassword('123456', '654321'), '两次输入的密码不一致');
      expect(Validators.validateConfirmPassword('', '123456'), '请再次输入密码');
    });
  });

  group('日期格式化测试', () {
    test('日期格式化测试', () {
      final date = DateTime(2024, 1, 15, 14, 30, 0);

      expect(DateFormatter.formatDate(date), '2024-01-15');
      expect(DateFormatter.formatTime(date), '14:30:00');
      expect(DateFormatter.formatChineseDate(date), '2024年01月15日');
      expect(DateFormatter.formatChineseTime(date), '14:30');
    });

    test('相对时间测试', () {
      final now = DateTime.now();
      final oneMinuteAgo = now.subtract(const Duration(minutes: 1));
      final oneHourAgo = now.subtract(const Duration(hours: 1));
      final oneDayAgo = now.subtract(const Duration(days: 1));

      expect(DateFormatter.getRelativeTime(now), '刚刚');
      expect(DateFormatter.getRelativeTime(oneMinuteAgo), '1分钟前');
      expect(DateFormatter.getRelativeTime(oneHourAgo), '1小时前');
      expect(DateFormatter.getRelativeTime(oneDayAgo), '1天前');
    });

    test('日期判断测试', () {
      final today = DateTime.now();
      final yesterday = today.subtract(const Duration(days: 1));
      final tomorrow = today.add(const Duration(days: 1));

      expect(DateFormatter.isToday(today), true);
      expect(DateFormatter.isToday(yesterday), false);
      expect(DateFormatter.isYesterday(yesterday), true);
      expect(DateFormatter.isYesterday(tomorrow), false);
    });

    test('时长格式化测试', () {
      expect(DateFormatter.formatDuration(30), '30秒');
      expect(DateFormatter.formatDuration(90), '1分30秒');
      expect(DateFormatter.formatDuration(3661), '1小时1分钟');
      expect(DateFormatter.formatDurationMinutes(45), '45分钟');
      expect(DateFormatter.formatDurationMinutes(90), '1小时30分钟');
    });
  });

  group('业务逻辑测试', () {
    test('训练计划创建测试', () {
      final exercises = [
        Exercise(
          id: 1,
          name: '俯卧撑',
          sets: 3,
          reps: 15,
          restTime: 60,
          order: 1,
        ),
        Exercise(
          id: 2,
          name: '深蹲',
          sets: 3,
          reps: 20,
          restTime: 90,
          order: 2,
        ),
      ];

      final plan = WorkoutPlan(
        id: 1,
        title: '居家健身计划',
        totalDuration: 30,
        moodContext: 'good',
        exercises: exercises,
      );

      expect(plan.exerciseCount, 2);
      expect(plan.moodDisplayText, '心情不错');
      expect(plan.exercises.length, 2);
      expect(plan.exercises.first.name, '俯卧撑');
    });

    test('情绪状态转换测试', () {
      // 测试情绪改善的逻辑
      final goodMood = MoodRecord(
        moodBefore: 'bad',
        moodAfter: 'good',
      );

      final noChange = MoodRecord(
        moodBefore: 'normal',
        moodAfter: 'normal',
      );

      final worse = MoodRecord(
        moodBefore: 'good',
        moodAfter: 'bad',
      );

      expect(goodMood.isMoodImproved, true);
      expect(goodMood.moodImprovementLevel, 2);
      expect(noChange.isMoodImproved, false);
      expect(noChange.moodImprovementLevel, 0);
      expect(worse.isMoodImproved, false);
      expect(worse.moodImprovementLevel, -2);
    });
  });

  group('边界情况测试', () {
    test('空值处理测试', () {
      // 测试各种空值情况
      final user = User(email: 'test@example.com');
      expect(user.isProfileComplete, false);
      expect(user.fitnessGoalDisplayText, '未设置');
      expect(user.genderDisplayText, '未设置');
    });

    test('极端数值测试', () {
      final exercise = Exercise(
        name: '测试动作',
        sets: 0,
        restTime: 0,
        order: 1,
      );

      expect(exercise.requirementText, '0组');
      expect(exercise.restTimeText, '0秒');
    });
  });
}