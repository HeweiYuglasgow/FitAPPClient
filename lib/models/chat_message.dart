import 'package:json_annotation/json_annotation.dart';

part 'chat_message.g.dart';

/// 聊天消息模型
@JsonSerializable()
class ChatMessage {
  final int? id;
  @JsonKey(name: 'user_id')
  final int? userId;
  final String question;
  final String answer;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  const ChatMessage({
    this.id,
    this.userId,
    required this.question,
    required this.answer,
    this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) => _$ChatMessageFromJson(json);

  Map<String, dynamic> toJson() => _$ChatMessageToJson(this);

  /// 创建聊天消息副本
  ChatMessage copyWith({
    int? id,
    int? userId,
    String? question,
    String? answer,
    DateTime? createdAt,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Format the creation time in English
  String get formattedTime {
    if (createdAt == null) return '';
    
    final now = DateTime.now();
    final difference = now.difference(createdAt!);
    
    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${createdAt!.year}-${createdAt!.month.toString().padLeft(2, '0')}-${createdAt!.day.toString().padLeft(2, '0')}';
    }
  }

  @override
  String toString() {
    return 'ChatMessage(id: $id, question: ${question.length > 20 ? '${question.substring(0, 20)}...' : question})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatMessage &&
        other.id == id &&
        other.question == question &&
        other.answer == answer;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        question.hashCode ^
        answer.hashCode;
  }
}