import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/Order.dart' as model;
import '../../services/cart_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  final CartService _cartService = CartService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  bool _loading = false;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _initializeFirebaseAndLoadUserData();
    _initializeStripe();
  }

  Future<void> _initializeStripe() async {
    await dotenv.load(fileName: ".env");
    Stripe.publishableKey = dotenv.env['STRIPE_PUBLISH_KEY'] ?? '';
    await Stripe.instance.applySettings();
  }

  Future<void> _initializeFirebaseAndLoadUserData() async {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        FirebaseAuth.instance.signInAnonymously().then((credential) {
          setState(() {
            _currentUser = credential.user;
          });
        });
      } else {
        setState(() {
          _currentUser = user;
        });
        _loadUserData();
      }
    });
  }

  Future<void> _loadUserData() async {
    if (_currentUser == null) return;

    setState(() {
      _loading = true;
    });

    try {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(_currentUser!.uid)
              .get();

      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        _nameController.text = userData['name'] ?? '';
        _emailController.text = userData['email'] ?? '';
        _addressController.text = userData['address'] ?? '';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load user data: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<Map<String, dynamic>> _createPaymentIntent(
    String amount,
    String currency,
    String email,
    String name,
    String address,
    String productName,
  ) async {
    try {
      final int amountInCents = (double.parse(amount) * 100).toInt();

      Map<String, dynamic> body = {
        'amount': amountInCents.toString(),
        'currency': currency,
        'payment_method_types[]': 'card',
        'receipt_email': email,
        'metadata[name]': name,
        'metadata[email]': email,
        'metadata[address]': address,
        'metadata[product]': productName,
      };

      final response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer ${dotenv.env['STRIPE_KEY']}',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
          'Failed to create Payment Intent: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (err) {
      throw Exception('Error creating Payment Intent: ${err.toString()}');
    }
  }

  Future<void> _processPayment(model.Order order) async {
    if (_currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to make a payment.')),
      );
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      if (Stripe.publishableKey.isEmpty) {
        await _initializeStripe();
      }
      final paymentIntentData = await _createPaymentIntent(
        order.productPrice.toString(),
        'USD',
        _emailController.text,
        _nameController.text,
        _addressController.text,
        order.productTitle,
      );

      if (paymentIntentData['client_secret'] == null) {
        throw Exception('Did not receive client_secret from Payment Intent.');
      }

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntentData['client_secret'],
          merchantDisplayName: 'RentHive',
          style: ThemeMode.light,
          customerEphemeralKeySecret: paymentIntentData['ephemeralKey'],
          customerId: paymentIntentData['customer'],
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      await FirebaseFirestore.instance
          .collection('orders')
          .doc(order.id)
          .update({'status': 'paid'});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment Successful! Order Confirmed.')),
        );
      }
    } on StripeException catch (e) {
      String message =
          'Payment failed: ${e.error.localizedMessage ?? e.error.message ?? 'Unknown Stripe error'}';
      if (e.error.code == "Canceled") {
        message = "Payment cancelled by user.";
      }
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (e) {
      if (mounted) {
        print(e.toString());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An unexpected error occurred: ${e.toString()}'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  void _showPaymentDialog(model.Order order) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Complete Payment'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Product: ${order.productTitle}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Amount: Rs. ${order.productPrice.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: _nameController,
                    labelText: 'Full Name',
                    icon: Icons.person,
                  ),
                  const SizedBox(height: 10),
                  _buildTextField(
                    controller: _emailController,
                    labelText: 'Email Address',
                    icon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 10),
                  _buildTextField(
                    controller: _addressController,
                    labelText: 'Shipping Address',
                    icon: Icons.location_on,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loading ? null : () => _processPayment(order),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.deepPurple,
                      ),
                      child:
                          _loading
                              ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                              : const Text('Pay Now'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Secure payment processed by Stripe',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Map<String, List<model.Order>> _groupOrdersByStatus(
    List<model.Order> orders,
  ) {
    final map = <String, List<model.Order>>{};
    for (final order in orders) {
      (map[order.status] ??= []).add(order);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        title: Text(
          'My Orders',
          style: GoogleFonts.roboto(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          StreamBuilder<int>(
            stream: _cartService.getCartCount(),
            builder: (context, snapshot) {
              final count = snapshot.data ?? 0;
              return Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  count.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : StreamBuilder<List<model.Order>>(
                stream: _cartService.getAllUserOrders(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  final cartItems = snapshot.data ?? [];

                  if (cartItems.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shopping_cart_outlined,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Your cart is empty',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add some products to get started!',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final groupedOrders = _groupOrdersByStatus(cartItems);
                  final statusOrder = [
                    'pending',
                    'approved',
                    'paid',
                    'rejected',
                    'returned',
                  ];

                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children:
                        statusOrder.map((status) {
                          final orders = groupedOrders[status] ?? [];
                          if (orders.isEmpty) return const SizedBox.shrink();

                          return ExpansionTile(
                            title: Text(
                              '${status[0].toUpperCase()}${status.substring(1)} (${orders.length})',
                              style: GoogleFonts.roboto(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            initiallyExpanded:
                                status == 'pending' || status == 'approved',
                            children:
                                orders.map((item) {
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.1),
                                          spreadRadius: 1,
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.all(16),
                                      leading: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.network(
                                          item.productImage,
                                          height: 80,
                                          width: 80,
                                          fit: BoxFit.cover,
                                          errorBuilder: (
                                            context,
                                            error,
                                            stackTrace,
                                          ) {
                                            return Container(
                                              height: 80,
                                              width: 80,
                                              color: Colors.grey[300],
                                              child: const Icon(
                                                Icons.image_not_supported,
                                                color: Colors.grey,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      title: Text(
                                        item.productTitle,
                                        style: GoogleFonts.roboto(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 4),
                                          Text(
                                            'Rs. ${item.productPrice.toStringAsFixed(2)}',
                                            style: GoogleFonts.roboto(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.deepPurple,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          if (item.status == 'approved')
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                top: 8.0,
                                              ),
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  _showPaymentDialog(item);
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.green,
                                                ),
                                                child: const Text('Pay Now'),
                                              ),
                                            ),
                                        ],
                                      ),
                                      trailing: IconButton(
                                        icon: const Icon(
                                          Icons.delete_outline,
                                          color: Colors.red,
                                        ),
                                        onPressed:
                                            () => _cartService.removeFromCart(
                                              item.id,
                                            ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                          );
                        }).toList(),
                  );
                },
              ),
    );
  }
}
