import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product_model.dart';
import '../providers/cart_provider.dart';

// 1. Change StatelessWidget to StatefulWidget [cite: 46]
class ProductDetailScreen extends StatefulWidget {
  final Product product;
  // NOTE: productData and productid were used in the PDF example, but the
  // provided code uses the Product model directly. We use the Product model.

  const ProductDetailScreen({super.key, required this.product});

  @override
  // 2. Create the State class [cite: 54]
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

// 3. Rename the main class to _ProductDetailScreenState and extend State [cite: 55]
class _ProductDetailScreenState extends State<ProductDetailScreen> {
  // 4. ADD OUR NEW STATE VARIABLE FOR QUANTITY [cite: 56]
  int _quantity = 1; // It always starts at 1 [cite: 65]

  Widget _buildFeatureCard(
      BuildContext context,
      IconData icon,
      String label,
      String value,
      Color iconColor,
      Color labelColor,
      ) {
    return Expanded(
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Icon(icon, color: iconColor, size: 28),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(fontSize: 12, color: labelColor),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87, // Default color
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 1. ADD THIS FUNCTION [cite: 69]
  void _incrementQuantity() {
    setState(() { // Calls setState to rebuild the UI [cite: 72, 84]
      _quantity++; // Adds 1 to _quantity [cite: 74, 84]
    });
  }

  // 2. ADD THIS FUNCTION [cite: 75]
  void _decrementQuantity() {
    // We don't want to go below 1 [cite: 77]
    if (_quantity > 1) { // Checks that _quantity is greater than 1 [cite: 85]
      setState(() { // Calls setState to rebuild the UI [cite: 78, 85]
        _quantity--; // [cite: 79]
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // 1. Access product data using 'widget.' [cite: 170]
    final product = widget.product;
    final cart = Provider.of<CartProvider>(context, listen: false); // [cite: 96]

    final cardIconColor = theme.primaryColor;
    final cardLabelColor = Colors.grey[600]!;

    return Scaffold(
      appBar: AppBar(title: Text(product.name)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Product Image
            Image.network(
              product.imageUrl,
              height: 300,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const SizedBox(height: 300, child: Center(child: CircularProgressIndicator()));
              },
              errorBuilder: (context, error, stackTrace) {
                return const SizedBox(height: 300, child: Center(child: Icon(Icons.broken_image, size: 100)));
              },
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name
                  Text(
                    product.name,
                    style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  Text(
                    product.genre,
                    style: TextStyle(
                        fontSize: 16,
                        color: theme.primaryColor,
                        fontStyle: FontStyle.italic
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Row for Price, Format, Rating
                  Row(
                    children: [
                      // 1. Price Card
                      _buildFeatureCard(
                        context,
                        Icons.monetization_on_outlined,
                        'Price',
                        '₱${product.price.toStringAsFixed(2)}',
                        cardIconColor,
                        cardLabelColor,
                      ),

                      // 2. Format Card
                      _buildFeatureCard(
                        context,
                        Icons.menu_book,
                        'Format',
                        product.format,
                        cardIconColor,
                        cardLabelColor,
                      ),

                      _buildFeatureCard(
                        context,
                        Icons.star_half_outlined,
                        'Rating',
                        '4.8',
                        cardIconColor,
                        cardLabelColor,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  const Divider(thickness: 1),
                  const SizedBox(height: 16),

                  Text(
                    'Synopsis',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),

                  // Full Description
                  Text(
                    product.description,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 30),

                  // --- ADD THIS NEW SECTION (Quantity Selector) [cite: 109]
                  const SizedBox(height: 20),
                  Row( // Add a new Row to hold + / - buttons horizontally [cite: 112, 171]
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 5. DECREMENT BUTTON [cite: 115]
                      IconButton.filledTonal( // Nice-looking "less important" button for the - icon [cite: 116, 172]
                        icon: const Icon(Icons.remove),
                        onPressed: _decrementQuantity, // Calls the decrement function [cite: 119]
                      ),
                      // 6. QUANTITY DISPLAY [cite: 120]
                      Padding(
                        padding: const EdgeInsets.symmetric (horizontal: 20), // [cite: 123]
                        child: Text(
                          '$_quantity', // 7. Display our state variable [cite: 126, 174]
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold), // [cite: 127]
                        ),
                      ),
                      // 8. INCREMENT BUTTON [cite: 128]
                      IconButton.filled( // Standard filled button for the + icon [cite: 129, 173]
                        icon: const Icon(Icons.add), // [cite: 130]
                        onPressed: _incrementQuantity, // Calls the increment function [cite: 131]
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // END OF NEW SECTION [cite: 137]

                  // 9. Find your "Add to Cart" button [cite: 138]
                  ElevatedButton.icon(
                    onPressed: () { // [cite: 140]
                      // 10. --- THIS IS THE UPDATED LOGIC [cite: 141]
                      // We now pass the _quantity from our state
                      cart.addItem(
                        product.id,
                        product.name,
                        product.price,
                        product.genre,
                        product.format,
                        _quantity, // 11. Pass the selected quantity [cite: 147, 175]
                      );

                      // 12. Update the SnackBar message [cite: 148, 176]
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Added $_quantity x ${product.name} to cart!'), // [cite: 150]
                          duration: const Duration(seconds: 2), // [cite: 150]
                        ),
                      );
                    },
                    icon: const Icon(Icons.shopping_cart),

                    label: Text('Add to Cart - ₱${product.price.toStringAsFixed(2)}'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontSize: 18),

                      backgroundColor: theme.primaryColor,
                      foregroundColor: theme.colorScheme.onPrimary,
                      minimumSize: const Size.fromHeight(50),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}