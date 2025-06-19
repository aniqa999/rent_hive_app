import 'package:flutter/material.dart';
import '../models/Category.dart';

class CategoryChip extends StatefulWidget {
  final Category cat;

  const CategoryChip({super.key, required this.cat});

  @override
  State<CategoryChip> createState() => _CategoryChipState();
}

class _CategoryChipState extends State<CategoryChip> {
  bool active = false;

  void _activeState() {
    setState(() {
      active = !active;
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _activeState,
      child: Chip(
        padding: EdgeInsets.all(10.0),
        backgroundColor: active ? Colors.deepPurple : Colors.white,
        avatar: Image.asset(widget.cat.iconURL),
        label: Text(
          widget.cat.name,
          style: TextStyle(color: active ? Colors.white : Colors.deepPurple),
        ),
      ),
    );
  }
}
