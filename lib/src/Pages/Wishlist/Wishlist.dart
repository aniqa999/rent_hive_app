import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/Order.dart' as model;
import '../../services/cart_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// void main() => runApp(const MyApp());

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: WishlistPage(),
//     );
//   }
// }

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  final CartService _cartService = CartService();

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
      body: StreamBuilder<List<model.Order>>(
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
                    style: TextStyle(fontSize: 16, color: Colors.grey[500]),
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
                                  errorBuilder: (context, error, stackTrace) {
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
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                      padding: const EdgeInsets.only(top: 8.0),
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
                                    () => _cartService.removeFromCart(item.id),
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

  Map<String, List<model.Order>> _groupOrdersByStatus(
    List<model.Order> orders,
  ) {
    final map = <String, List<model.Order>>{};
    for (final order in orders) {
      (map[order.status] ??= []).add(order);
    }
    return map;
  }

  void _showPaymentDialog(model.Order order) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Complete Payment'),
          content: const Text('This is a placeholder for the payment form.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Simulate payment
                await FirebaseFirestore.instance
                    .collection('orders')
                    .doc(order.id)
                    .update({'status': 'paid'});
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Payment Successful!')),
                );
              },
              child: const Text('Pay'),
            ),
          ],
        );
      },
    );
  }
}

// Animated JumpingText widget used for RentHive animation
class JumpingText extends StatefulWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final Color color;
  final double letterSpacing;

  const JumpingText({
    required this.text,
    required this.fontSize,
    required this.fontWeight,
    required this.color,
    this.letterSpacing = 0,
    super.key,
  });

  @override
  _JumpingTextState createState() => _JumpingTextState();
}

class _JumpingTextState extends State<JumpingText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 0,
      end: -8,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder:
          (context, child) => Transform.translate(
            offset: Offset(0, _animation.value),
            child: child,
          ),
      child: Text(
        widget.text,
        style: GoogleFonts.roboto(
          fontSize: widget.fontSize,
          fontWeight: widget.fontWeight,
          color: widget.color,
          letterSpacing: widget.letterSpacing,
          shadows: const [
            Shadow(offset: Offset(1, 1), blurRadius: 4, color: Colors.black38),
          ],
        ),
      ),
    );
  }
}
