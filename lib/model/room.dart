class Room {
  final String roomId;
  final String roomName;

  Room({
    required this.roomId,
    required this.roomName,
  });

  Map<String, dynamic> toMap() {
    return {
      'roomId': roomId,
      'roomName': roomName,
    };
  }

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      roomId: json['roomId'],
      roomName: json['roomName'],
    );
  }
}
