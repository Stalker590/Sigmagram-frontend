class ChatSummary {
  const ChatSummary({
    required this.id,
    required this.name,
    required this.type,
  });

  final String id;
  final String name;
  final String type;

  factory ChatSummary.fromJson(Map<String, dynamic> json) {
    return ChatSummary(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String? ?? 'global',
    );
  }
}
