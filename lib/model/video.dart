class Video {
  final int? id;
  final String path;

  Video({this.id, required this.path});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'path': path,
    };
  }

  factory Video.fromMap(Map<String, dynamic> map) {
    return Video(
      id: map['id'],
      path: map['path'],
    );
  }

  Video copyWith({int? id, String? path}) {
    return Video(
      id: id ?? this.id,
      path: path ?? this.path,
    );
  }
}
