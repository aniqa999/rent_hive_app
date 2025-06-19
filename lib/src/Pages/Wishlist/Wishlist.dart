import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

class WishlistPage extends StatelessWidget {
  const WishlistPage({super.key});

  final List<String> images = const [
    'assets/image1.jpg',
    'assets/image2.jpg',
    'assets/image3.jpg',
    'assets/image1.jpg',
    'assets/image2.jpg',
    'assets/image3.jpg',
  ];

  void showAction(BuildContext context, String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$action clicked'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Updated colors for a clean white theme with blue accents
    //final Color primaryColor = const Color.fromARGB(255, 9, 46, 78);
    final Color backgroundColor = Colors.white;
    final Color cardColor = Colors.grey.shade100;
    final Color shadowColor = Colors.grey.shade300;
    final Color iconColor = const Color.fromARGB(255, 8, 46, 83);

    return Scaffold(
      // drawer: Drawer(
      //   backgroundColor: Colors.white,
      //   child: ListView(
      //     children: [
      //       DrawerHeader(
      //         decoration: BoxDecoration(
      //           color: primaryColor,
      //           boxShadow: [
      //             BoxShadow(
      //               color: primaryColor.withOpacity(0.4),
      //               blurRadius: 8,
      //               offset: const Offset(0, 4),
      //             ),
      //           ],
      //         ),
      //         child: Row(
      //           mainAxisAlignment: MainAxisAlignment.center,
      //           crossAxisAlignment: CrossAxisAlignment.center,
      //           children: [
      //             SizedBox(
      //               height: 50,
      //               width: 45,
      //               child: Image.asset(
      //                 'assets/image1.jpg',
      //                 fit: BoxFit.contain,
      //               ),
      //             ),
      //             const SizedBox(width: 12),
      //             const JumpingText(
      //               text: 'RentHive',
      //               fontSize: 28,
      //               fontWeight: FontWeight.bold,
      //               color: Colors.white,
      //               letterSpacing: 1.5,
      //             ),
      //           ],
      //         ),
      //       ),
      //       ListTile(
      //         leading: Icon(Icons.home, color: iconColor),
      //         title: Text(
      //           'Go to Home',
      //           style: GoogleFonts.roboto(
      //             fontSize: 22,
      //             color: iconColor,
      //             shadows: [
      //               Shadow(
      //                 offset: const Offset(1, 1),
      //                 blurRadius: 2,
      //                 color: iconColor.withOpacity(0.3),
      //               ),
      //             ],
      //           ),
      //         ),
      //         onTap: () => showAction(context, 'Home'),
      //       ),
      //       ListTile(
      //         leading: Icon(Icons.settings, color: iconColor),
      //         title: Text(
      //           'Settings',
      //           style: GoogleFonts.roboto(
      //             fontSize: 22,
      //             color: iconColor,
      //             shadows: [
      //               Shadow(
      //                 offset: const Offset(1, 1),
      //                 blurRadius: 2,
      //                 color: iconColor.withOpacity(0.3),
      //               ),
      //             ],
      //           ),
      //         ),
      //         onTap: () => showAction(context, 'Settings'),
      //       ),
      //       ListTile(
      //         leading: Icon(Icons.info, color: iconColor),
      //         title: Text(
      //           'About Us',
      //           style: GoogleFonts.roboto(
      //             fontSize: 22,
      //             color: iconColor,
      //             shadows: [
      //               Shadow(
      //                 offset: const Offset(1, 1),
      //                 blurRadius: 2,
      //                 color: iconColor.withOpacity(0.3),
      //               ),
      //             ],
      //           ),
      //         ),
      //         onTap: () => showAction(context, 'About'),
      //       ),
      //     ],
      //   ),
      // ),
      // appBar: AppBar(
      //   backgroundColor: primaryColor,
      //   elevation: 4,
      //   title: Text(
      //     'My Wishlist',
      //     style: GoogleFonts.roboto(
      //       fontSize: 28,
      //       fontWeight: FontWeight.bold,
      //       color: Colors.white, // added this line
      //     ),
      //   ),

      //   centerTitle: true,
      //   actions: [
      //     IconButton(
      //       icon: const Icon(Icons.home),
      //       onPressed: () => showAction(context, 'Home Icon'),
      //     ),
      //   ],
      // ),
      backgroundColor: backgroundColor,
      body: ListView.builder(
        itemCount: images.length,
        padding: const EdgeInsets.all(12),
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: shadowColor,
                  blurRadius: 10,
                  offset: const Offset(4, 6),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(10),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.asset(
                  images[index],
                  height: 60,
                  width: 60,
                  fit: BoxFit.cover,
                ),
              ),
              title: Text(
                'Orange - XX Traders',
                style: GoogleFonts.roboto(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              subtitle: Text(
                'Rs.300 / 2KG',
                style: GoogleFonts.roboto(fontSize: 16, color: Colors.black54),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.favorite_border),
                    color: Colors.redAccent,
                    tooltip: 'Like',
                    onPressed: () => showAction(context, 'Liked'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_shopping_cart),
                    color: iconColor,
                    tooltip: 'Add to Cart',
                    onPressed: () => showAction(context, 'Added to Cart'),
                  ),
                ],
              ),
              onTap: () => showAction(context, 'Item tapped'),
            ),
          );
        },
      ),
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
