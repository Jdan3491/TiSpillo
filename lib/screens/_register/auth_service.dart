import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/widgets/notifier_ts.dart';

class RegisterService {
  static Future<void> register(
    GlobalKey<FormBuilderState> formKey,
    BuildContext context,
  ) async {
    if (formKey.currentState?.saveAndValidate() ?? false) {
      final formData = formKey.currentState?.value;
      if (formData == null) {
        print('Form data is null');
      }

      final email = formData?['email'];
      final password = formData?['password'];

      try {
        final AuthResponse res = await Supabase.instance.client.auth.signUp(
          email: email,
          password: password,
        );

        final client = Supabase.instance.client;
        final Session? session = res.session;
        final User? user = res.user;
        final itemData = {
          '_id_auth': user?.id,
          'email': email,
          'first_name': '',
          'last_name': '',
          'role': 'Employee',
        };

        await client.from('employees').insert(itemData).select().single();

        if (user != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => NotifierPopup(
                isError: false,
                message: 'Registrazione riuscita con successo!',
                onDismiss: () {
                  Navigator.pop(context);
                },
              ),
            ),
          );

          Future.delayed(Duration(seconds: 1), () {
            Navigator.pushNamed(context, '/home');
          });
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => NotifierPopup(
                isError: true,
                message: 'Errore nella registrazione!',
                onDismiss: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
              ),
            ),
          );
        }
      } catch (e) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => NotifierPopup(
              isError: true,
              message: 'Errore nella registrazione!',
              onDismiss: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
          ),
        );
      }
    }
  }
}
