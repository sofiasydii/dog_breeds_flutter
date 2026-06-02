import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'breed_details.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox('dogs');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dog Breeds',
      theme: ThemeData(
        colorSchemeSeed: Colors.orange,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> breeds = [];
  bool isLoading = true;
  String error = '';

  @override
  void initState() {
    super.initState();
    fetchBreeds();
  }

  Future<void> fetchBreeds() async {
    final box = Hive.box('dogs');

    try {
      final response = await http.get(
        Uri.parse('https://dog.ceo/api/breeds/list/all'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        breeds = (data['message'] as Map<String, dynamic>)
            .keys
            .toList();

        await box.put('breeds', breeds);

        setState(() {
          isLoading = false;
        });
      } else {
        throw Exception();
      }
    } catch (e) {
      final saved = box.get('breeds');

      if (saved != null) {
        breeds = List<String>.from(saved);

        setState(() {
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tryb offline - wyświetlam zapisane dane'),
          ),
        );
      } else {
        setState(() {
          error = 'Nie udało się pobrać danych';
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
        appBar: AppBar(title: const Text('Dog Breeds')),
        body: Center(child: Text(error)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dog Breeds'),
      ),
      body: ListView.builder(
        itemCount: breeds.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.pets),
            title: Text(
              breeds[index].toUpperCase(),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BreedDetailsScreen(
                    breed: breeds[index],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}