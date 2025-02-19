import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import '../../../../../core/widgets/notifier_ts.dart';
import 'settings.dart'; // Import the settings file
import '../../___screens/detail/detail_collection.dart';

class IndexPage extends StatefulWidget {
  @override
  _IndexPageState createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> with RouteAware {
  List<Map<String, dynamic>> allItems = [];
  List<Map<String, dynamic>> filteredItems = [];
  TextEditingController searchController = TextEditingController();
  final _formKey = GlobalKey<FormBuilderState>();
  FocusNode searchFocusNode = FocusNode();
  final settings =
      Settings(); // Create an instance of Settings to access the methods

  @override
  void initState() {
    super.initState();
    fetchDataFromDatabase();
  }

  @override
  void didPopNext() {
    super.didPopNext();
    fetchDataFromDatabase();
  }

  // Fetch data from the database using Settings
  Future<void> fetchDataFromDatabase() async {
    try {
      List<Map<String, dynamic>> dbResponse =
          await settings.fetchDataFromDatabase();
      setState(() {
        allItems = dbResponse;
        filteredItems = dbResponse;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore nel caricamento dei dati')),
      );
    }
  }

  // Handle the filter of the list using Settings
  void filterList(String query) {
    setState(() {
      filteredItems = settings.filterList(query, allItems);
    });
  }

  // UI Widget: Main screen
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text('Collezioni',
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
          actions: [
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: fetchDataFromDatabase,
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: searchController,
                focusNode: searchFocusNode,
                onChanged: filterList,
                decoration: InputDecoration(
                  labelText: 'Cerca...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Expanded(
                child: filteredItems.isEmpty
                    ? Center(child: Text('Nessun elemento trovato.'))
                    : ListView.builder(
                        padding: EdgeInsets.only(bottom: 80),
                        itemCount: filteredItems.length,
                        itemBuilder: (context, index) {
                          final item = filteredItems[index];
                          return Card(
                            color: Colors.yellow[50],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            margin: EdgeInsets.symmetric(vertical: 8.0),
                            elevation: 2,
                            child: ListTile(
                              contentPadding: EdgeInsets.all(16.0),
                              title: Text(item['name'],
                                  style: TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Descrizione della collezione
                                  Text(item['description'] ?? 'Nessuna descrizione'),

                                  // Nome utente
                                  SizedBox(
                                      height:
                                          8), 
                                  Text(
                                    'Nome Utente: ${item['user_name'] ?? 'Non disponibile'}',
                                    style: TextStyle(color: Colors.grey),
                                  ),

                                  // Data di creazione
                                  SizedBox(
                                      height:
                                          8), // Distanza tra il nome utente e la data
                                  Text(
                                    'Data di creazione: ${item['created_at'] ?? 'Non disponibile'}',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                              trailing: Icon(Icons.arrow_forward_ios,
                                  color: Theme.of(context).primaryColor),
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DetailCollection(
                                        collectionId: item['id']),
                                  ),
                                );
                                fetchDataFromDatabase();
                              },
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => createNewList(context),
          label: Text('Crea Lista', style: TextStyle(color: Colors.white)),
          icon: Icon(Icons.add, color: Colors.white),
          backgroundColor: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  // Create new list dialog
  Future<void> createNewList(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: FormBuilder(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Crea una nuova collezione'),
                SizedBox(height: 16),
                FormBuilderTextField(
                  name: 'create_list',
                  decoration: InputDecoration(
                    labelText: 'Crea Lista',
                    border: OutlineInputBorder(),
                  ),
                  validator: FormBuilderValidators.compose(
                      [FormBuilderValidators.required()]),
                ),
                SizedBox(height: 16),
                FormBuilderTextField(
                  name: 'create_list_description',
                  decoration: InputDecoration(
                    labelText: 'Aggiungi Descrizione',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Annulla'),
            ),
            TextButton(
              onPressed: () => _saveCollection(),
              child: Text('Salva'),
            ),
          ],
        );
      },
    );
  }

// Save collection using the Settings class
  Future<void> _saveCollection() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final formData = _formKey.currentState?.value;
      final createList = formData?['create_list'];
      final createList_desc = formData?['create_list_description'];

      // Show loading popup
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return NotifierPopup(
            message: 'Salvataggio in corso...',
            isError: false,
            onDismiss: () {},
          );
        },
      );

      try {
        await settings.saveCollection(createList, createList_desc);

        // Close the loading popup and show success message
        Navigator.pop(context); // Close the loading popup
        Navigator.pop(context); // Close the loading popup
        showDialog(
          context: context,
          builder: (context) {
            return NotifierPopup(
              message: 'Lista creata con successo!',
              isError: false,
              onDismiss: () {
                Navigator.pop(
                    context); // Close the NotifierPopup and go back to the previous screen
                Navigator.pop(context);
                fetchDataFromDatabase(); // Refresh the list
              },
            );
          },
        );
      } catch (error) {
        // Close the loading popup and show error message
        Navigator.pop(context); // Close the loading popup
        showDialog(
          context: context,
          builder: (context) {
            return NotifierPopup(
              message: 'Errore nella creazione della lista',
              isError: false,
              onDismiss: () {
                Navigator.pop(
                    context); // Close the NotifierPopup and go back to the previous screen
                Navigator.pop(context);
                Navigator.pop(context);
              },
            );
          },
        );
      }
    }
  }
}
