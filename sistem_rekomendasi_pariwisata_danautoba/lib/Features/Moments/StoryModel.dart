class Post {
  String username;
  String caption;
  List<String> imageUrls;
  DateTime timestamp;
  String profilePicUrl;
  List<String> likes;

  Post(
      {required this.username,
      required this.caption,
      required this.imageUrls,
      required this.timestamp,
      required this.profilePicUrl,
      required this.likes});

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'caption': caption,
      'imageUrls': imageUrls,
      'timestamp': timestamp.toIso8601String(),
      'profilePicUrl': profilePicUrl,
      'likes': likes
    };
  }

  static Post fromMap(Map<String, dynamic> map) {
    return Post(
        username: map['username'],
        caption: map['caption'],
        imageUrls: List<String>.from(map['imageUrls']),
        timestamp: DateTime.parse(map['timestamp']),
        profilePicUrl: map['profilePicUrl'],
        likes: map['likes'] ?? []);
  }
}
