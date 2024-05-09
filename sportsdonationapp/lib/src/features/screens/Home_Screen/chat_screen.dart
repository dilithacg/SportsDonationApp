import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:sportsdonationapp/src/features/screens/Home_Screen/chat_messages.dart';
import 'package:sportsdonationapp/src/features/screens/Home_Screen/new_messages.dart';

import '../../../constants/colors.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  void setupPushNotifications() async {
  final fcm = FirebaseMessaging.instance;

  await fcm.requestPermission();
  fcm.subscribeToTopic('chat');

 }

  @override
  void initState() {
    super.initState();

    setupPushNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: MyColors.sPSecondaryColor,
          automaticallyImplyLeading: false,
          title: const Center(
            child: Text(
              'Chat',
              style: TextStyle(
                color: Colors.black,
                fontSize: 22,
              ),
            ),
          ),
        ),
      body: Column(children: const [
        Expanded(child: ChatMessages(),
        ),
        NewMessage(),
      ],)
    );
  }
}

