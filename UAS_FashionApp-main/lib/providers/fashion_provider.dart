import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../models/fashion_model.dart';
import '../helpers/database_helper.dart';

class FashionProvider with ChangeNotifier {
  List<FashionItem> _items = [];
  List<CartItem> _cartItems = []; // List untuk cart items
  List<String> _categories = ['All', 'Tops', 'Bottoms', 'Outerwear', 'Accessories'];
  String _selectedCategory = 'All';
  final DatabaseHelper _dbHelper = DatabaseHelper();
  
  // Constructor
  FashionProvider() {
    _initData();
  }
  
  // Getter untuk mengetahui apakah data sudah dimuat
  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;
  
  // Inisialisasi data
  Future<void> _initData() async {
    await _loadItemsFromDb();
    await _loadCartFromDb();
    _isLoaded = true;
    notifyListeners();
  }
  
  // Load items dari database
  Future<void> _loadItemsFromDb() async {
    try {
      final db = await _dbHelper.database;
      final itemsData = await db.query('items');
      
      if (itemsData.isEmpty) {
        // Tambahkan data awal jika database kosong
        await _addInitialItems();
        final newItemsData = await db.query('items');
        _items = newItemsData.map((item) => FashionItem.fromMap(item)).toList();
      } else {
        _items = itemsData.map((item) => FashionItem.fromMap(item)).toList();
      }
      print('Loaded ${_items.length} items from database');
      notifyListeners();
    } catch (e) {
      print('Error loading items from database: $e');
      // Tambahkan data awal jika terjadi error
      _items = _getInitialItems();
      notifyListeners();
    }
  }
  
  // Mendapatkan data awal
  List<FashionItem> _getInitialItems() {
    return [
      FashionItem(
        id: '1',
        name: 'Minimalist White Tee',
        brand: 'ESSENTIALS',
        price: 200000,
        imagePath: 'assets/images/placeholder.png',
        category: 'Tops',
        colors: ['White', 'Black', 'Grey'],
        sizes: ['XS', 'S', 'M', 'L', 'XL'],
        description: 'Clean, minimalist design with premium cotton blend.',
        stock: 25,
      ),
      FashionItem(
        id: '2',
        name: 'Tailored Blazer',
        brand: 'MODERN',
        price: 750000,
        imagePath: 'assets/images/placeholder.png',
        category: 'Outerwear',
        colors: ['Navy', 'Black', 'Charcoal'],
        sizes: ['XS', 'S', 'M', 'L', 'XL'],
        description: 'Structured blazer with clean lines and perfect fit.',
        stock: 12,
      ),
      FashionItem(
        id: '3',
        name: 'High-Waist Trousers',
        brand: 'REFINED',
        price: 450000,
        imagePath: 'assets/images/placeholder.png',
        category: 'Bottoms',
        colors: ['Black', 'Navy', 'Beige'],
        sizes: ['24', '26', '28', '30', '32'],
        description: 'Elegant high-waist design with streamlined silhouette.',
        stock: 18,
      ),
    ];
  }
  
  // Tambahkan data awal
  Future<void> _addInitialItems() async {
    final initialItems = _getInitialItems();
    
    final db = await _dbHelper.database;
    for (var item in initialItems) {
      await db.insert('items', item.toMap());
    }
  }
  
  // Load cart dari database
  Future<void> _loadCartFromDb() async {
    try {
      final db = await _dbHelper.database;
      final cartData = await db.query('cart');
      _cartItems = cartData.map((item) => CartItem.fromMap(item)).toList();
      print('Loaded ${_cartItems.length} cart items from database');
      notifyListeners();
    } catch (e) {
      print('Error loading cart from database: $e');
      _cartItems = [];
      notifyListeners();
    }
  }

  // Getters
  List<FashionItem> get items => _items;
  List<CartItem> get cartItems => _cartItems;
  List<String> get categories => _categories;
  String get selectedCategory => _selectedCategory;

  List<FashionItem> get filteredItems {
    if (_selectedCategory == 'All') {
      return _items;
    }
    return _items.where((item) => item.category == _selectedCategory).toList();
  }

  List<FashionItem> get favoriteItems {
    return _items.where((item) => item.isFavorite).toList();
  }

