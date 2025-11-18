class Room {
  final String id;
  final String name;
  final String location;
  final DateTime createdAt;

  Room({
    required this.id,
    required this.name,
    required this.location,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Copy with method for updates
  Room copyWith({
    String? id,
    String? name,
    String? location,
    DateTime? createdAt,
  }) {
    return Room(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Convert to a database-ready map
  Map<String, dynamic> toDbMap() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  // Create from JSON
  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'] as String,
      name: json['name'] as String,
      location: json['location'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// Create a [Room] from a database map
  factory Room.fromDbMap(Map<String, dynamic> map) {
    return Room(
      id: map['id'] as String,
      name: map['name'] as String,
      location: map['location'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    );
  }

  @override
  String toString() {
    return 'Room(id: $id, name: $name, location: $location)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Room && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
