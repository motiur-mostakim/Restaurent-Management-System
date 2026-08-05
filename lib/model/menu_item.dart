class MenuItem {
  String id;
  String name;
  double price;
  String vendorId;
  String category;
  bool available;
  String? image;

  MenuItem({
    required this.id,
    required this.name,
    required this.price,
    required this.vendorId,
    required this.category,
    this.available = true,
    this.image,
  });

  factory MenuItem.fromJson(String id, Map<String, dynamic> json) {
    return MenuItem(
      id: id,
      name: json['name'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      vendorId: json['vendorId'] ?? '',
      category: json['category'] ?? '',
      available: json['available'] ?? true,
      image: json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'vendorId': vendorId,
      'category': category,
      'available': available,
      'image': image,
    };
  }
}

class CartItem extends MenuItem {
  int quantity;

  CartItem({
    required super.id,
    required super.name,
    required super.price,
    required super.vendorId,
    required super.category,
    super.available,
    super.image,
    this.quantity = 1,
  });
}
