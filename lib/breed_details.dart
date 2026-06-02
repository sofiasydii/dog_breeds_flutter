import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class BreedDetailsScreen extends StatefulWidget {
  final String breed;

  const BreedDetailsScreen({super.key, required this.breed});

  @override
  State<BreedDetailsScreen> createState() => _BreedDetailsScreenState();
}

class _BreedDetailsScreenState extends State<BreedDetailsScreen> {
  List<String> images = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchImages();
  }

  Future<void> fetchImages() async {
    final response = await http.get(
      Uri.parse('https://dog.ceo/api/breed/${widget.breed}/images'),
    );

    final data = jsonDecode(response.body);

    setState(() {
      images = List<String>.from(data['message']);
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.breed)),
      body: GridView.builder(
        itemCount: images.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
        ),
        itemBuilder: (context, index) {
          return Image.network(images[index]);
        },
      ),
    );
  }
}