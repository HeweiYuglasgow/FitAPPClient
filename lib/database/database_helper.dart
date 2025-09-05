import 'dart:async';
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../constants/app_constants.dart';
import '../models/workout_plan.dart';
import '../models/workout_record.dart';
import '../models/chat_message.dart';

/// Database helper class
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  /// Get database instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize database
  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, AppConstants.databaseName);

    return await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Create tables
  Future<void> _onCreate(Database db, int version) async {
    // Create workout plan table
    await db.execute('''
      CREATE TABLE workout_plans (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        server_id INTEGER,
        title TEXT NOT NULL,
        description TEXT,
        total_duration INTEGER NOT NULL,
        location TEXT,
        equipment TEXT,
        mood_context TEXT NOT NULL,
        exercises TEXT NOT NULL,
        motivational_message TEXT,
        generated_at TEXT NOT NULL,
        created_at TEXT NOT NULL,
        is_favorite INTEGER DEFAULT 0
      )
    ''');

    // Create workout record table
    await db.execute('''
      CREATE TABLE workout_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        server_id INTEGER,
        workout_plan_id INTEGER NOT NULL,
        completion_rate REAL NOT NULL,
        actual_duration INTEGER,
        completed_exercises TEXT NOT NULL,
        notes TEXT,
        mood_before TEXT,
        mood_after TEXT,
        started_at TEXT NOT NULL,
        completed_at TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (workout_plan_id) REFERENCES workout_plans (id)
      )
    ''');

    // Create mood record table
    await db.execute('''
      CREATE TABLE mood_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        server_id INTEGER,
        mood_before TEXT NOT NULL,
        mood_after TEXT,
        workout_id INTEGER,
        notes TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    // Create chat message table
    await db.execute('''
      CREATE TABLE chat_messages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        server_id INTEGER,
        question TEXT NOT NULL,
        answer TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // Create app settings table
    await db.execute('''
      CREATE TABLE app_settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
  }

  /// Database upgrade
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // 处理数据库版本升级
    if (oldVersion < newVersion) {
      // 这里可以添加具体的升级逻辑
    }
  }

  // ==================== 训练计划相关 ====================

  /// 保存训练计划
  Future<int> insertWorkoutPlan(WorkoutPlan plan) async {
    final db = await database;
    final planData = {
      'server_id': plan.id,
      'title': plan.title,
      'description': plan.description,
      'total_duration': plan.totalDuration,
      'location': plan.location,
      'equipment': plan.equipment,
      'mood_context': plan.moodContext,
      'exercises': _exercisesToJson(plan.exercises.map((e) => e.toJson()).toList()),
      'motivational_message': plan.motivationalMessage,
      'generated_at': plan.generatedAt?.toIso8601String(),
      'created_at': DateTime.now().toIso8601String(),
    };

    return await db.insert('workout_plans', planData);
  }

  /// 获取所有训练计划
  Future<List<WorkoutPlan>> getWorkoutPlans({int? limit}) async {
    final db = await database;
    final query = 'SELECT * FROM workout_plans ORDER BY created_at DESC${limit != null ? ' LIMIT $limit' : ''}';
    final List<Map<String, dynamic>> maps = await db.rawQuery(query);

    return maps.map((map) => _workoutPlanFromMap(map)).toList();
  }

  /// 获取收藏的训练计划
  Future<List<WorkoutPlan>> getFavoriteWorkoutPlans() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'workout_plans',
      where: 'is_favorite = ?',
      whereArgs: [1],
      orderBy: 'created_at DESC',
    );

    return maps.map((map) => _workoutPlanFromMap(map)).toList();
  }

  /// 切换收藏状态
  Future<void> toggleWorkoutPlanFavorite(int id) async {
    final db = await database;
    final plan = await db.query('workout_plans', where: 'id = ?', whereArgs: [id]);
    if (plan.isNotEmpty) {
      final isFavorite = plan.first['is_favorite'] == 1;
      await db.update(
        'workout_plans',
        {'is_favorite': isFavorite ? 0 : 1},
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  }

  /// 删除训练计划
  Future<void> deleteWorkoutPlan(int id) async {
    final db = await database;
    await db.delete('workout_plans', where: 'id = ?', whereArgs: [id]);
  }

  // ==================== 训练记录相关 ====================

  /// 保存训练记录
  Future<int> insertWorkoutRecord(WorkoutRecord record) async {
    final db = await database;
    final recordData = {
      'server_id': record.id,
      'workout_plan_id': record.workoutPlanId,
      'completion_rate': record.completionRate,
      'actual_duration': record.actualDuration,
      'completed_exercises': record.completedExercises.join(','),
      'notes': record.notes,
      'started_at': record.startedAt?.toIso8601String(),
      'completed_at': record.completedAt?.toIso8601String(),
      'created_at': DateTime.now().toIso8601String(),
    };

    return await db.insert('workout_records', recordData);
  }

  /// 获取训练记录
  Future<List<WorkoutRecord>> getWorkoutRecords({int? limit}) async {
    final db = await database;
    final query = 'SELECT * FROM workout_records ORDER BY created_at DESC${limit != null ? ' LIMIT $limit' : ''}';
    final List<Map<String, dynamic>> maps = await db.rawQuery(query);

    return maps.map((map) => _workoutRecordFromMap(map)).toList();
  }

  /// 获取统计数据
  Future<Map<String, dynamic>> getWorkoutStats() async {
    final db = await database;
    
    // 总训练次数
    final totalWorkouts = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM workout_records'),
    ) ?? 0;

    // 总训练时长
    final totalDuration = Sqflite.firstIntValue(
      await db.rawQuery('SELECT SUM(actual_duration) FROM workout_records WHERE actual_duration IS NOT NULL'),
    ) ?? 0;

    // 平均完成率
    final result = await db.rawQuery('SELECT AVG(completion_rate) FROM workout_records');
    final avgCompletionRate = result.isNotEmpty && result.first.values.first != null
        ? (result.first.values.first as num).toDouble()
        : 0.0;

    // 本周数据
    final oneWeekAgo = DateTime.now().subtract(const Duration(days: 7)).toIso8601String();
    final thisWeekWorkouts = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM workout_records WHERE created_at >= ?', [oneWeekAgo]),
    ) ?? 0;

    final thisWeekDuration = Sqflite.firstIntValue(
      await db.rawQuery('SELECT SUM(actual_duration) FROM workout_records WHERE created_at >= ? AND actual_duration IS NOT NULL', [oneWeekAgo]),
    ) ?? 0;

    return {
      'totalWorkouts': totalWorkouts,
      'totalDuration': totalDuration,
      'avgCompletionRate': avgCompletionRate,
      'thisWeek': {
        'workouts': thisWeekWorkouts,
        'duration': thisWeekDuration,
      },
    };
  }

  // ==================== 聊天消息相关 ====================

  /// 保存聊天消息
  Future<int> insertChatMessage(ChatMessage message) async {
    final db = await database;
    final messageData = {
      'server_id': message.id,
      'question': message.question,
      'answer': message.answer,
      'created_at': message.createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };

    return await db.insert('chat_messages', messageData);
  }

  /// 获取聊天消息历史
  Future<List<ChatMessage>> getChatMessages({int? limit}) async {
    final db = await database;
    final query = 'SELECT * FROM chat_messages ORDER BY created_at DESC${limit != null ? ' LIMIT $limit' : ''}';
    final List<Map<String, dynamic>> maps = await db.rawQuery(query);

    return maps.map((map) => _chatMessageFromMap(map)).toList();
  }

  /// 清除聊天历史
  Future<void> clearChatMessages() async {
    final db = await database;
    await db.delete('chat_messages');
  }

  // ==================== 应用设置相关 ====================

  /// 保存设置
  Future<void> saveSetting(String key, String value) async {
    final db = await database;
    await db.insert(
      'app_settings',
      {
        'key': key,
        'value': value,
        'updated_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 获取设置
  Future<String?> getSetting(String key) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'app_settings',
      where: 'key = ?',
      whereArgs: [key],
    );

    if (maps.isNotEmpty) {
      return maps.first['value'] as String;
    }
    return null;
  }

  /// 删除设置
  Future<void> deleteSetting(String key) async {
    final db = await database;
    await db.delete('app_settings', where: 'key = ?', whereArgs: [key]);
  }

  // ==================== 工具方法 ====================

  /// 将Exercise列表转换为JSON字符串
  String _exercisesToJson(List<Map<String, dynamic>> exercises) {
    return jsonEncode(exercises);
  }

  /// 从Map创建WorkoutPlan对象
  WorkoutPlan _workoutPlanFromMap(Map<String, dynamic> map) {
    // 简化版本，实际项目中需要完整的JSON解析
    return WorkoutPlan(
      id: map['server_id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String?,
      totalDuration: map['total_duration'] as int,
      location: map['location'] as String?,
      equipment: map['equipment'] as String?,
      moodContext: map['mood_context'] as String,
      exercises: [], // 需要JSON解析
      motivationalMessage: map['motivational_message'] as String?,
      generatedAt: map['generated_at'] != null 
          ? DateTime.parse(map['generated_at'] as String) 
          : null,
    );
  }

  /// 从Map创建WorkoutRecord对象
  WorkoutRecord _workoutRecordFromMap(Map<String, dynamic> map) {
    return WorkoutRecord(
      id: map['server_id'] as int?,
      workoutPlanId: map['workout_plan_id'] as int,
      completionRate: map['completion_rate'] as double,
      actualDuration: map['actual_duration'] as int?,
      completedExercises: (map['completed_exercises'] as String)
          .split(',')
          .where((s) => s.isNotEmpty)
          .map((s) => int.parse(s))
          .toList(),
      notes: map['notes'] as String?,
      startedAt: map['started_at'] != null 
          ? DateTime.parse(map['started_at'] as String) 
          : null,
      completedAt: map['completed_at'] != null 
          ? DateTime.parse(map['completed_at'] as String) 
          : null,
    );
  }

  /// 从Map创建ChatMessage对象
  ChatMessage _chatMessageFromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['server_id'] as int?,
      question: map['question'] as String,
      answer: map['answer'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  /// 关闭数据库连接
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }

  /// 清除所有数据（用于测试）
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('workout_plans');
    await db.delete('workout_records');
    await db.delete('mood_records');
    await db.delete('chat_messages');
    await db.delete('app_settings');
  }
}