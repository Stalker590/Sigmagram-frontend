class Messenge {
  final String id;
  final String senderId;
  final DateTime timeOfCreating;
  final String text;
  final String chatId;

  Messenge({
    required this.id,
    required this.senderId,
    required this.timeOfCreating,
    required this.text,
    required this.chatId,
  });

  factory Messenge.fromJson(Map<String, dynamic> json) {
    final time = json['time_of_creating'];
    return Messenge(
      id: json['id'] as String,
      senderId: json['sender_id'] as String,
      text: json['text'] as String,
      timeOfCreating: time is DateTime
          ? time
          : DateTime.parse(time.toString()),
      chatId: json['chat_id'] as String,
    );
  }
}
