class CustomerAddressModel {
  final int? id;
  final String customerId;
  final String title;
  final String addressLine;
  final double latitude;
  final double longitude;
  final bool isDefault;
  final DateTime? createdAt;

  const CustomerAddressModel({
    this.id,
    required this.customerId,
    required this.title,
    required this.addressLine,
    this.latitude = 18.4800,
    this.longitude = 73.8000,
    this.isDefault = false,
    this.createdAt,
  });

  factory CustomerAddressModel.fromJson(Map<String, dynamic> json) {
    return CustomerAddressModel(
      id: json['id'] as int?,
      customerId: (json['customer_id'] ?? '').toString(),
      title: (json['title'] ?? 'Address').toString(),
      addressLine: (json['address_line'] ?? '').toString(),
      latitude: (json['latitude'] as num?)?.toDouble() ?? 18.4800,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 73.8000,
      isDefault: json['is_default'] == true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'customer_id': customerId,
      'title': title,
      'address_line': addressLine,
      'latitude': latitude,
      'longitude': longitude,
      'is_default': isDefault,
    };
  }

  CustomerAddressModel copyWith({
    int? id,
    String? customerId,
    String? title,
    String? addressLine,
    double? latitude,
    double? longitude,
    bool? isDefault,
    DateTime? createdAt,
  }) {
    return CustomerAddressModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      title: title ?? this.title,
      addressLine: addressLine ?? this.addressLine,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
