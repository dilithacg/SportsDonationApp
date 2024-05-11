import 'dart:html';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'colors.dart';

class ImageUploader extends StatefulWidget {
  @override
  _ImageUploaderState createState() => _ImageUploaderState();
}

class _ImageUploaderState extends State<ImageUploader> {
  List<Uint8List> _images = [];
  List<String> _imageUrls = [];

  @override
  void initState() {
    super.initState();
    _fetchImages();
  }

  Future<void> _fetchImages() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance.collection('carousel_images').get();
      for (final doc in querySnapshot.docs) {
        final url = doc['url'] as String;
        setState(() {
          _imageUrls.add(url);
        });
      }
    } catch (error) {
      print('Error fetching images: $error');
    }
  }

  void _pickImage() {
    FileUploadInputElement uploadInput = FileUploadInputElement();
    uploadInput.click();

    uploadInput.onChange.listen((event) {
      final files = uploadInput.files;
      if (files != null && files.isNotEmpty) {
        final file = files[0];
        final reader = FileReader();

        reader.onLoadEnd.listen((event) {
          final imageData = reader.result as Uint8List;
          setState(() {
            _images.add(imageData);
          });
        });

        reader.readAsArrayBuffer(file);
      }
    });
  }

  Future<void> _uploadImages() async {
    try {
      for (final image in _images) {
        final Reference ref = FirebaseStorage.instance.ref().child('carousel_images/${DateTime.now()}.jpg');
        await ref.putData(image);
        final String downloadURL = await ref.getDownloadURL();
        setState(() {
          _imageUrls.add(downloadURL);
        });
        await FirebaseFirestore.instance.collection('carousel_images').add({'url': downloadURL});
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Images uploaded successfully')));
    } catch (error) {
      print('Error uploading images: $error');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error uploading images')));
    }
  }

  Future<void> _deleteImage(int index) async {
    try {
      // Delete the image URL from Firestore
      await FirebaseFirestore.instance.collection('carousel_images').where('url', isEqualTo: _imageUrls[index]).get().then((snapshot) {
        snapshot.docs.first.reference.delete();
      });

      // Delete the image from Firebase Storage
      await FirebaseStorage.instance.refFromURL(_imageUrls[index]).delete();

      // Update the UI
      setState(() {
        _images.removeAt(index);
        _imageUrls.removeAt(index);
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Image deleted successfully')));
    } catch (error) {

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Sports Updates'),
        backgroundColor: Colors.black,),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: MyColors.sThColor,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: ElevatedButton(
                onPressed: _pickImage,
                child: Text('Select Images'),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
                ),
              ),
            ),
            SizedBox(height: 16.0),
            Container(
              decoration: BoxDecoration(
                color: MyColors.sThColor,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: ElevatedButton(
                onPressed: _uploadImages,
                child: Text('Upload Images'),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
                ),
              ),
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: _imageUrls.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      leading: Image.network(
                        _imageUrls[index],
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _deleteImage(index),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
