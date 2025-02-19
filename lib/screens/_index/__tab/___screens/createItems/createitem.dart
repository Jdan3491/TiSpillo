import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import '../../../../../core/widgets/full_button_ts.dart';
import '../../../../../core/widgets/notifier_ts.dart';
import 'settings.dart';
import 'item_manager.dart';

class CreateItemPage extends StatefulWidget {
  final String collectionId;
  final String? ProductID;

  CreateItemPage({Key? key, required this.collectionId, this.ProductID})
      : super(key: key);

  @override
  _CreateItemPageState createState() => _CreateItemPageState();
}

class _CreateItemPageState extends State<CreateItemPage> {
  final _formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _formData = {};
  bool _isLoading = false;
  String _nameParentList = '';

  @override
  void initState() {
    super.initState();
    if (widget.ProductID != null) {
      _initializeData();
    }
  }

  Future<void> _initializeData() async {
    setState(() {
      _isLoading = true;
    });

    final data = await ItemSettings.loadItemData(widget.ProductID!);
    final listName = await ItemSettings.getList(widget.collectionId);

    setState(() {
      _formData = data;
      _nameParentList = listName;
      _isLoading = false;
    });
  }

  // Funzione per mostrare la finestra di dialogo di conferma
  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Text('Conferma cancellazione'),
        content: Text(
            'Vuoi cancellare il materiale: ${_formData['name_item']} dalla lista ${_nameParentList}?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Chiude la finestra di dialogo
            },
            child: Text('Annulla'),
          ),
          TextButton(
            onPressed: () async {
              if (widget.ProductID != null) {
                // Verifica che non sia null
                bool success = await Settings.deleteItem(widget.ProductID!);
                print(success);
                if (success && context.mounted) {
                  Navigator.pop(dialogContext);
                  Navigator.pop(context);
                } else {
                  print("Errore nell'eliminazione del prodotto");
                }
              } else {
                print("Errore: ProductID nullo");
              }
            },
            child: Text('Conferma'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Aggiungi Materiale alla lista',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
        actions: (widget.ProductID != null && _formData.isNotEmpty)
            ? [
                IconButton(
                  icon:
                      Icon(Icons.delete, color: Theme.of(context).primaryColor),
                  onPressed: _showDeleteDialog,
                ),
              ]
            : null,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _isLoading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: FormBuilder(
                    key: _formKey,
                    initialValue: _formData,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        // Campo: Nome Item
                        FormBuilderTextField(
                          name: 'name_item',
                          decoration: const InputDecoration(
                            labelText: 'Nome Materiale',
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

                        // Campo: Inventory Item
                        FormBuilderTextField(
                          name: 'inventory_qty',
                          decoration: const InputDecoration(
                            labelText: 'Pezzi richiesti in Magazzino',
                            border: OutlineInputBorder(),
                          ),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(
                                errorText: ' * Il Campo è richiesto'),
                            FormBuilderValidators.integer(),
                            FormBuilderValidators.min(0,
                                errorText:
                                    " * Il valore non può essere negativo"),
                          ]),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),

                        // Campo: Price Item
                        FormBuilderTextField(
                          name: 'wish_qty',
                          decoration: const InputDecoration(
                            labelText: 'Pezzi desiderati',
                            border: OutlineInputBorder(),
                          ),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(
                                errorText: ' * Il Campo è richiesto'),
                            FormBuilderValidators.min(0,
                                errorText:
                                    " * Il valore non può essere negativo"),
                            FormBuilderValidators.integer(),
                          ]),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),
                        FormBuilderTextField(
                          name: 'description_item',
                          decoration: const InputDecoration(
                            labelText: 'Descrizione Materiale',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 5,
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

                        const SizedBox(height: 32),
                        FullButtonTs(
                          onPressed: () async {
                            if (_formKey.currentState?.saveAndValidate() ??
                                false) {
                              final formData = _formKey.currentState?.value;

                              int result = await Settings.saveItemToBackend(
                                  formData!,
                                  productID: widget.ProductID,
                                  collectionId: widget.collectionId);

                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) {
                                  return NotifierPopup(
                                    message: 'Prodotto salvato con successo!',
                                    isError: false,
                                    onDismiss: () async {
                                      Navigator.pop(context);
                                      Navigator.pop(context);
                                      _initializeData();
                                      if (result == 1) {
                                        Navigator.pop(context, true);
                                      } else if (result == 2) {
                                        setState(() {
                                          _formKey.currentState?.reset();
                                          _isLoading = false;
                                          _initializeData();
                                        });
                                      }
                                    },
                                  );
                                },
                              );
                            } else {
                              print('Errore nella validazione del modulo');
                            }
                          },
                          child:
                              (widget.ProductID != null && _formData.isNotEmpty)
                                  ? const Text('Aggiorna Materiale')
                                  : const Text('Aggiungi Materiale'),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
