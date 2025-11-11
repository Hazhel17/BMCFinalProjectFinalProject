import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_ecommerce_app/widgets/order_card.dart'; // 1. Import our new card [cite: 89]

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 2. Get the current user [cite: 94, 149]
    final User? user = FirebaseAuth.instance.currentUser; //[cite: 95]

    return Scaffold(
        appBar: AppBar(
            title: const Text('My Orders'), //[cite: 99]
        ),
        // 3. Check if the user is logged in [cite: 100, 150-152]
        body: user == null
            ? const Center(
            child: Text('Please log in to see your orders.'), //[cite: 104]
        )
        // 4. If logged in, show the StreamBuilder [cite: 105, 153-154]
            : StreamBuilder<QuerySnapshot>(
          // 5. THIS IS THE CRITICAL NEW QUERY [cite: 107-108, 155]
            stream: FirebaseFirestore.instance
                .collection('orders') //[cite: 109-110]
        // 6. Filter the 'orders' collection by userId [cite: 111-112, 156-157]
            .where('userId', isEqualTo: user.uid) //[cite: 112]
        // 7. Sort by date, newest first [cite: 113-114, 158]
        .orderBy('createdAt', descending: true) //[cite: 114]
        .snapshots(), //[cite: 115]

    builder: (context, snapshot) {
    // 8. Handle loading state [cite: 117-118, 159]
    if (snapshot.connectionState == ConnectionState.waiting) { //[cite: 118]
    return const Center(child: CircularProgressIndicator()); //[cite: 120]
    }

    // 9. Handle error state [cite: 121, 126-127, 159]
    if (snapshot.hasError) { //[cite: 126]
    // Ito ang code na nagpapakita ng error na nakita mo sa screenshot
    return Center(child: Text('Error: \${snapshot.error}')); //[cite: 127]
    }

    // 10. Handle no data (no orders) [cite: 128-129, 159]
    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) { //[cite: 129]
    return const Center(
    child: Text('You have not placed any orders yet.'), //[cite: 130]
    );
    }

    // 11. We have data! Get the list of order documents [cite: 133-134]
    final orderDocs = snapshot.data!.docs; //[cite: 134]

    // 12. Use ListView.builder to show the list [cite: 135]
    return ListView.builder( //[cite: 136]
    itemCount: orderDocs.length, //[cite: 137]
    itemBuilder: (context, index) { //[cite: 138]
    // 13. Get the data for a single order [cite: 139-140]
    final orderData = orderDocs[index].data() as Map<String, dynamic>; //[cite: 140]
    // 14. Return our custom OrderCard widget [cite: 141-142, 160]
    return OrderCard(orderData: orderData); //[cite: 142]
    },
    );
    },
    ),
    );
  }
}