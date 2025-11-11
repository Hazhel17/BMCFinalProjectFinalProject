import 'package:my_ecommerce_app/providers/cart_provider.dart';
import 'package:my_ecommerce_app/screens/payment_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// 2. It's a Stateless Widget again!
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 3. We listen: true, so the list and total update
    final cart = Provider.of<CartProvider>(context);
    final theme = Theme.of(context); // Get theme for text color consistency

    return Scaffold(
      appBar: AppBar(
        // FIX: Remove the erroneous 'style' parameter and bold the title text
        title: Text(
          'Your Cart',
          style: TextStyle(
            fontWeight: FontWeight.bold, // **Bold the title**
            // Ensure the text color uses the AppBar's foregroundColor (kRichBlack)
            color: theme.appBarTheme.foregroundColor,
          ),
        ),
      ),
      body: Column(
        children: [
          // 4. The ListView is the same as before
          Expanded(
            child: cart.items.isEmpty
                ? const Center(child: Text('Your cart is empty.'))
                : ListView.builder(
              itemCount: cart.items.length,
              itemBuilder: (context, index) {
                final cartItem = cart.items[index];
                return ListTile(
                  leading: CircleAvatar(
                    // Set circle avatar background color to primary color
                    backgroundColor: theme.colorScheme.primary,
                    // Set text color to contrast primary color
                    foregroundColor: theme.colorScheme.onPrimary,
                    child: Text(cartItem.title[0]),
                  ),
                  title: Text(cartItem.title),
                  subtitle: Text('Qty: ${cartItem.quantity}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                          '₱${(cartItem.price * cartItem.quantity).toStringAsFixed(2)}'),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          cart.removeItem(cartItem.id);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          // 5. --- PRICE BREAKDOWN CARD (from Module 15) ---
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Subtotal:', style: TextStyle(fontSize: 16)),
                      Text('₱${cart.subtotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('VAT (12%):', style: TextStyle(fontSize: 16)),
                      Text('₱${cart.vat.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                  const Divider(height: 20, thickness: 1),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      Text(
                        '₱${cart.totalPriceWithVat.toStringAsFixed(2)}',
                        style: TextStyle( // Use dynamic theme color for highlight
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary), // Use your theme's primary color (Dark Green)
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // 6. --- THIS IS THE MODIFIED BUTTON
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              // 7. Disable if cart is empty, otherwise navigate
              onPressed: cart.items.isEmpty
                  ? null
                  : () {
                // 8. Navigate to our new PaymentScreen
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => PaymentScreen(
                      // 9. Pass the final VAT-inclusive total
                      totalAmount: cart.totalPriceWithVat,
                    ),
                  ),
                );
              },
              // 10. No more spinner!
              child: const Text('Proceed to Payment'),
            ),
          ),
        ],
      ),
    );
  }
}