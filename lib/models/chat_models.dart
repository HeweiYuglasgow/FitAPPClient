import 'package:json_annotation/json_annotation.dart';

part 'chat_models.g.dart';

/// Chat message model
@JsonSerializable()
class ChatMessage {
  final String content;
  @JsonKey(name: 'is_user')
  final bool isUser;
  final DateTime timestamp;

  const ChatMessage({
    required this.content,
    required this.isUser,
    required this.timestamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);

  Map<String, dynamic> toJson() => _$ChatMessageToJson(this);
}

/// Chat request model
@JsonSerializable()
class ChatRequest {
  final String question;
  final Map<String, dynamic>? context;

  const ChatRequest({
    required this.question,
    this.context,
  });

  factory ChatRequest.fromJson(Map<String, dynamic> json) =>
      _$ChatRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ChatRequestToJson(this);
}

/// Chat response model
@JsonSerializable()
class ChatResponse {
  final String response;
  final DateTime timestamp;

  const ChatResponse({
    required this.response,
    required this.timestamp,
  });

  factory ChatResponse.fromJson(Map<String, dynamic> json) =>
      _$ChatResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ChatResponseToJson(this);
}