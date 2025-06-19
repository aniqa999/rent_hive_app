import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
//import 'package:carousel_slider/carousel_slider.dart';
//import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../models/Products.dart';
import '../../models/Category.dart';
import '../../Components/CategoryChip.dart';
import '../../Components/ProductCard.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(),
        primaryColor: Colors.deepPurple,
      ),
      home: ProductsPage(),
    );
  }
}

class ProductsPage extends StatelessWidget {
  final List<Product> products = [
    Product(
      imageURL: "https://images.unsplash.com/photo-1546069901-ba9599a7e63c",
      price: 29.99,
      title: "Delicious Meal",
      description: "Beautifully prepared healthy meal",
      category: "Food",
      createdAt: DateTime.now(),
    ),
    Product(
      imageURL: "https://images.unsplash.com/photo-1555939594-58d7cb561ad1",
      price: 19.99,
      title: "Grilled Steak",
      description: "Juicy grilled steak with herbs",
      category: "Food",
      createdAt: DateTime.now(),
    ),
    Product(
      imageURL: "https://images.unsplash.com/photo-1565299624946-b28f40a0ae38",
      price: 15.50,
      title: "Pizza Margherita",
      description: "Classic Italian pizza",
      category: "Food",
      createdAt: DateTime.now(),
    ),
    Product(
      imageURL: "https://images.unsplash.com/photo-1565958011703-44f9829ba187",
      price: 12.75,
      title: "Fresh Salad",
      description: "Healthy salad with avocado",
      category: "Food",
      createdAt: DateTime.now(),
    ),
  ];

  final List<Category> categories = [
    Category(name: "Sports", iconURL: "assets/sports.png"),
    Category(name: "Vehicles", iconURL: "assets/vehicles.png"),
    Category(name: "Properties", iconURL: "assets/properties.png"),
    Category(name: "Camera", iconURL: "assets/camera.png"),
    Category(name: "Laptops", iconURL: "assets/laptops.png"),
  ];

  ProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF3F4F6),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Search here...',
                prefixIcon: Icon(Icons.search, color: Colors.deepPurple),
                suffixIcon: Icon(Icons.camera_alt, color: Colors.deepPurple),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Categories',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                spacing: 20.0,
                children: [
                  for (int i = 0; i < categories.length; i++)
                    CategoryChip(cat: categories[i]),
                ],
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Best Selling',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.7,
                ),
                itemCount: products.length,
                itemBuilder:
                    (context, index) => ProductCard(product: products[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
