class FashionItem {
  final String id;
  final String name;
  final String brand;
  final double price;
  final String imagePath;
  final List<String> colors;
  final List<String> sizes;
  final String description;
  final int stock;
  bool isFavorite;

  FashionItem({
    required this.id,
    required this.name,
    required this.brand,
    required this.price,
    required this.imagePath,
    required this.colors,
    required this.sizes,
    required this.description,
    required this.stock,
    this.isFavorite = false,
  });
}

class CartItem {
  final String id;
  final String fashionItemId;
  final String name;
  final String brand;
  final double price;
  final String imagePath;
  final String selectedColor;
  final String selectedSize;
  final String description;
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
    required this.description,
    this.quantity = 1,
  });

  double get totalPrice => price * quantity;
}