  // Cart getters
  int get cartItemCount => _cartItems.length;

  double get cartTotalPrice {
    return _cartItems.fold(0.0, (total, item) => total + item.totalPrice);
  }

  // Methods
  Future<void> toggleFavorite(String id) async {
    final itemIndex = _items.indexWhere((item) => item.id == id);
    if (itemIndex >= 0) {
      _items[itemIndex].isFavorite = !_items[itemIndex].isFavorite;
      
      // Update di database
      final db = await _dbHelper.database;
      await db.update(
        'items',
        {'isFavorite': _items[itemIndex].isFavorite ? 1 : 0},
        where: 'id = ?',
        whereArgs: [id],
      );
      
      notifyListeners();
    }
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  // CRUD untuk items
  Future<void> addItem(FashionItem item) async {
    final db = await _dbHelper.database;
    await db.insert('items', item.toMap());
    await _loadItemsFromDb();
  }
  
  Future<void> updateItem(FashionItem item) async {
    final db = await _dbHelper.database;
    await db.update(
      'items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
    await _loadItemsFromDb();
  }
  
  Future<void> deleteItem(String id) async {
    final db = await _dbHelper.database;
    await db.delete(
      'items',
      where: 'id = ?',
      whereArgs: [id],
    );
    await _loadItemsFromDb();
  }
  
  // Cart methods
  Future<void> addToCart(FashionItem fashionItem, String selectedColor, String selectedSize) async {
    // Cek apakah item dengan kombinasi yang sama sudah ada di cart
    final existingCartItemIndex = _cartItems.indexWhere((cartItem) =>
    cartItem.fashionItemId == fashionItem.id &&
        cartItem.selectedColor == selectedColor &&
        cartItem.selectedSize == selectedSize);

    final db = await _dbHelper.database;
    
    if (existingCartItemIndex >= 0) {
      // Jika sudah ada, tambah quantity
      _cartItems[existingCartItemIndex].quantity++;
      
      // Update di database
      await db.update(
        'cart',
        {'quantity': _cartItems[existingCartItemIndex].quantity},
        where: 'id = ?',
        whereArgs: [_cartItems[existingCartItemIndex].id],
      );
    } else {
      // Jika belum ada, buat cart item baru
      final cartItem = CartItem(
        id: '${fashionItem.id}_${selectedColor}_${selectedSize}_${DateTime.now().millisecondsSinceEpoch}',
        fashionItemId: fashionItem.id,
        name: fashionItem.name,
        brand: fashionItem.brand,
        price: fashionItem.price,
        imagePath: fashionItem.imagePath,
        selectedColor: selectedColor,
        selectedSize: selectedSize,
      );
      
      // Simpan ke database
      await db.insert('cart', cartItem.toMap());
      _cartItems.add(cartItem);
    }
    notifyListeners();
  }

  Future<void> removeFromCart(String cartItemId) async {
    final db = await _dbHelper.database;
    await db.delete(
      'cart',
      where: 'id = ?',
      whereArgs: [cartItemId],
    );
    
    _cartItems.removeWhere((item) => item.id == cartItemId);
    notifyListeners();
  }

  Future<void> updateCartItemQuantity(String cartItemId, int newQuantity) async {
    if (newQuantity <= 0) {
      await removeFromCart(cartItemId);
      return;
    }

    final cartItemIndex = _cartItems.indexWhere((item) => item.id == cartItemId);
    if (cartItemIndex >= 0) {
      _cartItems[cartItemIndex].quantity = newQuantity;
      
      // Update di database
      final db = await _dbHelper.database;
      await db.update(
        'cart',
        {'quantity': newQuantity},
        where: 'id = ?',
        whereArgs: [cartItemId],
      );
      
      notifyListeners();
    }
  }

  Future<void> clearCart() async {
    final db = await _dbHelper.database;
    await db.delete('cart');
    
    _cartItems.clear();
    notifyListeners();
  }

  // Method untuk mengecek apakah item sudah ada di cart
  bool isInCart(String fashionItemId) {
    return _cartItems.any((cartItem) => cartItem.fashionItemId == fashionItemId);
  }
}