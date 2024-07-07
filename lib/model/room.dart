class Room {
  Room({
    required this.roomId,
    required this.roomName,
  });

  final String roomName;
  final int roomId;

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      roomId: json['roomId'] as int,
      roomName: json['roomName'] as String,
    );
  }
}
