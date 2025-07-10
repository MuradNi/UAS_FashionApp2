class FashionItem {
  final String id;
  final String name;
  final String brand;
  final double price;
  final String imagePath;
  final String category;
  final List<String> colors;
  final List<String> sizes;
  final String description;
  final int stock; // Tambahan stock
  bool isFavorite;

  FashionItem({
    required this.id,
    required this.name,
    required this.brand,
    required this.price,
    required this.imagePath,
    required this.category,
    required this.colors,
    required this.sizes,
    required this.description,
    required this.stock, // Tambahan stock
    this.isFavorite = false,
  });
  
  // Konversi FashionItem ke Map untuk SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'price': price,
      'imagePath': imagePath,
      'category': category,
      'colors': colors.join(','),
      'sizes': sizes.join(','),
      'description': description,
      'stock': stock,
      'isFavorite': isFavorite ? 1 : 0,
    };
  }
  
  // Membuat FashionItem dari Map SQLite
  factory FashionItem.fromMap(Map<String, dynamic> map) {
    return FashionItem(
      id: map['id'] as String,
      name: map['name'] as String,
      brand: map['brand'] as String,
      price: map['price'] is int ? (map['price'] as int).toDouble() : map['price'] as double,
      imagePath: map['imagePath'] as String,
      category: map['category'] as String,
      colors: (map['colors'] as String).split(','),
      sizes: (map['sizes'] as String).split(','),
      description: map['description'] as String,
      stock: map['stock'] as int,
      isFavorite: map['isFavorite'] == 1,
    );
  }
}

// Model untuk item di cart
class CartItem {
  final String id;
  final String fashionItemId;
  final String name;
  final String brand;
  final double price;
  final String imagePath;
  final String selectedColor;
  final String selectedSize;
  int quantity;

  CartItem({
    required this.id,
    required this.fashionItemId,
    required this.name,
    required this.brand,
    required this.price,
    required this.imagePath,
    required this.selectedColor,
    required this.selectedSize,
    this.quantity = 1,
  });

  double get totalPrice => price * quantity;
  
  // Konversi CartItem ke Map untuk SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fashionItemId': fashionItemId,
      'name': name,
      'brand': brand,
      'price': price,
      'imagePath': imagePath,
      'selectedColor': selectedColor,
      'selectedSize': selectedSize,
      'quantity': quantity,
    };
  }
  
  // Membuat CartItem dari Map SQLite
  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      id: map['id'] as String,
      fashionItemId: map['fashionItemId'] as String,
      name: map['name'] as String,
      brand: map['brand'] as String,
      price: map['price'] is int ? (map['price'] as int).toDouble() : map['price'] as double,
      imagePath: map['imagePath'] as String,
      selectedColor: map['selectedColor'] as String,
      selectedSize: map['selectedSize'] as String,
      quantity: map['quantity'] as int,
    );
  }
}