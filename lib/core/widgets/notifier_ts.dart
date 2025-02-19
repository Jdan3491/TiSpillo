import 'package:flutter/material.dart';

class NotifierPopup extends StatefulWidget {
  final bool isError;
  final String message;
  final VoidCallback onDismiss;

  const NotifierPopup({
    Key? key,
    required this.isError,
    required this.message,
    required this.onDismiss,
  }) : super(key: key);

  @override
  _NotifierPopupState createState() => _NotifierPopupState();
}

class _NotifierPopupState extends State<NotifierPopup> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    // Delay Code Running
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        _isLoading = false;
      });

      // Show Dialog Mode
      _showDialog(context);
    });
  }

  void _showDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor:
              widget.isError ? Colors.yellow.shade700 : Colors.green.shade600,
          title: Text(
            widget.isError ? 'Error' : 'Success',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: Colors.white,
            ),
          ),
          content: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              widget.message,
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: ElevatedButton(
                onPressed: () {
                  widget.onDismiss(); // Call the onDismiss callback
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white, // White background for button
                  foregroundColor: widget.isError
                      ? Colors.orange.shade900
                      : Colors.green.shade800, // Text color
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(
                  'OK',
                  style: TextStyle(
                    fontWeight: FontWeight.bold, // Bold Font
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return SizedBox
          .shrink();
    }
  }
}
