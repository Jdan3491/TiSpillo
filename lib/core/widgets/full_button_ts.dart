import 'package:flutter/material.dart';

class FullButtonTs extends StatelessWidget {
  final Widget child;
  final VoidCallback onPressed;

  const FullButtonTs({
    required this.child,
    required this.onPressed,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 80,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.brown,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: EdgeInsets.symmetric(vertical: 18),
          elevation: 0,
        ),
        child: DefaultTextStyle.merge(
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
          child: child,
        ),
      ),
    );
  }
}
