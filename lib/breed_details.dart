import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;

class BreedDetailsScreen extends StatefulWidget {
  final String breed;

  const BreedDetailsScreen({
    super.key,
    required this.breed,
  });

  @override
  State<BreedDetailsScreen> createState() =>
      _BreedDetailsScreenState();
}

class _BreedDetailsScreenState
    extends State<BreedDetailsScreen> {
  List<String> images = [];
  bool isLoading = true;
  String error = '';

  @override
  void initState() {
    super.initState();
    fetchImages();
  }

  Future<void> fetchImages() async {
    final box = Hive.box('dogs');

    try {
      final response = await http.get(
        Uri.parse(
          'https://dog.ceo/api/breed/${widget.breed}/images',
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        images = List<String>.from(data['message']);

        await box.put(widget.breed, images);

        setState(() {
          isLoading = false;
        });
      } else {
        throw Exception();
      }
    } catch (e) {
      final saved = box.get(widget.breed);

      if (saved != null) {
        images = List<String>.from(saved);

        setState(() {
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Brak zdjęć';
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (error.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.breed),
        ),
        body: Center(
          child: Text(error),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.breed.toUpperCase()),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: images.length > 20 ? 20 : images.length,
        gridDelegate:
        const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemBuilder: (context, index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              images[index],
              fit: BoxFit.cover,
            ),
          );
        },
      ),
    );
  }
}