import 'package:flutter/material.dart';
import '../models/fashion_model.dart';

class FashionProvider extends ChangeNotifier {
  List<FashionItem> _items = [];
  List<CartItem> _cartItems = [];
  String _searchQuery = '';

  FashionProvider() {
    _loadItems();
  }

  List<FashionItem> get items => _items;
  List<CartItem> get cartItems => _cartItems;
  String get searchQuery => _searchQuery;

  List<FashionItem> get filteredItems {
    if (_searchQuery.isEmpty) {
      return _items;
    }
    return _items.where((item) {
      return item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.brand.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  int get cartItemCount {
    return _cartItems.fold(0, (sum, item) => sum + item.quantity);
  }

  double get cartTotalPrice {
    return _cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  void _loadItems() {
    _items = [
      FashionItem(
        id: '1',
        name: 'Summer Dress',
        brand: 'Zara',
        price: 299000,
        imagePath: 'assets/images/dress1.jpg',
        colors: ['Red', 'Blue', 'White'],
        sizes: ['S', 'M', 'L', 'XL'],
        description: 'Beautiful summer dress perfect for any occasion. Made from lightweight cotton fabric with a flattering silhouette.',
        stock: 10,
      ),
      FashionItem(
        id: '2',
        name: 'Casual T-Shirt',
        brand: 'H&M',
        price: 149000,
        imagePath: 'assets/images/tshirt1.jpg',
        colors: ['Black', 'White', 'Gray'],
        sizes: ['S', 'M', 'L', 'XL'],
        description: 'Comfortable cotton t-shirt for everyday wear. Soft fabric with classic fit.',
        stock: 15,
      ),
      FashionItem(
        id: '3',
        name: 'Denim Jeans',
        brand: 'Levi\'s',
        price: 599000,
        imagePath: 'assets/images/jeans1.jpg',
        colors: ['Blue', 'Black', 'Light Blue'],
        sizes: ['28', '30', '32', '34'],
        description: 'Classic denim jeans with perfect fit. Durable and stylish for any casual look.',
        stock: 8,
      ),
      FashionItem(
        id: '4',
        name: 'Formal Blazer',
        brand: 'Mango',
        price: 799000,
        imagePath: 'assets/images/blazer1.jpg',
        colors: ['Black', 'Navy', 'Gray'],
        sizes: ['S', 'M', 'L', 'XL'],
        description: 'Professional blazer for business occasions. Tailored fit with premium fabric.',
        stock: 5,
      ),
      FashionItem(
        id: '5',
        name: 'Sneakers',
        brand: 'Nike',
        price: 899000,
        imagePath: 'assets/images/sneakers1.jpg',
        colors: ['White', 'Black', 'Gray'],
        sizes: ['38', '39', '40', '41', '42'],
        description: 'Comfortable sneakers for sports and casual wear. Air cushion technology for maximum comfort.',
        stock: 12,
      ),
      FashionItem(
        id: '6',
        name: 'Floral Skirt',
        brand: 'Forever 21',
        price: 199000,
        imagePath: 'assets/images/skirt1.jpg',
        colors: ['Pink', 'Blue', 'Yellow'],
        sizes: ['S', 'M', 'L'],
        description: 'Cute floral skirt perfect for spring. Lightweight and comfortable for all-day wear.',
        stock: 7,
      ),
      FashionItem(
        id: '7',
        name: 'Leather Jacket',
        brand: 'Pull & Bear',
        price: 1299000,
        imagePath: 'assets/images/jacket1.jpg',
        colors: ['Black', 'Brown'],
        sizes: ['S', 'M', 'L', 'XL'],
        description: 'Stylish leather jacket for a bold look. Genuine leather with premium finish.',
        stock: 3,
      ),
      FashionItem(
        id: '8',
        name: 'High Heels',
        brand: 'Charles & Keith',
        price: 699000,
        imagePath: 'assets/images/heels1.jpg',
        colors: ['Black', 'Red', 'Nude'],
        sizes: ['36', '37', '38', '39', '40'],
        description: 'Elegant high heels for formal events. Comfortable heel height with cushioned insole.',
        stock: 6,
      ),
    ];
    notifyListeners();
  }

  void addToCart(FashionItem item, String selectedColor, String selectedSize) {
    final existingIndex = _cartItems.indexWhere((cartItem) =>
    cartItem.fashionItemId == item.id &&
        cartItem.selectedColor == selectedColor &&
        cartItem.selectedSize == selectedSize);

    if (existingIndex >= 0) {
      _cartItems[existingIndex].quantity += 1;
    } else {
      final cartItem = CartItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        fashionItemId: item.id,
        name: item.name,
        brand: item.brand,
        price: item.price,
        imagePath: item.imagePath,
        selectedColor: selectedColor,
        selectedSize: selectedSize,
        description: item.description,
        quantity: 1,
      );
      _cartItems.add(cartItem);
    }
    notifyListeners();
  }

  void removeFromCart(String cartItemId) {
    _cartItems.removeWhere((item) => item.id == cartItemId);
    notifyListeners();
  }

  void updateCartItemQuantity(String cartItemId, int newQuantity) {
    final index = _cartItems.indexWhere((item) => item.id == cartItemId);
    if (index >= 0) {
      if (newQuantity > 0) {
        _cartItems[index].quantity = newQuantity;
      } else {
        _cartItems.removeAt(index);
      }
      notifyListeners();
    }
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  void toggleFavorite(String itemId) {
    final index = _items.indexWhere((item) => item.id == itemId);
    if (index >= 0) {
      _items[index].isFavorite = !_items[index].isFavorite;
      notifyListeners();
    }
  }
}