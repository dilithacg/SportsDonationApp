import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsPopup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'call',
          child: ListTile(
            leading: Icon(Icons.phone),
            title: Text('Call Us'),
            onTap: () async {
              final url = 'tel:+1234567890'; // Replace with your phone number
              if (await canLaunch(url)) {
                await launch(url);
              } else {
                throw 'Could not launch $url';
              }
            },
          ),
        ),
        PopupMenuItem(
          value: 'whatsapp',
          child: ListTile(
            leading: Icon(Icons.message),
            title: Text('WhatsApp Us'),
            onTap: () async {
              final url = 'https://wa.me/1234567890'; // Replace with your WhatsApp number
              if (await canLaunch(url)) {
                await launch(url);
              } else {
                throw 'Could not launch $url';
              }
            },
          ),
        ),
      ],
      child: Container(
        margin: const EdgeInsets.only(top: 1),
        height: 60,
        width: 60,
        child: FloatingActionButton(
          onPressed: () {},
          elevation: 0,
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 3, color: Colors.white38),
            borderRadius: BorderRadius.circular(100),
          ),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
