import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import 'cart_screen.dart';
import 'admin_panel_screen.dart';
import '../models/product_model.dart';
import '../widgets/product_card.dart';
import '../screens/product_detail_screen.dart';
import 'order_history_screen.dart';
import 'package:my_ecommerce_app/screens/profile_screen.dart';
import 'package:my_ecommerce_app/widgets/notification_icon.dart';
import 'package:my_ecommerce_app/screens/chat_screen.dart';
import 'package:my_ecommerce_app/screens/admin_chat_list_screen.dart';
import 'package:my_ecommerce_app/screens/admin_order_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 1. STATE VARIABLES
  String _userRole = 'user';
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'Manga', 'Comics'];

  // 2. LIFECYCLE METHOD
  @override
  void initState() {
    super.initState();
    _fetchUserRole();
  }

  // 3. HELPER METHODS (Unchanged)
  Future<void> _fetchUserRole() async {
    if (_currentUser == null) return;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser.uid)
          .get();

      if (doc.exists && doc.data() != null) {
        setState(() {
          _userRole = doc.data()!['role'];
        });
      }
    } catch (e) {
      print("Error fetching user role: $e");
    }
  }

  Stream<QuerySnapshot> _getProductStream() {
    Query query = FirebaseFirestore.instance.collection('products');

    if (_selectedCategory == 'Manga') {
      query = query.where('format', isEqualTo: 'Manga');
    } else if (_selectedCategory == 'Comics') {
      query = query.where('format', isEqualTo: 'Comics');
    }

    return query.snapshots();
  }

  Widget _buildCategoryButton(String category) {
    final isSelected = _selectedCategory == category;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ChoiceChip(
        label: Text(category),
        selected: isSelected,
        selectedColor: theme.primaryColor,
        labelStyle: TextStyle(
          color: isSelected
              ? theme.colorScheme.onPrimary
              : theme.colorScheme.onSurface,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        onSelected: (selected) {
          if (selected) {
            setState(() {
              _selectedCategory = category;
            });
          }
        },
      ),
    );
  }

  // 4. BUILD METHOD (Updated)
  @override
  Widget build(BuildContext context) {
    // 1. EXTRACT ACTIONS TO A WIDGET FOR RE-USE
    final List<Widget> actionIcons = [
      // Notifications are for everyone
      const NotificationIcon(),

      // --- ADMIN ACTIONS: ONLY FOR ADMINS ---
      if (_userRole == 'admin') ...[
        IconButton(
          icon: const Icon(Icons.list_alt),
          tooltip: 'Manage Orders',
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const AdminOrderScreen()),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.chat_bubble_outline),
          tooltip: 'User Chats',
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const AdminChatListScreen(),
              ),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.admin_panel_settings),
          tooltip: 'Admin Panel',
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const AdminPanelScreen()),
            );
          },
        ),
      ],

      // --- USER ACTIONS: ONLY FOR USERS ---
      if (_userRole == 'user') ...[
        // Cart Icon
        Consumer<CartProvider>(
          builder: (context, cart, child) {
            return Badge(
              label: Text(cart.itemCount.toString()),
              isLabelVisible: cart.itemCount > 0,
              child: IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const CartScreen()),
                  );
                  setState(() {});
                },
              ),
            );
          },
        ),
        // My Orders Icon
        IconButton(
          icon: const Icon(Icons.receipt_long),
          tooltip: 'My Orders',
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const OrderHistoryScreen(),
              ),
            );
          },
        ),
      ],

      // Profile Icon (For both user and admin)
      IconButton(
        icon: const Icon(Icons.person_outline),
        tooltip: 'Profile',
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const ProfileScreen()),
          );
        },
      ),
    ];

    // 2. CONVERT TO NESTEDSCROLLVIEW STRUCTURE FOR COLLAPSING BEHAVIOR
    return Scaffold(
      // The body now uses CustomScrollView for the collapsing effect
      body: CustomScrollView(
        slivers: [
          // 1. SLIVER APP BAR (Handles the collapsing header, logo, and icons)
          SliverAppBar(
            // Use 'pinned: true' so the Actions (icons) and Title stay visible
            pinned: true,
            // Use 'floating: true' so the App Bar reappears immediately when scrolling down
            floating: true,
            // 'snap: true' works best with 'floating: true'
            snap: true,
            // Expanded height for the logo and the filter bar
            expandedHeight: 120.0,
            automaticallyImplyLeading:
                false, // Don't show back arrow by default
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,

            // FlexibleSpace makes the App Bar expand/collapse
            flexibleSpace: FlexibleSpaceBar(
              // The Title row (Logo + Filter Chips) now moves with the scroll
              title: Padding(
                padding: const EdgeInsets.only(
                  bottom: 50.0,
                ), // Raise title a bit
                child: Row(
                  children: [
                    // 1. LOGO (Left Side)
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Image.asset(
                        'assets/images/splash_logo.png',
                        height: 30, // Smaller size when collapsed
                      ),
                    ),
                    const SizedBox(width: 10),

                    // 2. Filter Chips (Will be slightly obscured when fully collapsed)
                    // We move the chips to the bottom property for better control
                  ],
                ),
              ),
              centerTitle: false,
              titlePadding: EdgeInsets.zero,
            ),

            // Actions (Icons on the right)
            actions: actionIcons,

            // BOTTOM: This is where we place the Filter Bar to make it stick just below the header
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(50.0),
              child: Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                padding: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 8.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _categories.map((category) {
                    return _buildCategoryButton(category);
                  }).toList(),
                ),
              ),
            ),
          ),

          // 2. SLIVER GRID (The product list, replaces the GridView.builder inside Expanded)
          StreamBuilder<QuerySnapshot>(
            stream: _getProductStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // If loading, show a centered progress indicator within a Sliver
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError) {
                return SliverFillRemaining(
                  child: Center(child: Text('Error: ${snapshot.error}')),
                );
              }
              final documents = snapshot.data!.docs;
              if (documents.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Text(
                      'No $_selectedCategory products found.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }
              return SliverGrid(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final productDoc = documents[index];
                  final productData = productDoc.data() as Map<String, dynamic>;
                  final product = Product.fromMap(productData, productDoc.id);

                  return ProductCard(
                    name: product.name,
                    price: product.price,
                    imageUrl: product.imageUrl,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              ProductDetailScreen(product: product),
                        ),
                      );
                    },
                  );
                }, childCount: documents.length),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  // *** CHANGE 3 COLUMNS TO 2 COLUMNS (User Request) ***
                  crossAxisCount: 2,
                  crossAxisSpacing: 10, // Increased spacing for better look
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.55, // Adjusted for 2 columns
                ),
              );
            },
          ),
        ],
      ),
      // --- FAB (Floating Action Button): ONLY FOR USERS (Unchanged) ---
      floatingActionButton: _userRole == 'user'
          ? StreamBuilder<DocumentSnapshot>(
              stream: _firestore
                  .collection('chats')
                  .doc(_currentUser!.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                int unreadCount = 0;
                if (snapshot.hasData && snapshot.data!.exists) {
                  final data = snapshot.data!.data();
                  if (data != null) {
                    unreadCount =
                        (data as Map<String, dynamic>)['unreadByUserCount'] ??
                        0;
                  }
                }
                return Badge(
                  label: Text('$unreadCount'),
                  isLabelVisible: unreadCount > 0,
                  child: FloatingActionButton.extended(
                    icon: const Icon(Icons.support_agent),
                    label: const Text('Contact Admin'),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              ChatScreen(chatRoomId: _currentUser!.uid),
                        ),
                      );
                    },
                  ),
                );
              },
            )
          : null,
    );
  }
}
