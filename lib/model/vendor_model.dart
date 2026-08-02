class VendorModel {
  final String id;
  final String name;
  final String icon;

  VendorModel({required this.id, required this.name, required this.icon});

  factory VendorModel.fromFirestore(String id, Map<String, dynamic> data) {
    return VendorModel(
      id: data['id'] ?? id,
      name: data['name'] ?? '',
      icon: data['icon'] ?? '🍔',
    );
  }
}
