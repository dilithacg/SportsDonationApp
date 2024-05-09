import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:location/location.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../constants/colors.dart';

class ItemData {
  final String itemName;
  final List<String> itemImages;
  final String uploadedTime;
  final String sportsCategory;
  final bool approved; // New field for approval status
  final GeoPoint? location; // Added field for location

  ItemData({
    required this.itemName,
    required this.itemImages,
    required this.uploadedTime,
    required this.sportsCategory,
    required this.location,
    this.approved = false, // Set the initial value to false
  });
}

class ItemDonate extends StatefulWidget {
  const ItemDonate({Key? key}) : super(key: key);

  @override
  _ItemDonateState createState() => _ItemDonateState();
}

class _ItemDonateState extends State<ItemDonate> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController contactNumberController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  int itemCount = 1; // Initial item count
  String? selectedDistrict;
  String? selectedSportsCategory;
  List<String> districts = [
    'Ampara',
    'Anuradhapura',
    'Badulla',
    'Batticaloa',
    'Colombo',
    'Galle',
    'Gampaha',
    'Hambantota',
    'Jaffna',
    'Kalutara',
    'Kandy',
    'Kegalle',
    'Kilinochchi',
    'Kurunegala',
    'Mannar',
    'Matale',
    'Matara',
    'Monaragala',
    'Mullaitivu',
    'Nuwara Eliya',
    'Polonnaruwa',
    'Puttalam',
    'Ratnapura',
    'Trincomalee',
    'Vavuniya',
  ];

  List<String> sportsCategories = [
    'Cricket',
    'Football',
    'Rugby',
    'Netball',
    'Volleyball',
    'Other',
  ];

  List<XFile> selectedImages = [];
  final ImagePicker _imagePicker = ImagePicker();

  bool _isLoading = false; // Added

  String? donatorName; // Store donator name
  String? donID;

  LocationData? _currentLocation; // Variable to store the current location
  GeoPoint? _selectedLocation; // Variable to store the selected location

  @override
  void initState() {
    super.initState();
    retrieveDonatorName();
    _getLocation();
  }

  Future<void> retrieveDonatorName() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      DocumentSnapshot userSnapshot =
      await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get();
      if (userSnapshot.exists) {
        setState(() {
          donatorName = userSnapshot['name'];
          donID = currentUser.uid;
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
    );

    if (image != null) {
      setState(() {
        if (selectedImages.length < 3) {
          selectedImages.add(image);
        } else {
          // Handle maximum image selection
        }
      });
    }
  }

  Future<void> _uploadDataToFirebase(ItemData itemData, int itemCount) async {
    setState(() {
      _isLoading = true; // Show loading indicator
    });

    try {
      CollectionReference itemsCollection =
      FirebaseFirestore.instance.collection('items');

      List<String> imageUrls = await _uploadImagesToStorage(selectedImages);

      await itemsCollection.add({
        'itemName': itemData.itemName,
        'itemImages': imageUrls,
        'uploadedTime': itemData.uploadedTime,
        'district': selectedDistrict,
        'sportsCategory': itemData.sportsCategory,
        'description': descriptionController.text,
        'contactNumber': contactNumberController.text,
        'approved': itemData.approved, // Include the 'approved' field
        'itemCount': itemCount, // Store the selected item count
        'donatorName': donatorName ?? 'Anonymous', // Include donator name
        'city': cityController.text,
        'location': itemData.location, // Store the location
        'donatorID': donID ?? '',
      });

      print('Data uploaded successfully!');
    } catch (e) {
      print('Error uploading data: $e');
    }

    setState(() {
      _isLoading = false; // Hide loading indicator
    });
  }

  Future<List<String>> _uploadImagesToStorage(List<XFile> images) async {
    List<String> imageUrls = [];

    for (XFile image in images) {
      try {
        String fileName = DateTime.now().millisecondsSinceEpoch.toString();
        Reference reference = FirebaseStorage.instance.ref().child('images/$fileName.jpg');
        await reference.putFile(File(image.path));
        String downloadURL = await reference.getDownloadURL();
        imageUrls.add(downloadURL);
      } catch (e) {
        print('Error uploading image: $e');
      }
    }

    return imageUrls;
  }

  Future<void> _getLocation() async {
    try {
      Location location = Location();

      bool _serviceEnabled;
      PermissionStatus _permissionGranted;

      _serviceEnabled = await location.serviceEnabled();
      if (!_serviceEnabled) {
        _serviceEnabled = await location.requestService();
        if (!_serviceEnabled) {
          return;
        }
      }

      _permissionGranted = await location.hasPermission();
      if (_permissionGranted == PermissionStatus.denied) {
        _permissionGranted = await location.requestPermission();
        if (_permissionGranted != PermissionStatus.granted) {
          return;
        }
      }

      _currentLocation = await location.getLocation();

      setState(() {
        _selectedLocation =
            GeoPoint(_currentLocation!.latitude!, _currentLocation!.longitude!);
      });
    } catch (e) {
      print("Error getting location: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColors.sPSecondaryColor,
        automaticallyImplyLeading: false,
        title: const Center(
          child: Text(
            'Donate item',
            style: TextStyle(
              color: Colors.black,
              fontSize: 22,
            ),
          ),
        ),
      ),
      body: _isLoading // Show loading indicator if uploading data
          ? Center(child: CircularProgressIndicator())
          : Container(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton(
                onPressed: _pickImage,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.black, // Text color
                ),
                child: const Text('Pick Image from Gallery',
                    style: TextStyle(color: Colors.white)),
                // Set text color explicitly
              ),

              if (selectedImages.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var image in selectedImages)
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Image.file(
                            File(image.path),
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                    ],
                  ),
                ),
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              if (_currentLocation != null)
                TextFormField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration:
                  const InputDecoration(labelText: 'Description'),
                ),
              SizedBox(height: 15),
              Row(
                children: [
                  Icon(Icons.location_on, color: Colors.red), // Location icon
                  SizedBox(width: 5), // Spacer between icon and text
                  GestureDetector(
                    onTap: () {
                      if (_currentLocation != null) {
                        // Null check added here
                        // Open Google Maps with the location coordinates
                        launch(
                            'https://www.google.com/maps/search/?api=1&query=${_currentLocation!.latitude},${_currentLocation!.longitude}');
                      }
                    },
                    child: Text(
                      _currentLocation != null
                          ? 'Current Location: ${_currentLocation!.latitude}, ${_currentLocation!.longitude}'
                          : 'Current Location: Unknown',
                      style: TextStyle(
                        decoration:
                        TextDecoration.underline, // Underline the text to indicate it's clickable
                      ),
                    ),
                  ),
                ],
              ),
              DropdownButtonFormField(
                value: selectedDistrict,
                items: districts.map((district) {
                  return DropdownMenuItem(
                    value: district,
                    child: Text(
                      district,
                      style: const TextStyle(),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedDistrict = value as String?;
                  });
                },
                decoration: const InputDecoration(labelText: 'District'),
              ),
              TextFormField(
                controller: cityController,
                keyboardType: TextInputType.streetAddress,
                decoration: const InputDecoration(labelText: 'City'),
              ),
              DropdownButtonFormField(
                value: selectedSportsCategory,
                items: sportsCategories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(
                      category,
                      style: const TextStyle(
                        // Change the text color here
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedSportsCategory = value as String?;
                  });
                },
                decoration: const InputDecoration(
                    labelText: 'Sports Category'),
              ),
              TextFormField(
                controller: contactNumberController,
                keyboardType: TextInputType.phone,
                decoration:
                const InputDecoration(labelText: 'Contact Number'),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {
                      if (itemCount > 1) {
                        setState(() {
                          itemCount--; // Decrease item count
                        });
                      }
                    },
                    icon: Icon(Icons.remove),
                  ),
                  Text(
                    '$itemCount', // Display current item count
                    style: TextStyle(fontSize: 20),
                  ),
                  IconButton(
                    onPressed: () {
                      if (itemCount < 50) {
                        setState(() {
                          itemCount++; // Increase item count
                        });
                      }
                    },
                    icon: Icon(Icons.add),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Center(
                child: Container(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: MyColors.sThColor,
                      padding: EdgeInsets.symmetric(
                          horizontal: 42,
                          vertical: 16), // Text color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () async {
                      if (selectedImages.isEmpty ||
                          selectedSportsCategory == null) {
                        // Show an error message for no selected images or sports category
                        return;
                      }

                      String title = titleController.text.trim();
                      if (title.isEmpty) {
                        // Show an error message for empty title
                        return;
                      }

                      try {
                        ItemData itemData = ItemData(
                          itemName: title,
                          itemImages: selectedImages
                              .map((image) => image.path)
                              .toList(),
                          uploadedTime: DateTime.now().toString(),
                          sportsCategory: selectedSportsCategory!,
                          location:
                          _selectedLocation, // Pass the current location
                        );

                        await _uploadDataToFirebase(
                            itemData, itemCount); // Pass itemCount to the method
                        // Optionally, reset form fields and selected images here

                        Navigator.pop(context, itemData);
                      } catch (e) {
                        // Handle other errors
                        print('Error: $e');
                      }
                    },
                    child: const Text(
                      'Submit',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
