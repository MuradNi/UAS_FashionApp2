import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/fashion_provider.dart';
import '../widgets/fashion_item_card.dart';
import 'cart_screen.dart';
import '../../models/fashion_model.dart';

class MainFashionScreen extends StatefulWidget {
  @override
  _MainFashionScreenState createState() => _MainFashionScreenState();
}

class _MainFashionScreenState extends State<MainFashionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              _buildHeader(),
              SizedBox(height: 30),
              _buildCategoryFilter(),
              SizedBox(height: 30),
              Expanded(
                child: _buildFashionGrid(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddProductDialog(context),
        backgroundColor: Colors.black,
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fashion App',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            Text(
              'UAS Pemograman Mobile (Fashion APP)',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        Row(
          children: [
            // Cart button with badge
            Consumer<FashionProvider>(
              builder: (context, provider, child) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CartScreen()),
                    );
                  },
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Icon(
                            Icons.shopping_cart_outlined,
                            color: Colors.grey[700],
                            size: 20,
                          ),
                        ),
                        if (provider.cartItemCount > 0)
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  '${provider.cartItemCount > 9 ? '9+' : provider.cartItemCount}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
            SizedBox(width: 12),
            // Profile button
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.person_outline,
                color: Colors.grey[700],
                size: 20,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryFilter() {
    return Consumer<FashionProvider>(
      builder: (context, provider, child) {
        return Container(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: provider.categories.length,
            itemBuilder: (context, index) {
              final category = provider.categories[index];
              final isSelected = category == provider.selectedCategory;

              return GestureDetector(
                onTap: () => provider.setCategory(category),
                child: Container(
                  margin: EdgeInsets.only(right: 16),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.black : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? Colors.black : Colors.grey[300]!,
                    ),
                  ),
                  child: Text(
                    category,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey[600],
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      fontSize: 14,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildFashionGrid() {
    return Consumer<FashionProvider>(
      builder: (context, provider, child) {
        final items = provider.filteredItems;

        if (items.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.shopping_bag_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                SizedBox(height: 16),
                Text(
                  'No items found',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Try selecting a different category',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        }

        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.7,
            crossAxisSpacing: 16,
            mainAxisSpacing: 20,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            return FashionItemCard(item: items[index]);
          },
        );
      },
    );
  }
  
  void _showAddProductDialog(BuildContext context) {
    final nameController = TextEditingController();
    final brandController = TextEditingController();
    final priceController = TextEditingController();
    final descriptionController = TextEditingController();
    final stockController = TextEditingController();
    final imagePathController = TextEditingController(text: 'https://via.placeholder.com/300');
    
    String selectedCategory = 'Tops';
    List<String> colors = [];
    List<String> sizes = [];
    
    final availableCategories = Provider.of<FashionProvider>(context, listen: false).categories;
    final availableColors = ['White', 'Black', 'Grey', 'Navy', 'Red', 'Blue', 'Green', 'Yellow', 'Purple', 'Pink', 'Orange', 'Brown', 'Beige', 'Charcoal'];
    final availableSizes = ['XS', 'S', 'M', 'L', 'XL', '24', '26', '28', '30', '32'];
    
    // Fungsi untuk validasi URL
    bool isValidUrl(String url) {
      Uri? uri = Uri.tryParse(url);
      return uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
    }
    
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Add New Product'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: 'Product Name'),
                  ),
                  TextField(
                    controller: brandController,
                    decoration: InputDecoration(labelText: 'Brand'),
                  ),
                  TextField(
                    controller: priceController,
                    decoration: InputDecoration(labelText: 'Price (Rp)'),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: descriptionController,
                    decoration: InputDecoration(labelText: 'Description'),
                    maxLines: 3,
                  ),
                  TextField(
                    controller: stockController,
                    decoration: InputDecoration(labelText: 'Stock'),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: imagePathController,
                    decoration: InputDecoration(
                      labelText: 'Image URL',
                      hintText: 'Enter a valid image URL (http/https)',
                    ),
                    keyboardType: TextInputType.url,
                  ),
                  SizedBox(height: 16),
                  
                  // Category Dropdown
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: InputDecoration(labelText: 'Category'),
                    items: availableCategories
                        .where((cat) => cat != 'All')
                        .map((cat) => DropdownMenuItem(
                              value: cat,
                              child: Text(cat),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedCategory = value;
                        });
                      }
                    },
                  ),
                  
                  SizedBox(height: 16),
                  Text('Available Colors:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Wrap(
                    spacing: 8,
                    children: availableColors.map((color) {
                      final isSelected = colors.contains(color);
                      return FilterChip(
                        label: Text(color),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              colors.add(color);
                            } else {
                              colors.remove(color);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  
                  SizedBox(height: 16),
                  Text('Available Sizes:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Wrap(
                    spacing: 8,
                    children: availableSizes.map((size) {
                      final isSelected = sizes.contains(size);
                      return FilterChip(
                        label: Text(size),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              sizes.add(size);
                            } else {
                              sizes.remove(size);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  // Validasi input
                  if (nameController.text.isEmpty ||
                      brandController.text.isEmpty ||
                      priceController.text.isEmpty ||
                      stockController.text.isEmpty ||
                      colors.isEmpty ||
                      sizes.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please fill all required fields')),
                    );
                    return;
                  }
                  
                  // Validasi URL gambar
                  if (!isValidUrl(imagePathController.text)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please enter a valid image URL (http/https)')),
                    );
                    return;
                  }
                  
                  // Buat objek FashionItem baru
                  final newItem = FashionItem(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: nameController.text,
                    brand: brandController.text,
                    price: double.parse(priceController.text),
                    imagePath: imagePathController.text,
                    category: selectedCategory,
                    colors: colors,
                    sizes: sizes,
                    description: descriptionController.text,
                    stock: int.parse(stockController.text),
                  );
                  
                  // Tambahkan item baru ke provider
                  await Provider.of<FashionProvider>(context, listen: false).addItem(newItem);
                  
                  Navigator.of(context).pop();
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Product added successfully')),
                  );
                },
                child: Text('Add Product'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}