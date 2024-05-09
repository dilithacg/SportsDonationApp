import 'package:flutter/material.dart';

class Category {
  const Category({
    required this.id,
    required this.title,
    this.color = Colors.orange,
  });

  final String id;
  final String title;
  final Color color;
}
class ButtonImg{
  static const List<String> items = [
    'assets/images/b1.jpg',
    'assets/images/b2.jpg',
    'assets/images/b3.png',
    'assets/images/b4.jpg',


    // Add more image paths as needed
  ];
}

class CarouselItems {
  static const List<String> items = [
    'assets/images/carousel_image1.jpg',
    'assets/images/carousel_image2.jpg',
    'assets/images/carousel_image3.jpg',
    // Add more image paths as needed
  ];
}