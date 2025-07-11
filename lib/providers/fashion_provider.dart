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
  
  // Mendapatkan data awal dengan URL images
  List<FashionItem> _getInitialItems() {
    return [
      FashionItem(
        id: '1',
        name: 'Minimalist White Tee',
        brand: 'ESSENTIALS',
        price: 200000,
        imagePath: 'https://www.google.com/url?sa=i&url=https%3A%2F%2Fpreloved.co.id%2Fproducts%2Funiqlo-minimalist-casual-t-shirt-wanita-white%3Fsrsltid%3DAfmBOopeq2N_BbwhtUAkvbhDjUCEj0lairaD1yspVGegCdTRXUKCp0p_&psig=AOvVaw3UIcfsEtusDB2mKwb3NsoS&ust=1752318461170000&source=images&cd=vfe&opi=89978449&ved=0CBQQjRxqFwoTCJDl9NrUtI4DFQAAAAAdAAAAABAL',
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
        imagePath: 'https://encrypted-tbn3.gstatic.com/shopping?q=tbn:ANd9GcSZQstyb4qA57xGX_lUisbxJRAhOpWSmpdmCggS5sQt3UiLeaelbRzR86cFkVh_h0eyg-3Gjtaf-7MesSeQpvGwdASNjvuwDgL4fbom_Rm3cKP1eoaIos1d',
        category: 'Bottoms',
        colors: ['Black', 'Navy', 'Beige'],
        sizes: ['24', '26', '28', '30', '32'],
        description: 'Elegant high-waist design with streamlined silhouette.',
        stock: 18,
      ),
      FashionItem(
        id: '4',
        name: 'Vintage Denim Jacket',
        brand: 'CLASSIC',
        price: 350000,
        imagePath: 'https://images.unsplash.com/photo-1551698618-1dfe5d97d256?w=400&h=600&fit=crop',
        category: 'Outerwear',
        colors: ['Blue', 'Light Blue', 'Dark Blue'],
        sizes: ['XS', 'S', 'M', 'L', 'XL'],
        description: 'Classic denim jacket with vintage wash and perfect fit.',
        stock: 20,
      ),
      FashionItem(
        id: '5',
        name: 'Leather Handbag',
        brand: 'LUXURY',
        price: 850000,
        imagePath: 'data:image/webp;base64,UklGRjoPAABXRUJQVlA4IC4PAAAQTQCdASrPAOQAPj0cjESiIaEQyOV8IAPEs4vJK+AHIDpTInmX4GVzgV9I3l72zZ/znR/SNvVvoiTcj+N5g+BP5k/Uz8L+ZPxl6vvdE388AHWJf3Xoj9kPYA/ln9J/xXrL/x/8z5an3b/Z+wN/L/7J/qv7r7E//J/k/Rh9H/+L3F/1p/5f2++AD9wfZb/YAiNi9OAwz+dmgrxe94t+YNIdyOqRSMBl3SvA7HFIX+V6/qr09akc17eBtcI1lSQiRCE/jldwX7vzCGGwlYqizsT1o20iiHJ2g2uKrmW6y9guTVg//sVHj1OgSatd8GCt3xTcnTPE2EimooFhwpO5StNBm3QVOFUwajx6UBJn9ELxrODs00XO1dFnVZvocsD05gC6oI4eDz/xtYuaOFrMoC5zaIvRYrk1zv94cBVo2HIEXQwrKnzN8NHPEBe3zmlNu2VjurCeWx2Koc0+J5lzeN6mRt1KOpsZa3ilyLNqsD7tfUxvqEyVXkXgIon2F8fgxVt3xrL/B3ZU9rrNdlAWe1D0y/3nmauYcpRJQqkbBMLL02tNBAUX8eqBRBuMD6yXungXRJ96HhTAFjTCyEevjX4MoHn9cvqFgnZffiu/vh19UXEkkLvExBcsY40ABoTIfWH+kRsDOBo+c23nGXNKaGwHGQFBLHc8jhhptHypWAmkX9aMcB+AL3FIwjMDTLpga1I6AMHdlPy81NXcsai5ssZmtaieOeMxRF6LrSFk2qaf2gL9D760frrrvg+jwXd8zRZYDF3zuG3U/UGDq9LVCu6LM0zYymGTMjHvTu314K83IQzDDk1yP0DtxfjPdIlpATgAAP7Y8A0eX8/Gtp+FyRj9CcFFAH/yXIomk8aJ8E2X9gCO91FnOnAwCu8z7oQL4zBcXrbjhqUmpjqAKfw91YdSUWy0N5Xc54pnrULn/VifpNgUA+8T1DXyU8udokh8l3XXObor9CcDiAvKdQHE56NkSSFVwkKz/pBs7w3x+kwOj4yMkln0/Pdc52x2NzCyxdm/cC+8ktTRskJa4yDO8zBwqSbeR8c9pQf9e6jzZ8+6ImTTY+vG9BfWuPp49B8v1hKkjCp1vRC/8+hs+w0Knmuq0ZSBHcHMCqIC4YLQlu5scvwsomP+EeMKjB2N/Y9OltDDGc3H7bAPhjLkiYndPYzBjPCUqI1Uq1wVtmvWhOAmSNCsu9tX+4bXWxIvse38PJbdUeIMcr8JqkC6w3in6dxmBACBYBcFI/v+ogGMlNXfC2wdiNhdBh8T/QQLGxIEf6jw3tywCATMD3zf+It2fYzgveiG3PyoK0hhN2tRZ2JD3+bB997Zn8eGEQhfcLBFd1bxTspjF1NFfLOwC15etBnMGSV9eGsG/v5S5fqcU1exJlcXIAo4Nd+VfjJ/7sOVEz3/jCHQ/IhG+lOCvinP81gjxlcKlHNmBlsUk1muZhiUqI7Csk9VXavil5hi3MemFqnbb6uvjbaMyAroXjdAUEA3cFlHOA+uZ6BHWF0IMpvhIR7UvcNwDcyGxoEKVq9aLaMZOBfTJRczJjls1OxL3r02VVkiQHsKaMD6dEpJOf0DzCcrdmYohByLWYk2AJnwrFOPvdcCyKlbd/iiDCdr/GIVjszTJ8j/VRf0BcefGbtsEMKQo3tnmLoLeOsVJihm7//xzi3s4NlNceuiidM+G2qGrgDkpBvwTYOuMG8C409F5L1Xt6rOc6MEHlg36ZuwAAkPmDrKp7c/+7InNfvfmQ2UD+wDY88uq1JOdMvo5tmJ+e0lf6aaHEy16vo07qyCQ3J2WDPFfDG8qG4HVvFasZ2DkPLBwX0XiI/uVUOX9OLmyRn/06uFR7ymgDLh1gIUdKpWoS3MBA18njPvg3bAe35QHZZPKJwbheK1c4Tiap8OI7DYIGR9+0zIMZiPFlDERccX4zoggw9uahXF2j1wjYAR+3ve8wzlk2q8t9Wj5VrUr+xW7bZ90WbELFpQ4XMmG0gZ8oWaWezJQEZV8yV6bt/7h2RcNR7gIvrqipMloRlzIXZaBCYMbuw7kYCjKrz+lF8u8DuLjnNIdfWI7vP94Hy9g+FUKODLLNRJxxGnQOLnMwDzBeofGnnK9R4rBrYb5yVEWv//jVyZ9VQsERv+u6/PS4W565yqMVfiMPajidzUlgkCsGCzm1gbrFkZ+sW2YGrZvDLUb6FGPr+tQPxGzw22U9Lqwm/HZT8fwgvy0XU1XFvHKZOMRrBZp7dEdOSY4VebOzMh4MXwTMFaP4QT9VB92pcb2riif8/6nl2yxvSpkAB3W98yKrBcPAXU9eYNlf24ABex3WoZfmCCFJc/SgK4MmL+/IfjCH80Qj6ML8f0DqYGty02JXBq1IcNfOP/7yTi9VdUzm6agdD4pZnW1U4bJptLU6YtFFanwq7odAn7wLSTty5oEk2a22LlfnRzfIPLCXGeCxxFPSC7i1SpBdd9ppQq/1tuH7vAhUWNMjTvXR2uDzHuLQlRzAEhc+rj2ukRO0Zv/Lo+h54a4vGzXwjsa5YhuwP+R9V+9+8w4ge+PYNCgnmvs+cjfpmXcaZYXLzXaC3zir1Tmc9vE/kYHhLiFXCl+8S0JIWY7mBxmAUt36sTuNV/0C62rKZMUGMm9EMZd9Cg+kTNdZqaASbSqMInSJDK+YRHF4CBkjgEKyEa5uABkWkrm5wRpvmZMMINAxd3v9ralEwJBbRIWiFA8r7Tc8Ow+SVArgDjU0i/wRgDnqFaCnhNClaRRuSdjVq4jvvLlYf74et4Jg3DgfPZzq9ozTbVxF9lVWc2CoGKXp807vIe8EDRGnH2gDIKlknCGAdnOkeI0eyabSlNzR9pjAyu2hwlfzrL23PKyNkp58AHJyk9eUTczgBBCnA+ZQiD3/tSCm8JFotyqhgvqUFNL9nDlfwqcdWC572MgZfxdMYeD9bk463wj3lgnZuAsroR4wanaH1fPS/4sLO86ibCdHhC7/4MRFzmbf/gwh8kJHWCXRdhnBMSCWSS74DoeRrx9F2dXmSjiaCOzXUHiUKj57wckOXe1xTCpJInRD1Ok7ID/OJrAqGgTqtmewkQjtKJsmGnVyOuYrE0URhHfGcTCUQOCIIo15OQZAjYa2famsoMP794x0jJFAYdxMIkd9o3whbhSXx8uikqfVXOc3OBGF3CXP27bj7ZG+ayIy5Jxg9wu0UV8edydJ4AeHKIxde5B/XOhPXg+12VTIf/8eVYjsUvibHze+mL8cUyiE+815FvebPslmFDQQM8OqCq2Kiy6KtVUbJx7LxcuDRnzLeH+s8yajm7NDqdvaRFcqBiTxDiq3n2d8temTwwoDRgFzIje9Ml02btpZNsQVxHAjwNnkRUIuI/H4wglHH+CNYWVAEZCngJNuqgy5z7VhXvCn7Lz/kRAbZQCJHWbOpBPN3tHJ1fRvHX0tmlN/KX/FwCsUYCx1SZyA+5UdJfSpw57P90AC54/ROfJ1bXqyk63tl4y/LDf9H4YHyw7YXRX1wgOYArfsQP35uHCh6LV+5ORcArEPMjgXb9Uvg/GStOfqDH39Ge2Yw1JjrA6UBpnZnFBjai53Dxdd3Ci+WQ+3cLF5/UcTEpO5zwEXNeB5juztPks4puPfOh9ymvVvWGU3CYcnGmKAQlG5VvwaDiiZbIgmveMXIMwLr3ojoEzxSQq0TKPPtq39JsUg13qDuYLO18GeZ9orMSV4rL+8521h98JDhFqDY1TKoCLkMU7wz+8NmYjsO4ampC+LVs1TVV8qyZ3El6b0+Gc7lqYWnVkq0QCiooHhU4WWVmoDX+JqOzIAACQHVpGQAr6lELUpo9M3fpWtnkGOH+zsBv//i5Do/D0Kb1cE3J9vcvC1cXppC6i2ocA0Q7JOyY9f9KCdT6XTWrvSQVbBXZxoWh0Rxu6InVudaaLG+wXDNeUNiUF95Ly6zvqeA7hPD5eYmXfIgZbn9Hsvpw+EiFxFL1vwPwK5uAR1FO84VBREkNQ1ZAeVkr2Q11nO+U8jNzU7s/m3u6qf7BnslJ+pUhmiXLdGIh1UY1q3dB6n+yCndnLCMj77ko4SGumeeMQdSHlJMh3TolFGBpdzgQs3lxKmivu9BlxCQJH1bdiVC1hz5IHMLEuqYWsDhPmA2MdjxawfcmePic8KEv30MtWQRzC8hstao2AVdsngMCdy5/MyGbrvNj7kxVFj6GE9yN0YTprCGPtP2sSsC1HqD/nfpdbsn2EJEANNPqQ8Ie0nhY6/IlcsUFcP7gqmsYuh76Binrtuk3rkupt3pWqQjewDYY/GC2wvfyZUDGRobHdSaAG0YgCLgIPfr9dnvzO2wW0HiC0klrehybFfw/lHG4vyD0nFRt9K6Lc8CYcTtxBHN6Khmk7AZIDmApSA/elKlX9smwLPEoLwUuJeYOmo8XnB9T2dTR/VmcttyrrysgRAzd2ZST/swJzMmIXaj2Cb2curu7rGElT8BJxwjdMUFgy+TOu2Zpy6Euttq3hfUR43iebU8K7Wf/ZvnABR2zca+P2i2CNo5qMXHwvNFwoNvv33nltDMK54HrXLtte54GrZverYBPZpbdnN0KVz6X1R8TBrXmEQb/rwcZwYoiCYDgYMMnVWZx42ZoWp2l9k0gfxfvsJyrGlIqKx7EZ2p5mj7+ZzuGNRb8Is9vUo9Mqc0K05YGiSXFeRxzUfLYxSNNZn0eg7mE4iViTbFeb8VLy+ZByXACS5vL2QaKK9htcptEynUksZD//AuT2Tr5LkHEqd77WQt04f9DroolPnIlb2iXWkl9EO8n7kbjxzjo56orfpEVGLxH+17+htveWZV2twIBzSETRNyDOE5G2mywGDWb1gUpA4bMFFXcPRtroRmq5GUm2yTIWcWcRrsgQWTmoYY0eOpKWNw9LHEfG5jkypxQPguPoO0PCoIVvAVoGJoAarVAgDSNaxTw7o5kZw3kHRajoaRojg5iH48NBn7kVhGe2KdNn9k8A2+iRMO2YPqIZnIH8l5gS9QjgyuM2Y5GoNDxK8Rq0yx03+KieCprqB+3qnyVGO+XEmcSusJsrnYXQRCg+9r25yTaPD/rkgJ1ryldS0Pf3RYH2Sgmp7xNmjCivi/IkGDgvTgapQhRZ1DSW18teEd3xV1AMTxg1N330S70qUwQg28B6XFsRvCnRFX6otSrL27WZYcEwI2Pr5qoV4IkfUmU8AAAAAAAAAAA',
        category: 'Accessories',
        colors: ['Black', 'Brown', 'Tan'],
        sizes: ['One Size'],
        description: 'Premium leather handbag with elegant design.',
        stock: 8,
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
      notifyListeners();
    } catch (e) {
      print('Error loading cart from database: $e');
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
      try {
        final db = await _dbHelper.database;
        await db.update(
          'items',
          {'isFavorite': _items[itemIndex].isFavorite ? 1 : 0},
          where: 'id = ?',
          whereArgs: [id],
        );
      } catch (e) {
        print('Error updating favorite status: $e');
      }
      
      notifyListeners();
    }
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  // CRUD untuk items
  Future<void> addItem(FashionItem item) async {
    try {
      final db = await _dbHelper.database;
      await db.insert('items', item.toMap());
      await _loadItemsFromDb();
    } catch (e) {
      print('Error adding item: $e');
    }
  }
  
  Future<void> updateItem(FashionItem updatedItem) async {
    try {
      final db = await _dbHelper.database;
      
      // Update item in database
      await db.update(
        'items',
        updatedItem.toMap(),
        where: 'id = ?',
        whereArgs: [updatedItem.id],
      );
      
      // Update item in memory
      final itemIndex = _items.indexWhere((item) => item.id == updatedItem.id);
      if (itemIndex >= 0) {
        _items[itemIndex] = updatedItem;
        notifyListeners();
        print('Item updated successfully: ${updatedItem.name}');
      } else {
        print('Item not found for update: ${updatedItem.id}');
      }
    } catch (e) {
      print('Error updating item: $e');
      throw e; // Re-throw to allow handling in UI
    }
  }

  Future<void> deleteItem(String id) async {
    try {
      final db = await _dbHelper.database;
      
      // Delete item from database
      final deletedRows = await db.delete(
        'items',
        where: 'id = ?',
        whereArgs: [id],
      );
      
      if (deletedRows > 0) {
        // Delete item from memory
        _items.removeWhere((item) => item.id == id);
        
        // Also remove any cart items associated with this product
        _cartItems.removeWhere((cartItem) => cartItem.fashionItemId == id);
        await db.delete(
          'cart',
          where: 'fashionItemId = ?',
          whereArgs: [id],
        );
        
        notifyListeners();
        print('Item deleted successfully: $id');
      } else {
        print('Item not found for deletion: $id');
      }
    } catch (e) {
      print('Error deleting item: $e');
      throw e; // Re-throw to allow handling in UI
    }
  }
  
  // Cart methods
  Future<void> addToCart(FashionItem fashionItem, String selectedColor, String selectedSize) async {
    // Cek apakah item dengan kombinasi yang sama sudah ada di cart
    final existingCartItemIndex = _cartItems.indexWhere((cartItem) =>
    cartItem.fashionItemId == fashionItem.id &&
        cartItem.selectedColor == selectedColor &&
        cartItem.selectedSize == selectedSize);

    try {
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
          quantity: 1,
        );
        
        // Simpan ke database
        await db.insert('cart', cartItem.toMap());
        _cartItems.add(cartItem);
      }
      
      // Pastikan untuk memanggil notifyListeners() agar UI diperbarui
      notifyListeners();
      
      print('Cart items after adding: ${_cartItems.length}');
      for (var item in _cartItems) {
        print('Cart item: ${item.name}, Color: ${item.selectedColor}, Size: ${item.selectedSize}, Quantity: ${item.quantity}');
      }
      
    } catch (e) {
      print('Error adding to cart: $e');
    }
  }

  Future<void> removeFromCart(String cartItemId) async {
    try {
      final db = await _dbHelper.database;
      await db.delete(
        'cart',
        where: 'id = ?',
        whereArgs: [cartItemId],
      );
      
      _cartItems.removeWhere((item) => item.id == cartItemId);
      notifyListeners();
    } catch (e) {
      print('Error removing from cart: $e');
    }
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
      try {
        final db = await _dbHelper.database;
        await db.update(
          'cart',
          {'quantity': newQuantity},
          where: 'id = ?',
          whereArgs: [cartItemId],
        );
      } catch (e) {
        print('Error updating cart item quantity: $e');
      }
      
      notifyListeners();
    }
  }

  Future<void> clearCart() async {
    try {
      final db = await _dbHelper.database;
      await db.delete('cart');
      
      _cartItems.clear();
      notifyListeners();
    } catch (e) {
      print('Error clearing cart: $e');
    }
  }

  // Method untuk mengecek apakah item sudah ada di cart
  bool isInCart(String fashionItemId) {
    return _cartItems.any((cartItem) => cartItem.fashionItemId == fashionItemId);
  }
}