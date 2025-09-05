// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatMessage _$ChatMessageFromJson(Map<String, dynamic> json) => ChatMessage(
  content: json['content'] as String,
  isUser: json['is_user'] as bool,
  timestamp: DateTime.parse(json['timestamp'] as String),
);

Map<String, dynamic> _$ChatMessageToJson(ChatMessage instance) =>
    <String, dynamic>{
      'content': instance.content,
      'is_user': instance.isUser,
      'timestamp': instance.timestamp.toIso8601String(),
    };

ChatRequest _$ChatRequestFromJson(Map<String, dynamic> json) => ChatRequest(
  question: json['question'] as String,
  context: json['context'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$ChatRequestToJson(ChatRequest instance) =>
    <String, dynamic>{
      'question': instance.question,
      'context': instance.context,
    };

ChatResponse _$ChatResponseFromJson(Map<String, dynamic> json) => ChatResponse(
  response: json['response'] as String,
  timestamp: DateTime.parse(json['timestamp'] as String),
);

Map<String, dynamic> _$ChatResponseToJson(ChatResponse instance) =>
    <String, dynamic>{
      'response': instance.response,
      'timestamp': instance.timestamp.toIso8601String(),
    };
