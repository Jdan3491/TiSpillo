import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/widgets/custom_alert_dialog.dart';
import '../../../../core/widgets/notifier_ts.dart';

class ProfileSettings {
  User? currentUser;
  String profileImageUrl = '';
  String firstName = '';
  String lastName = '';

  ProfileSettings() {
    currentUser = Supabase.instance.client.auth.currentUser;
  }

  Future<void> fetchEmployeeData(Function updateState) async {
    final client = Supabase.instance.client;
    final user = Supabase.instance.client.auth.currentUser;

    if (user != null) {
      final response = await client
          .from('employees')
          .select()
          .eq('_id_auth', user.id)
          .single();

      if (response.isNotEmpty) {
        profileImageUrl = response['profile_image'] ?? profileImageUrl;
        firstName = response['first_name'] ?? '';
        lastName = response['last_name'] ?? '';
        updateState();
      }
    }
  }
Future<void> logout(BuildContext context) async {
  try {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return const CustomAlertDialog(
          title: 'Conferma Logout',
          content: 'Sei sicuro di voler effettuare il logout?',
        );
      },
    );

    if (confirmed == true) {
      await Supabase.instance.client.auth.signOut();

      showDialog(
        context: context,
        builder: (_) => NotifierPopup(
          isError: false,
          message: 'Logout eseguito con successo!',
          onDismiss: () {
            Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
          },
        ),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Errore durante il logout. Riprova.')),
    );
  }
}

}
