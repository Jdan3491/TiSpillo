import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void editCollection(
    BuildContext context, String collectionId, Map<String, dynamic> collection, VoidCallback onUpdate) {
  final _formKey = GlobalKey<FormBuilderState>();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Modifica Collezione'),
        content: FormBuilder(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FormBuilderTextField(
                name: 'edit_name',
                initialValue: collection['name'],
                decoration: const InputDecoration(
                  labelText: 'Nome',
                  border: OutlineInputBorder(),
                ),
                validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(
                                errorText: ' * Il Campo è richiesto'),
                            FormBuilderValidators.maxLength(20,
                                errorText: " * Massimo 20 caratteri"),
                          ]),
              ),
              const SizedBox(height: 16),
              FormBuilderTextField(
                name: 'edit_description',
                initialValue: collection['description'],
                decoration: const InputDecoration(
                  labelText: 'Descrizione',
                  border: OutlineInputBorder(),
                ),                          maxLines: 5,
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(
                                errorText: " * La descrizione è obbligatoria"),
                            FormBuilderValidators.maxLength(40,
                                errorText: " * Massimo 40 caratteri"),
                            (value) {
                              if (value == null || value.trim().isEmpty) {
                                return " * Il campo non può essere vuoto";
                              }

                              // Blocca caratteri pericolosi manualmente (evita problemi con il regex)
                              const List<String> forbiddenChars = [
                                '<',
                                '>',
                                ';',
                                '"',
                                "'"
                              ];
                              for (var char in forbiddenChars) {
                                if (value.contains(char)) {
                                  return " * Caratteri speciali non ammessi ($char)";
                                }
                              }

                              // Blocca parole sospette (SQL/HTML injection)
                              final List<String> blockedWords = [
                                "script",
                                "select",
                                "drop",
                                "insert",
                                "delete",
                                "update",
                                "alter"
                              ];
                              for (var word in blockedWords) {
                                if (value.toLowerCase().contains(word)) {
                                  return " * Testo non valido: contiene parole riservate";
                                }
                              }

                              return null;
                            },
                          ]),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annulla'),
          ),
          TextButton(
            onPressed: () async {
              if (_formKey.currentState?.saveAndValidate() ?? false) {
                final formData = _formKey.currentState!.value;
                await Supabase.instance.client.from('collections').update({
                  'name': formData['edit_name'],
                  'description': formData['edit_description'],
                }).eq('id', collectionId);

                Navigator.pop(context);
                onUpdate(); // Aggiorna lo stato nella schermata principale
              }
            },
            child: const Text('Salva'),
          ),
        ],
      );
    },
  );
}
