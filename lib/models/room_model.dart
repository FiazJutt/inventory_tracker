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

// class Room {
//   final String id;
//   final String name;
//   final String location;
//   final String type;
//   final int itemCount;
//   final DateTime createdAt;
//   final String? imageUrl;

//   Room({
//     required this.id,
//     required this.name,
//     required this.location,
//     required this.type,
//     this.itemCount = 0,
//     DateTime? createdAt,
//     this.imageUrl,
//   }) : createdAt = createdAt ?? DateTime.now();

//   // Helper method to get icon based on room type
//   String get icon {
//     switch (type.toLowerCase()) {
//       case 'living room':
//         return '🛋️';
//       case 'bedroom':
//         return '🛏️';
//       case 'bathroom':
//         return '🚿';
//       case 'kitchen':
//         return '🍳';
//       case 'office':
//         return '💼';
//       case 'garage':
//         return '🚗';
//       default:
//         return '🏠';
//     }
//   }

//   // Convert to map for storage
//   Map<String, dynamic> toMap() {
//     return {
//       'id': id,
//       'name': name,
//       'location': location,
//       'type': type,
//       'itemCount': itemCount,
//       'createdAt': createdAt.toIso8601String(),
//       'imageUrl': imageUrl,
//     };
//   }

//   // Create Room from map
//   factory Room.fromMap(Map<String, dynamic> map) {
//     return Room(
//       id: map['id'],
//       name: map['name'],
//       location: map['location'],
//       type: map['type'],
//       itemCount: map['itemCount'] ?? 0,
//       createdAt: DateTime.parse(map['createdAt']),
//       imageUrl: map['imageUrl'],
//     );
//   }
// }
