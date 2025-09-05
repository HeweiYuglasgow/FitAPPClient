import '../models/chat_models.dart';
import '../models/api_response.dart';
import 'http_service.dart';

/// Chat service class
class ChatService {
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  final HttpService _httpService = HttpService();

  /// Send chat message to AI
  Future<ApiResponse<ChatResponse>> sendMessage({
    required String question,
    Map<String, dynamic>? context,
  }) async {
    final request = ChatRequest(
      question: question,
      context: context,
    );

    final response = await _httpService.post(
      '/ai/chat',
      data: request.toJson(),
      fromJson: (data) {
        // Handle different possible response formats
        if (data is String) {
          // If response is a simple string
          return ChatResponse(
            response: data,
            timestamp: DateTime.now(),
          );
        } else if (data is Map<String, dynamic>) {
          // If response has a specific structure
          if (data.containsKey('response')) {
            return ChatResponse.fromJson(data);
          } else if (data.containsKey('answer')) {
            return ChatResponse(
              response: data['answer'].toString(),
              timestamp: DateTime.now(),
            );
          } else {
            // Fallback: convert entire response to string
            return ChatResponse(
              response: data.toString(),
              timestamp: DateTime.now(),
            );
          }
        } else {
          throw Exception('Unexpected response format');
        }
      },
    );

    return response;
  }

  /// Get chat suggestions/quick questions (fallback to default)
  Future<ApiResponse<List<String>>> getChatSuggestions() async {
    // Since there's no specific suggestions API, return default questions
    await Future.delayed(const Duration(milliseconds: 100)); // Simulate API call
    
    final defaultQuestions = [
      'How to do squats correctly?',
      'What to eat during fat loss?',
      'What exercises should beginners start with?',
      'Is muscle soreness after exercise normal?',
      'How to create a training plan?',
      'Difference between aerobic and anaerobic exercise?',
    ];

    return ApiResponse(
      success: true,
      data: defaultQuestions,
      message: 'Default suggestions loaded',
    );
  }

  /// Clear chat history (local only)
  Future<ApiResponse<bool>> clearChatHistory() async {
    // Since there's no specific clear API, just return success
    await Future.delayed(const Duration(milliseconds: 50));
    
    return ApiResponse(
      success: true,
      data: true,
      message: 'Chat history cleared locally',
    );
  }
}