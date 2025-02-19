import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/widgets/notifier_ts.dart';
import 'setting.dart';

void deleteCollection(
    BuildContext context, String collectionId, VoidCallback onDelete) {
  final settings = Settings();
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Conferma eliminazione'),
        content: const Text(
            'Sei sicuro di voler eliminare questa collezione? Questa azione è irreversibile.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annulla'),
          ),
          TextButton(
            onPressed: () async {
              try {
                settings.deleteCollection(collectionId);

                Navigator.pop(context);

                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) {
                    return NotifierPopup(
                      message: 'Prodotto cancellato con successo!',
                      isError: false,
                      onDismiss: () async {
                        Navigator.pop(context);
                        onDelete();
                      },
                    );
                  },
                );
              } catch (error) {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) {
                    return NotifierPopup(
                      message: 'Errore: impossibile eliminare la collezione',
                      isError: false,
                      onDismiss: () async {
                        Navigator.pop(context);
                        onDelete();
                      },
                    );
                  },
                );
              }
            },
            child: const Text('Elimina'),
          ),
        ],
      );
    },
  );
}
