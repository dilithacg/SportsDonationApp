import 'dart:typed_data'; // Import for handling image bytes
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore library
import 'package:firebase_storage/firebase_storage.dart'; // Firebase Storage library
import 'package:flutter/material.dart'; // Flutter Material library
import 'package:image_picker/image_picker.dart'; // Image Picker library

class AddTextToFirestore extends StatefulWidget {
  @override
  _AddTextToFirestoreState createState() => _AddTextToFirestoreState();
}

class _AddTextToFirestoreState extends State<AddTextToFirestore> {
  // Controllers for text fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _sportController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _detailController = TextEditingController();

  Uint8List? _imageBytes; // Holds the bytes of the selected image

  // Function to pick an image from the device's gallery
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      final imageBytes = await pickedImage.readAsBytes();
      setState(() {
        _imageBytes = imageBytes;
      });
    } else {
      print('No image selected.');
    }
  }

  // Function to add text and image to Firestore
  Future<void> _addTextAndImageToFirestore(String name, String sport, String district, String city, String phoneNumber, String price, String detail) async {
    try {
      if (_imageBytes != null) {
        // Upload image to Firebase Storage
        final Reference ref = FirebaseStorage.instance.ref().child('coaches_images/${DateTime.now()}.jpg');
        await ref.putData(_imageBytes!);
        final imageUrl = await ref.getDownloadURL();

        // Add data to Firestore
        await FirebaseFirestore.instance.collection('coaches').add({
          'name': name,
          'sport': sport,
          'district': district,
          'city': city,
          'phone_number': phoneNumber,
          'price': price,
          'detail': detail,
          'image_url': imageUrl,
          'timestamp': DateTime.now(),
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Data added to Firestore')));

        // Clear text fields and reset image selection
        _nameController.clear();
        _sportController.clear();
        _districtController.clear();
        _cityController.clear();
        _phoneNumberController.clear();
        _priceController.clear();
        _detailController.clear();
        setState(() {
          _imageBytes = null;
        });
      } else {
        print('Please select an image.');
      }
    } catch (error) {
      // Handle errors
      print('Error adding data to Firestore: $error');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error adding data to Firestore')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Data to Firestore'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display selected image if available
              if (_imageBytes != null) Image.memory(_imageBytes!),
              // Button to select image
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('Select Image'),
              ),
              // Text fields for entering coach details
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                ),
              ),
              TextField(
                controller: _sportController,
                decoration: InputDecoration(
                  labelText: 'Sport',
                ),
              ),
              TextField(
                controller: _districtController,
                decoration: InputDecoration(
                  labelText: 'District',
                ),
              ),
              TextField(
                controller: _cityController,
                decoration: InputDecoration(
                  labelText: 'City',
                ),
              ),
              TextField(
                controller: _phoneNumberController,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                ),
              ),
              TextField(
                controller: _detailController,
                decoration: InputDecoration(
                  labelText: 'Detail',
                ),
              ),
              TextField(
                controller: _priceController,
                decoration: InputDecoration(
                  labelText: 'Price',
                ),
              ),
              SizedBox(height: 20.0),
              // Button to add data to Firestore
              ElevatedButton(
                onPressed: () {
                  String name = _nameController.text;
                  String sport = _sportController.text;
                  String district = _districtController.text;
                  String city = _cityController.text;
                  String phoneNumber = _phoneNumberController.text;
                  String price = _priceController.text;
                  String detail = _detailController.text;
                  _addTextAndImageToFirestore(name, sport, district, city, phoneNumber, price, detail);
                },
                child: Text('Add Data to Firestore'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
