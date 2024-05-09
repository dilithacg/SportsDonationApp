import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:sportsdonationapp/src/features/screens/Home_Screen/setting.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:carousel_slider/carousel_slider.dart';

import '../../../constants/colors.dart';

import '../Notifivation_screen/notification.dart';
import 'Category.dart';
import 'category_grid_item.dart';
import 'categorydata.dart';
import 'chat_screen.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({Key? key}) : super(key: key);

  @override
  _CategoriesScreenState createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _selectedIndex == 0 ? AppBar(
        title: const Center(
          child: Text(
            'Pick your category',
            style: TextStyle(
              color: Colors.black,
              fontSize: 22,
            ),
          ),
        ),
        backgroundColor: MyColors.sPSecondaryColor,
        automaticallyImplyLeading: false,
      ) : null,
      body: _buildCurrentScreen(),
      floatingActionButton: _selectedIndex == 0 ? FloatingActionButton(
        onPressed: () {
          // Show popup menu
          showContactPopupMenu(context);
        },
        backgroundColor: MyColors.sForColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
        ),
        child: Image.asset(
          'assets/Icons/customer-service.png',
          width: 40,
          height: 40,
        ),
      ) : null,
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildCurrentScreen() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeScreen();
      case 1:
        return ChatScreen();
      case 2:
        return NotificationScreen();
      case 3:
        return SettingsScreen();
      default:
        return Container(); // Placeholder, replace with your default screen
    }
  }

  Widget _buildHomeScreen() {
    return ListView(
      children: [
        SizedBox(height: 20),
        CarouselSlider(
          items: CarouselItems.items.map((imagePath) {
            return Container(
              margin: EdgeInsets.symmetric(horizontal: 5.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                ),
              ),
            );
          }).toList(),
          options: CarouselOptions(
            height: 200.0,
            autoPlay: true,
            enlargeCenterPage: true,
            aspectRatio: 16 / 9,
            autoPlayCurve: Curves.fastOutSlowIn,
            enableInfiniteScroll: true,
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            viewportFraction: 0.8,

          ),
        ),
        const SizedBox(height: 15),
        GridView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1,
            childAspectRatio: 2 / 0.8,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
          ),
          children: [
            for (final category in availableCategories)
              CategoryGridItem(category: category)
          ],
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
          // Adjust these values according to your needs
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20),
        child: GNav(
          gap: 8,
          backgroundColor: Colors.black,
          color: MyColors.foColor,
          activeColor: MyColors.sThColor,
          tabBackgroundColor: Colors.grey.shade800,
          padding: EdgeInsets.all(16),
          tabs: [
            GButton(icon: Icons.home, text: 'Home'),
            GButton(icon: Icons.chat, text: 'Chat'),
            GButton(icon: Icons.notifications, text: 'Notifications'),
            GButton(icon: Icons.settings, text: 'Settings'),
          ],
          selectedIndex: _selectedIndex,
          onTabChange: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
      ),
    );
  }

  void showContactPopupMenu(BuildContext context) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        MediaQuery.of(context).size.width / 2,
        MediaQuery.of(context).size.height / 1.32 - 80, // Adjust this value as needed
        80,
        05,
      ),
      items: [
        PopupMenuItem(
          value: 'call',
          child: ListTile(
            leading: Icon(Icons.phone, color: Colors.green),
            title: Text('Call Us'),
            onTap: () async {
              final url = 'tel:+1234567890';
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
            leading: Image.asset(
              'assets/Icons/wapp.png',
              width: 30,
              height: 30,
            ),
            title: Text('WhatsApp'),
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
      elevation: 8.0,
    );
  }
}
