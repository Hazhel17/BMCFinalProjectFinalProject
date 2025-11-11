import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting the date

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final User? _user = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // This function will mark all unread notifications as "read"
  void _markNotificationsAsRead(List<QueryDocumentSnapshot> docs) {
    // Use a "WriteBatch" to update multiple documents at once
    final batch = _firestore.batch();

    for (var doc in docs) {
      // Check if it's currently unread before adding to batch
      if (doc['isRead'] == false) {
        // If it's unread, add an "update" operation to the batch
        batch.update(doc.reference, {'isRead': true});
      }
    }

    // "Commit" the batch, sending all updates to Firestore
    if (docs.any((doc) => doc['isRead'] == false)) {
      batch.commit();
    }
  }

  // Function to delete a single notification
  void _deleteNotification(String notificationId) {
    _firestore
        .collection('notifications')
        .doc(notificationId)
        .delete()
        .catchError((e) {
      print('Error deleting notification: $e');
    });
  }

  // Stream function with the final fix for the abstract class error
  Stream<QuerySnapshot> _notificationsStream() {
    // Ensure _user is not null before accessing uid
    if (_user == null) {
      // FINAL FIX: Return a Stream that is immediately empty.
      // This correctly handles the "not logged in" scenario for a StreamBuilder.
      return const Stream.empty();
    }
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: _user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Move the logic to mark as read *after* the first frame is drawn
  @override
  void initState() {
    super.initState();
    if (_user != null) {
      // Use addPostFrameCallback to ensure the widget tree is built
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        // Fetch the data once to run the batch update
        final snapshot = await _notificationsStream().first;
        _markNotificationsAsRead(snapshot.docs);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: TextStyle(
            fontWeight: FontWeight.bold, // Make title bold
            color: theme.appBarTheme.foregroundColor,
          ),
        ),
      ),
      body: _user == null
          ? const Center(child: Text('Please log in.'))
          : StreamBuilder<QuerySnapshot>(
        // Get ALL notifications for this user, newest first
        stream: _notificationsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('You have no notifications.'));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final timestamp = (data['createdAt'] as Timestamp?);
              final formattedDate = timestamp != null
                  ? DateFormat('MM/dd/yy hh:mm a').format(timestamp.toDate())
                  : '';

              // Check if this notification was *just* read
              final bool wasUnread = data['isRead'] == false;

              return ListTile(
                // The tile color changes slightly if it was unread
                tileColor: wasUnread ? theme.colorScheme.secondary.withOpacity(0.05) : null,

                // Show a "new" icon if it was unread
                leading: wasUnread
                    ? Icon(Icons.circle, color: theme.colorScheme.primary, size: 12)
                    : const Icon(Icons.circle_outlined, color: Colors.grey, size: 12),

                title: Text(
                  data['title'] ?? 'No Title',
                  style: TextStyle(
                    fontWeight: wasUnread ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                subtitle: Text(
                  '${data['body'] ?? ""}\n$formattedDate',
                ),
                isThreeLine: true,

                // Delete button
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    _deleteNotification(doc.id);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}