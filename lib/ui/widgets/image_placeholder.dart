import 'package:flutter/material.dart';

class ImagePlaceholder extends StatelessWidget {
  final String itemName;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const ImagePlaceholder({
    Key? key,
    required this.itemName,
    this.width,
    this.height,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: _getColorForItem(itemName),
        borderRadius: borderRadius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getColorForItem(itemName),
            _getColorForItem(itemName).withOpacity(0.7),
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getIconForItem(itemName),
            size: width != null ? width! * 0.3 : 40,
            color: Colors.white,
          ),
          SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              itemName,
              style: TextStyle(
                color: Colors.white,
                fontSize: width != null ? width! * 0.08 : 12,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorForItem(String itemName) {
    final name = itemName.toLowerCase();
    if (name.contains('dress')) return Colors.pink[400]!;
    if (name.contains('shirt') || name.contains('t-shirt')) return Colors.blue[400]!;
    if (name.contains('jeans')) return Colors.indigo[400]!;
    if (name.contains('blazer')) return Colors.grey[700]!;
    if (name.contains('sneakers')) return Colors.green[400]!;
    if (name.contains('skirt')) return Colors.purple[400]!;
    if (name.contains('jacket')) return Colors.brown[400]!;
    if (name.contains('heels')) return Colors.red[400]!;
    return Colors.orange[400]!;
  }

  IconData _getIconForItem(String itemName) {
    final name = itemName.toLowerCase();
    if (name.contains('dress') || name.contains('skirt')) return Icons.checkroom;
    if (name.contains('shirt') || name.contains('t-shirt') || name.contains('blazer') || name.contains('jacket')) return Icons.dry_cleaning;
    if (name.contains('jeans')) return Icons.content_cut;
    if (name.contains('sneakers') || name.contains('heels')) return Icons.sports_soccer;
    return Icons.shopping_bag;
  }
}