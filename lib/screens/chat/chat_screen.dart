import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../models/chat_models.dart';
import '../../services/chat_service.dart';

/// AI assistant chat screen
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  final ChatService _chatService = ChatService();
  bool _isLoading = false;
  String? _errorMessage;

  // Quick questions
  List<String> _quickQuestions = [
    'How to do squats correctly?',
    'What to eat during fat loss?',
    'What exercises should beginners start with?',
    'Is muscle soreness after exercise normal?',
    'How to create a training plan?',
    'Difference between aerobic and anaerobic exercise?',
  ];

  @override
  void initState() {
    super.initState();
    _loadChatSuggestions();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Load chat suggestions from API
  Future<void> _loadChatSuggestions() async {
    try {
      final response = await _chatService.getChatSuggestions();
      if (response.success && response.data != null && mounted) {
        setState(() {
          _quickQuestions = response.data!;
        });
      }
    } catch (e) {
      // Use default questions on failure
    }
  }

  /// Send message
  Future<void> _sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    // Add user message
    final userMessage = ChatMessage(
      content: message.trim(),
      isUser: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMessage);
      _isLoading = true;
      _errorMessage = null;
    });

    _messageController.clear();
    _scrollToBottom();

    try {
      // Prepare context from recent messages
      final context = <String, dynamic>{};
      
      // Add recent conversation history as context
      final recentMessages = _messages.take(10).toList(); // Last 10 messages
      if (recentMessages.isNotEmpty) {
        context['recent_messages'] = recentMessages.map((msg) => {
          'content': msg.content,
          'is_user': msg.isUser,
          'timestamp': msg.timestamp.toIso8601String(),
        }).toList();
      }
      
      // Add user context (can be extended with more user info)
      context['user_info'] = {
        'session_id': DateTime.now().millisecondsSinceEpoch.toString(),
      };

      // Send message to API
      final response = await _chatService.sendMessage(
        question: message.trim(),
        context: context,
      );

      if (mounted) {
        if (response.success && response.data != null) {
          setState(() {
            _messages.add(ChatMessage(
              content: response.data!.response,
              isUser: false,
              timestamp: response.data!.timestamp,
            ));
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = response.message ?? 'Failed to get AI response';
            _messages.add(ChatMessage(
              content: 'Sorry, I encountered an error. Please try again.',
              isUser: false,
              timestamp: DateTime.now(),
            ));
            _isLoading = false;
          });
        }
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Network error occurred';
          _messages.add(ChatMessage(
            content: 'Sorry, I\'m having trouble connecting. Please check your internet connection and try again.',
            isUser: false,
            timestamp: DateTime.now(),
          ));
          _isLoading = false;
        });
        _scrollToBottom();
      }
    }
  }

  /// Scroll to bottom
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// Select quick question
  void _selectQuickQuestion(String question) {
    _sendMessage(question);
  }

  /// Clear chat
  Future<void> _clearChat() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Chat'),
        content: const Text('Are you sure you want to clear all chat messages?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              
              setState(() {
                _messages.clear();
                _errorMessage = null;
              });

              // Optionally call API to clear server-side history
              try {
                await _chatService.clearChatHistory();
              } catch (e) {
                // Ignore API errors for clearing history
              }
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('AI Fitness Coach'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _clearChat,
            tooltip: 'Clear chat',
          ),
        ],
      ),
      body: Column(
        children: [
          // Show error message if any
          if (_errorMessage != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: AppColors.error.withOpacity(0.1),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: AppColors.error,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 16),
                    onPressed: () => setState(() => _errorMessage = null),
                    color: AppColors.error,
                  ),
                ],
              ),
            ),
          Expanded(
            child: _messages.isEmpty
                ? _buildEmptyView()
                : _buildMessageList(),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  /// Build empty view
  Widget _buildEmptyView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(
              Icons.smart_toy,
              size: 40,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Hello! I am your AI Fitness Coach',
            style: AppTextStyles.h4.copyWith(
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Feel free to ask me any fitness questions',
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: 32),
          const Text(
            'Common Questions',
            style: AppTextStyles.labelLarge,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _quickQuestions.map((question) {
              return GestureDetector(
                onTap: () => _selectQuickQuestion(question),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primary),
                  ),
                  child: Text(
                    question,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// Build message list
  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (_isLoading && index == _messages.length) {
          return _buildLoadingMessage();
        }

        final message = _messages[index];
        return _buildMessageBubble(message);
      },
    );
  }

  /// Build message bubble
  Widget _buildMessageBubble(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: message.isUser 
            ? MainAxisAlignment.end 
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary,
              child: Icon(
                Icons.smart_toy,
                size: 16,
                color: AppColors.white,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: message.isUser 
                    ? AppColors.primary 
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: !message.isUser 
                    ? Border.all(color: AppColors.divider)
                    : null,
              ),
              child: Text(
                message.content,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: message.isUser 
                      ? AppColors.white 
                      : AppColors.textPrimary,
                ),
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.grey300,
              child: Icon(
                Icons.person,
                size: 16,
                color: AppColors.grey600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Build loading message
  Widget _buildLoadingMessage() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primary,
            child: Icon(
              Icons.smart_toy,
              size: 16,
              color: AppColors.white,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'AI is thinking...',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build input area
  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: _sendMessage,
              decoration: const InputDecoration(
                hintText: 'Ask fitness related questions...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(24),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.send,
                color: AppColors.white,
              ),
              onPressed: () => _sendMessage(_messageController.text),
            ),
          ),
        ],
      ),
    );
  }
}