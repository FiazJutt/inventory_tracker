// lib/models/item_model.dart
// Same structure as Container, or you can use the same model
class Item {
  final String id;
  final String name;
  final String roomId;
  final String? containerId;
  final int quantity;
  final String? serialNumber;
  final String? notes;
  final String? description;
  final double? purchasePrice;
  final DateTime? purchaseDate;
  final double? currentValue;
  final String? currentCondition;
  final DateTime? expirationDate;
  final double? weight;
  final String? retailer;
  final String? brand;
  final String? model;
  final String? searchMetadata;
  final DateTime createdAt;

  Item({
    required this.id,
    required this.name,
    required this.roomId,
    this.containerId,
    this.quantity = 1,
    this.serialNumber,
    this.notes,
    this.description,
    this.purchasePrice,
    this.purchaseDate,
    this.currentValue,
    this.currentCondition,
    this.expirationDate,
    this.weight,
    this.retailer,
    this.brand,
    this.model,
    this.searchMetadata,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Item copyWith({
    String? id,
    String? name,
    String? roomId,
    String? containerId,
    int? quantity,
    String? serialNumber,
    String? notes,
    String? description,
    double? purchasePrice,
    DateTime? purchaseDate,
    double? currentValue,
    String? currentCondition,
    DateTime? expirationDate,
    double? weight,
    String? retailer,
    String? brand,
    String? model,
    String? searchMetadata,
    DateTime? createdAt,
  }) {
    return Item(
      id: id ?? this.id,
      name: name ?? this.name,
      roomId: roomId ?? this.roomId,
      containerId: containerId ?? this.containerId,
      quantity: quantity ?? this.quantity,
      serialNumber: serialNumber ?? this.serialNumber,
      notes: notes ?? this.notes,
      description: description ?? this.description,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      currentValue: currentValue ?? this.currentValue,
      currentCondition: currentCondition ?? this.currentCondition,
      expirationDate: expirationDate ?? this.expirationDate,
      weight: weight ?? this.weight,
      retailer: retailer ?? this.retailer,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      searchMetadata: searchMetadata ?? this.searchMetadata,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'roomId': roomId,
    'containerId': containerId,
    'quantity': quantity,
    'serialNumber': serialNumber,
    'notes': notes,
    'description': description,
    'purchasePrice': purchasePrice,
    'purchaseDate': purchaseDate?.toIso8601String(),
    'currentValue': currentValue,
    'currentCondition': currentCondition,
    'expirationDate': expirationDate?.toIso8601String(),
    'weight': weight,
    'retailer': retailer,
    'brand': brand,
    'model': model,
    'searchMetadata': searchMetadata,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Item.fromJson(Map<String, dynamic> json) => Item(
    id: json['id'],
    name: json['name'],
    roomId: json['roomId'],
    containerId: json['containerId'],
    quantity: json['quantity'] ?? 1,
    serialNumber: json['serialNumber'],
    notes: json['notes'],
    description: json['description'],
    purchasePrice: json['purchasePrice']?.toDouble(),
    purchaseDate: json['purchaseDate'] != null
        ? DateTime.parse(json['purchaseDate'])
        : null,
    currentValue: json['currentValue']?.toDouble(),
    currentCondition: json['currentCondition'],
    expirationDate: json['expirationDate'] != null
        ? DateTime.parse(json['expirationDate'])
        : null,
    weight: json['weight']?.toDouble(),
    retailer: json['retailer'],
    brand: json['brand'],
    model: json['model'],
    searchMetadata: json['searchMetadata'],
    createdAt: json['createdAt'] != null
        ? DateTime.parse(json['createdAt'])
        : DateTime.now(),
  );

  Map<String, dynamic> toDbMap() {
    return {
      'id': id,
      'name': name,
      'room_id': roomId,
      'container_id': containerId,
      'quantity': quantity,
      'serial_number': serialNumber,
      'notes': notes,
      'description': description,
      'purchase_price': purchasePrice,
      'purchase_date': purchaseDate?.millisecondsSinceEpoch,
      'current_value': currentValue,
      'current_condition': currentCondition,
      'expiration_date': expirationDate?.millisecondsSinceEpoch,
      'weight': weight,
      'retailer': retailer,
      'brand': brand,
      'model': model,
      'search_metadata': searchMetadata,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  factory Item.fromDbMap(Map<String, dynamic> map) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is int) {
        return DateTime.fromMillisecondsSinceEpoch(value);
      }
      if (value is String) {
        return DateTime.tryParse(value);
      }
      return null;
    }

    double? asDouble(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString());
    }

    return Item(
      id: map['id'] as String,
      name: map['name'] as String,
      roomId: map['room_id'] as String,
      containerId: map['container_id'] as String?,
      quantity: (map['quantity'] as int?) ?? 1,
      serialNumber: map['serial_number'] as String?,
      notes: map['notes'] as String?,
      description: map['description'] as String?,
      purchasePrice: asDouble(map['purchase_price']),
      purchaseDate: parseDate(map['purchase_date']),
      currentValue: asDouble(map['current_value']),
      currentCondition: map['current_condition'] as String?,
      expirationDate: parseDate(map['expiration_date']),
      weight: asDouble(map['weight']),
      retailer: map['retailer'] as String?,
      brand: map['brand'] as String?,
      model: map['model'] as String?,
      searchMetadata: map['search_metadata'] as String?,
      createdAt: parseDate(map['created_at']) ?? DateTime.now(),
    );
  }
}
