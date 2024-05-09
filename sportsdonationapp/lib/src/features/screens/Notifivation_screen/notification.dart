import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../../../constants/colors.dart';

class NotificationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColors.sPSecondaryColor,
        automaticallyImplyLeading: false,
        title: const Center(
          child: Text(
            'Notifications',
            style: TextStyle(
              color: Colors.black,
              fontSize: 22,
            ),
          ),
        ),
      ),
      body: UserNotifications(),
    );
  }
}

class UserNotifications extends StatefulWidget {
  @override
  _UserNotificationsState createState() => _UserNotificationsState();
}

class _UserNotificationsState extends State<UserNotifications> {
  late User? _user;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('notifications')
          .where('userId', isEqualTo: _user!.uid)
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var notification = snapshot.data!.docs[index];
              return NotificationTile(
                title: notification['title'],
                body: notification['body'],
                timestamp: notification['timestamp'],
              );
            },
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}

class NotificationTile extends StatelessWidget {
  final String title;
  final String body;
  final Timestamp timestamp;

  const NotificationTile({
    required this.title,
    required this.body,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    DateTime dateTime = timestamp.toDate();
    String formattedDateTime =
    DateFormat.yMMMd().add_jm().format(dateTime); // Format: May 9, 2024 6:09 PM

    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(body),
            SizedBox(height: 4),
            Text(
              formattedDateTime,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        onTap: () {
          // Add action when tapped
        },
      ),
    );
  }
}
