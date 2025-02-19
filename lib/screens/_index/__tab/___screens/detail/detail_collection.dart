import 'package:tispillo_official/screens/_index/__tab/___screens/detail/setting.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:uuid/uuid.dart';
import '../createItems/createitem.dart';
import 'delete_collection.dart';
import 'edit_collection.dart';

class DetailCollection extends StatefulWidget {
  final String collectionId;

  const DetailCollection({Key? key, required this.collectionId})
      : super(key: key);

  @override
  State<DetailCollection> createState() => _DetailCollectionState();
}

class _DetailCollectionState extends State<DetailCollection> {
  List<Map<String, dynamic>> items = [];
  List<Map<String, dynamic>> filteredItems = [];
  TextEditingController searchController = TextEditingController();
  FocusNode searchFocusNode = FocusNode();
  Map<String, dynamic>? collectionData;
  final settings = Settings();
  bool isLoading = true;
  Map<String, int> itemQuantities = {};

  @override
  void initState() {
    super.initState();
    fetchItems();
  }

  Future<void> handleCheckboxChange(
      bool? value, Map<String, dynamic> item) async {
    if (value == true) {
      String unitId;

      // Recupera l'ID della caratteristica
      final characteristicID = await Supabase.instance.client
          .from('characteristic')
          .select('id')
          .eq('name', 'COMPLETE_ITEMS')
          .maybeSingle() // <--- Sostituito single() con maybeSingle()
          .then((res) => res?['id'])
          .catchError((error) {
        print("Errore nel recupero della caratteristica: $error");
        return null;
      });

      if (characteristicID == null) {
        print("Errore: caratteristica non trovata");
        return;
      }

      try {
        final getUnitExists = await Supabase.instance.client
            .from('unit_characteristic')
            .select('unitid')
            .eq('item_id', item['id'])
            .eq('characteristic_id', characteristicID)
            .maybeSingle();

        if (getUnitExists != null && getUnitExists.containsKey('unitid')) {
          unitId = getUnitExists['unitid'];
        } else {
          final uuid = Uuid();
          unitId = uuid.v4();
        }

        print("Checkbox attivata, unitid: $unitId");

        // Crea l'oggetto da inserire
        final objUnitCharacteristic = {
          'item_id': item['id'],
          'characteristic_id': characteristicID,
          'value': 'COMPLETE_ITEMS',
        };

        // Inserisce i dati nella tabella
        await Supabase.instance.client
            .from('unit_characteristic')
            .insert(objUnitCharacteristic)
            .select()
            .single();

        // Aggiorna la UI dopo aver recuperato i nuovi dati
        await fetchItems();
        setState(() {});
      } catch (error) {
        print("Errore nell'inserimento in unit_characteristic: $error");
      }
    }
  }

  Future<void> fetchItems() async {
    final fetchedItems = await settings.fetchItems(widget.collectionId);
    final getitemdetail =
        await settings.fetchCollectionDetails(widget.collectionId);
    if (mounted) {
      setState(() {
        items = fetchedItems;
        filteredItems = fetchedItems;
        isLoading = false;
        collectionData = getitemdetail;
      });
    }
  }

