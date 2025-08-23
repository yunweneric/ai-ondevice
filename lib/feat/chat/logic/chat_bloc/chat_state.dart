import 'package:equatable/equatable.dart';

/// Base class for chat states
abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

/// Initial chat state
class ChatInitial extends ChatState {
  const ChatInitial();
}

/// Chat loading state
class ChatLoading extends ChatState {
  const ChatLoading();
}

/// Chat initialized state
class ChatInitialized extends ChatState {
  final String modelId;
  final String sessionId;
  final List<ChatMessageModel> messages;
  final bool isStreaming;

  const ChatInitialized({
    required this.modelId,
    required this.sessionId,
    this.messages = const [],
    this.isStreaming = false,
  });

  @override
  List<Object?> get props => [modelId, sessionId, messages, isStreaming];

  /// Copy with method for immutable updates
  ChatInitialized copyWith({
    String? modelId,
    String? sessionId,
    List<ChatMessageModel>? messages,
    bool? isStreaming,
  }) {
    return ChatInitialized(
      modelId: modelId ?? this.modelId,
      sessionId: sessionId ?? this.sessionId,
      messages: messages ?? this.messages,
      isStreaming: isStreaming ?? this.isStreaming,
    );
  }
}

/// Chat streaming state
class ChatStreaming extends ChatState {
  final String modelId;
  final String sessionId;
  final List<ChatMessageModel> messages;
  final String currentResponse;
  final bool isComplete;

  const ChatStreaming({
    required this.modelId,
    required this.sessionId,
    required this.messages,
    required this.currentResponse,
    this.isComplete = false,
  });

  @override
  List<Object?> get props => [modelId, sessionId, messages, currentResponse, isComplete];

  /// Copy with method for immutable updates
  ChatStreaming copyWith({
    String? modelId,
    String? sessionId,
    List<ChatMessageModel>? messages,
    String? currentResponse,
    bool? isComplete,
  }) {
    return ChatStreaming(
      modelId: modelId ?? this.modelId,
      sessionId: sessionId ?? this.sessionId,
      messages: messages ?? this.messages,
      currentResponse: currentResponse ?? this.currentResponse,
      isComplete: isComplete ?? this.isComplete,
    );
  }
}

/// Chat error state
class ChatErrorState extends ChatState {
  final String error;
  final String? sessionId;
  final List<ChatMessageModel>? messages;

  const ChatErrorState(
    this.error, {
    this.sessionId,
    this.messages,
  });

  @override
  List<Object?> get props => [error, sessionId, messages];
}

/// Chat message model
class ChatMessageModel {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final String? imagePath;
  final bool isStreaming;
  final bool isComplete;

  const ChatMessageModel({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.imagePath,
    this.isStreaming = false,
    this.isComplete = true,
  });

  /// Create a user message
  factory ChatMessageModel.user({
    required String content,
    String? imagePath,
  }) {
    return ChatMessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      isUser: true,
      timestamp: DateTime.now(),
      imagePath: imagePath,
    );
  }

  /// Create an AI message
  factory ChatMessageModel.ai({
    required String content,
    bool isStreaming = false,
    bool isComplete = true,
  }) {
    return ChatMessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      isUser: false,
      timestamp: DateTime.now(),
      isStreaming: isStreaming,
      isComplete: isComplete,
    );
  }

  /// Copy with method for immutable updates
  ChatMessageModel copyWith({
    String? id,
    String? content,
    bool? isUser,
    DateTime? timestamp,
    String? imagePath,
    bool? isStreaming,
    bool? isComplete,
  }) {
    return ChatMessageModel(
      id: id ?? this.id,
      content: content ?? this.content,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      imagePath: imagePath ?? this.imagePath,
      isStreaming: isStreaming ?? this.isStreaming,
      isComplete: isComplete ?? this.isComplete,
    );
  }

  @override
  List<Object?> get props => [
        id,
        content,
        isUser,
        timestamp,
        imagePath,
        isStreaming,
        isComplete,
      ];

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatMessageModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
