import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/widgets/notifier_ts.dart';

class AuthService {
  static Future<String?> login(
    GlobalKey<FormBuilderState> formKey,
    BuildContext context,
  ) async {
    if (formKey.currentState?.saveAndValidate() ?? false) {
      final formData = formKey.currentState?.value;
      final email = formData?['email'];
      final password = formData?['password'];

      try {
        final response = await Supabase.instance.client.auth
            .signInWithPassword(email: email, password: password);

        if (response.user != null) {
          // Mostra il popup di successo
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => NotifierPopup(
                isError: false,
                message: 'Login successful!',
                onDismiss: () {
                  Navigator.pop(
                      context); // Close the NotifierPopup and go back to the previous screen
                },
              ),
            ),
          );

          Future.delayed(Duration(seconds: 1), () {
            Navigator.pushNamed(context, '/home');
          });

          return null;
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => NotifierPopup(
                isError: true,
                message: 'Credentials are invalid! Please try again.',
                onDismiss: () {
                  Navigator.pop(
                      context); // Close the NotifierPopup and go back to the previous screen
                },
              ),
            ),
          );

          Future.delayed(Duration(seconds: 1), () {
            Navigator.pushNamed(context, '/home');
          });

          return null;
        }
      } catch (error) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => NotifierPopup(
              isError: true,
              message: 'An error occurred. Please try again.',
              onDismiss: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
          ),
        );
        return null;
      }
    }
    return null;
  }
}
