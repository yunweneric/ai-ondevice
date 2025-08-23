import 'package:equatable/equatable.dart';
import 'dart:io';

/// Base class for chat events
abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

/// Initialize chat with a model
class InitializeChat extends ChatEvent {
  final String modelId;

  const InitializeChat(this.modelId);

  @override
  List<Object?> get props => [modelId];
}

/// Start a new chat session
class StartChatSession extends ChatEvent {
  const StartChatSession();
}

/// Send a text message
class SendMessage extends ChatEvent {
  final String message;
  final String? sessionId;
  final List<Map<String, dynamic>>? conversationHistory;

  const SendMessage(
    this.message, {
    this.sessionId,
    this.conversationHistory,
  });

  @override
  List<Object?> get props => [message, sessionId, conversationHistory];
}

/// Send a message with image
class SendMessageWithImage extends ChatEvent {
  final String message;
  final File imageFile;
  final String? sessionId;
  final List<Map<String, dynamic>>? conversationHistory;

  const SendMessageWithImage(
    this.message,
    this.imageFile, {
    this.sessionId,
    this.conversationHistory,
  });

  @override
  List<Object?> get props => [message, imageFile, sessionId, conversationHistory];
}

/// Update streaming response
class UpdateStreamingResponse extends ChatEvent {
  final String response;
  final bool isComplete;
  final bool hasImage;

  const UpdateStreamingResponse(
    this.response, {
    this.isComplete = false,
    this.hasImage = false,
  });

  @override
  List<Object?> get props => [response, isComplete, hasImage];
}

/// Handle chat error
class ChatError extends ChatEvent {
  final String error;
  final String? sessionId;

  const ChatError(this.error, {this.sessionId});

  @override
  List<Object?> get props => [error, sessionId];
}

/// Clear chat history
class ClearChat extends ChatEvent {
  const ClearChat();
}

/// Close chat session
class CloseChat extends ChatEvent {
  const CloseChat();
}

/// Reset chat state
class ResetChat extends ChatEvent {
  const ResetChat();
}