  void filterList(String query) {
    setState(() {
      filteredItems = query.isEmpty
          ? items
          : items
              .where((item) =>
                  item['name'].toLowerCase().contains(query.toLowerCase()))
              .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dettaglio Collezione',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
        actions: [
          IconButton(
            icon: Icon(Icons.delete, color: Theme.of(context).primaryColor),
            onPressed: () => deleteCollection(context, widget.collectionId, () {
              Navigator.pop(context);
              Navigator.pop(context);
            }),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      color: Colors.blue[50],
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Text(
                          collectionData?['name'] ?? "Senza nome",
                          style: const TextStyle(
                              fontSize: 40, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(collectionData?['description'] ??
                            "Nessuna descrizione"),
                        trailing: IconButton(
                          icon: Icon(Icons.edit,
                              color: Theme.of(context).primaryColor),
                          onPressed: collectionData == null
                              ? null
                              : () => editCollection(
                                  context,
                                  widget.collectionId,
                                  collectionData!,
                                  fetchItems),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (items.isNotEmpty)
                      TextField(
                        controller: searchController,
                        focusNode: searchFocusNode,
                        onChanged: filterList,
                        decoration: InputDecoration(
                          labelText: 'Cerca...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.only(bottom: 80),
                        child: Column(
                          children: [
                            if (filteredItems.isEmpty)
                              SizedBox(
                                height: 50,
                                child: Card(
                                  color: Colors.yellow[50],
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  elevation: 2,
                                  child: const Center(
                                    child: Text(
                                      'Nessun prodotto assegnato',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black),
                                    ),
                                  ),
                                ),
                              )
                            else
                              ...filteredItems.map(
                                (item) => Card(
                                  color: item['isCompleted']
                                      ? Colors.green[500]
                                      : Colors.yellow[50],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 2,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12, horizontal: 16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ListTile(
                                          contentPadding: EdgeInsets.zero,
                                          title: Text(
                                            item['name'],
                                            style: TextStyle(
                                              fontSize: 25,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                          subtitle: Text(
                                            item['description'] ??
                                                'No description',
                                            style: TextStyle(
                                              color: item['isCompleted']
                                                  ? Colors.black
                                                  : Colors.grey,
                                            ),
                                          ),
                                          trailing: item['isCompleted']
                                              ? SizedBox.shrink()
                                              : IconButton(
                                                  icon: Icon(
                                                    Icons.info_outline,
                                                    size: 50,
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                  ),
                                                  onPressed: () async {
                                                    await Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            CreateItemPage(
                                                          collectionId: widget
                                                              .collectionId,
                                                          ProductID: item['id'],
                                                        ),
                                                      ),
                                                    );
                                                    fetchItems();
                                                  },
                                                ),
                                        ),
                                        const SizedBox(height: 10),
                                        if (item['isCompleted'])
                                          Row(
                                            children: [
                                              // Se l'item è completato, mostra un'icona di checkbox flaggata e "COMPLETATO"
                                              Container(
                                                color: Colors
                                                    .white, // Colore di sfondo bianco per la sezione
                                                padding: EdgeInsets.all(
                                                    20.0), // Padding per dare un po' di spazio intorno
                                                child: Row(
                                                  children: [
                                                    Transform.scale(
                                                      scale: 2,
                                                      child: Icon(
                                                        Icons
                                                            .check_circle, // Icona di checkbox flaggata
                                                        color: Colors.green[
                                                            500], // Colore verde per l'icona
                                                        size: 32,
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 20.0),
                                                      child: Text(
                                                        "COMPLETATO", // Scritta per "completato"
                                                        style: TextStyle(
                                                          fontSize: 24,
                                                          color: Colors.green[
                                                              500], // Colore verde per la scritta
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          )
                                        else
                                          Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  ElevatedButton(
                                                    onPressed: () async {
                                                      try {
                                                        if (item[
                                                                'inventory_qty'] >
                                                            0) {
                                                          await Supabase
                                                              .instance.client
                                                              .from('items')
                                                              .update({
                                                            'inventory_qty':
                                                                item['inventory_qty'] -
                                                                    1,
                                                          }).eq('id',
                                                                  item['id']);
                                                          setState(() {
                                                            fetchItems();
                                                          });
                                                        }
                                                      } catch (e) {
                                                        print(
                                                            'Error updating wish_qty: $e');
                                                      }
                                                    },
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      shape: CircleBorder(),
                                                      padding:
                                                          EdgeInsets.all(16),
                                                      backgroundColor:
                                                          Colors.grey[300],
                                                      foregroundColor:
                                                          Theme.of(context)
                                                              .primaryColor,
                                                    ),
                                                    child: Icon(
                                                      Icons.remove,
                                                      color: Theme.of(context)
                                                          .primaryColor,
                                                      size: 30,
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 8),
                                                    child: Text.rich(
                                                      TextSpan(
                                                        children: [
                                                          TextSpan(
                                                            text: item[
                                                                    'inventory_qty']
                                                                .toString(),
                                                            style: TextStyle(
                                                              fontSize: 24,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                          ),
                                                          TextSpan(
                                                            text: "/",
                                                            style: TextStyle(
                                                              fontSize: 40,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                          ),
                                                          TextSpan(
                                                            text:
                                                                item['wish_qty']
                                                                    .toString(),
                                                            style: TextStyle(
                                                              fontSize: 40,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: Theme.of(
                                                                      context)
                                                                  .primaryColor,
                                                              decoration:
                                                                  TextDecoration
                                                                      .underline,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  ElevatedButton(
                                                    onPressed: () async {
                                                      try {
                                                        await Supabase
                                                            .instance.client
                                                            .from('items')
                                                            .update({
                                                          'inventory_qty': item[
                                                                  'inventory_qty'] +
                                                              1,
                                                        }).eq('id', item['id']);
                                                        setState(() {
                                                          fetchItems();
                                                        });
                                                      } catch (e) {
                                                        print(
                                                            'Error updating wish_qty: $e');
                                                      }
                                                    },
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      shape: CircleBorder(),
                                                      padding:
                                                          EdgeInsets.all(16),
                                                      backgroundColor:
                                                          Colors.grey[300],
                                                      foregroundColor:
                                                          Theme.of(context)
                                                              .primaryColor,
                                                    ),
                                                    child: Icon(
                                                      Icons.add,
                                                      color: Theme.of(context)
                                                          .primaryColor,
                                                      size: 30,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 25),
                                              Row(
                                                children: [
                                                  // Se l'item non è completato, mostra una checkbox non selezionata e "Soddisfatto?"
                                                  Container(
                                                    padding: EdgeInsets.all(
                                                        8.0), // Padding per dare un po' di spazio intorno
                                                    child: Row(
                                                      children: [
                                                        Transform.scale(
                                                          scale: 2,
                                                          child: Checkbox(
                                                            value: item[
                                                                'isCompleted'],
                                                            activeColor: Colors
                                                                .green[500],
                                                            checkColor:
                                                                Colors.white,
                                                            fillColor:
                                                                WidgetStateProperty
                                                                    .all(Colors
                                                                        .grey),
                                                            onChanged: (bool?
                                                                value) async {
                                                              await handleCheckboxChange(
                                                                  value, item);
                                                            },
                                                            visualDensity:
                                                                VisualDensity
                                                                    .comfortable,
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 8.0),
                                                          child: Text(
                                                            "Soddisfatto?", // Scritta per "soddisfatto?"
                                                            style: TextStyle(
                                                              fontSize: 24,
                                                              color: Colors
                                                                  .grey, // Colore grigio per la scritta
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  CreateItemPage(collectionId: widget.collectionId),
            ),
          );
          fetchItems();
        },
        label: const Text('Aggiungi materiale',
            style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.add, color: Colors.white),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }
}
