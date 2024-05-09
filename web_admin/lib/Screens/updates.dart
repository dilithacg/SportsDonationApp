import 'dart:html';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ImageUploader extends StatefulWidget {
  @override
  _ImageUploaderState createState() => _ImageUploaderState();
}

class _ImageUploaderState extends State<ImageUploader> {
  List<Uint8List> _images = [];
  List<String> _imageUrls = [];

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
      await FirebaseStorage.instance.refFromURL(_imageUrls[index]).delete();
      setState(() {
        _images.removeAt(index);
        _imageUrls.removeAt(index);
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Image deleted successfully')));
    } catch (error) {
      print('Error deleting image: $error');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting image')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Image Uploader')),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: _pickImage,
            child: Text('Pick Image'),
          ),
          ElevatedButton(
            onPressed: _uploadImages,
            child: Text('Upload Images'),
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4.0,
                mainAxisSpacing: 4.0,
              ),
              itemCount: _images.length,
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    Image.memory(
                      _images[index],
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _deleteImage(index),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
