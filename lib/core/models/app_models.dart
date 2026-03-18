// Lightweight model classes used across services and screens.

class UserProfile {
  final String id;
  final String username;
  const UserProfile({required this.id, required this.username});
  factory UserProfile.fromJson(Map<String, dynamic> j) =>
      UserProfile(id: j['id'] as String, username: j['username'] as String);
}

class Contact {
  final String id;
  final String contactId;
  final String username;
  final String? nickname;
  const Contact({
    required this.id,
    required this.contactId,
    required this.username,
    this.nickname,
  });
  String get displayName => nickname ?? username;
  factory Contact.fromJson(Map<String, dynamic> j) => Contact(
        id: j['id'] as String,
        contactId: j['contact_id'] as String,
        username: (j['profile'] as Map<String, dynamic>)['username'] as String,
        nickname: j['nickname'] as String?,
      );
}

class ContactRequest {
  final String id;
  final String fromId;
  final String fromUsername;
  final DateTime createdAt;
  const ContactRequest({
    required this.id,
    required this.fromId,
    required this.fromUsername,
    required this.createdAt,
  });
  factory ContactRequest.fromJson(Map<String, dynamic> j) => ContactRequest(
        id: j['id'] as String,
        fromId: j['from_id'] as String,
        fromUsername:
            (j['sender'] as Map<String, dynamic>)['username'] as String,
        createdAt: DateTime.parse(j['created_at'] as String),
      );
}

class Conversation {
  final String id;
  final String otherUserId;
  final String otherUsername;
  final String? nickname;
  final String? activeTurnId;
  final DateTime? lastMessageAt;
  final DateTime createdAt;
  const Conversation({
    required this.id,
    required this.otherUserId,
    required this.otherUsername,
    this.nickname,
    this.activeTurnId,
    this.lastMessageAt,
    required this.createdAt,
  });
  String get displayName => nickname ?? otherUsername;
}

class Message {
  final String id;
  final String conversationId;
  final String senderId;
  final String? content;
  final String type;
  final DateTime createdAt;
  final DateTime? openedAt;
  const Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    this.content,
    required this.type,
    required this.createdAt,
    this.openedAt,
  });
  factory Message.fromJson(Map<String, dynamic> j) => Message(
        id: j['id'] as String,
        conversationId: j['conversation_id'] as String,
        senderId: j['sender_id'] as String,
        content: j['content'] as String?,
        type: j['type'] as String? ?? 'text',
        createdAt: DateTime.parse(j['created_at'] as String),
        openedAt: j['opened_at'] != null
            ? DateTime.parse(j['opened_at'] as String)
            : null,
      );
}
