import 'package:supabase_flutter/supabase_flutter.dart';

class Settings {
  Future<Map<String, dynamic>?> fetchCollectionDetails(String id) async {
    final response = await Supabase.instance.client
        .from('collections')
        .select()
        .eq('id', id)
        .single();

    if (response is Map<String, dynamic>) {
      print(response);
      return response;
    } else {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> fetchItems(String collectionId) async {
    final response = await Supabase.instance.client
        .from('items')
        .select()
        .eq('collection_id', collectionId)
        .order('updated_at', ascending: false);

    List<Map<String, dynamic>> items =
        List<Map<String, dynamic>>.from(response);

    for (var item in items) {
      bool isCompleted = await _checkIfCompleted((item['id']));
      item['isCompleted'] = isCompleted;
    }

    print('Test Print: $items');

    return items;
  }


Future<bool> _checkIfCompleted(String itemId) async {
  try {
    // Recupera il record dalla tabella unit_characteristic per l'item_id
    final unitCharacteristicsResponse = await Supabase.instance.client
        .from('unit_characteristic')
        .select('unitid, characteristic_id')
        .eq('item_id', itemId)
        .eq('value', 'COMPLETE_ITEMS')
        .single();

    if (unitCharacteristicsResponse == null || unitCharacteristicsResponse.isEmpty) {
      return false; // Nessun record trovato per l'item_id, quindi non è completato
    }

    // Recupera il characteristic_id dal record trovato
    final characteristicId = unitCharacteristicsResponse['characteristic_id'];

    // Verifica se la caratteristica associata è "COMPLETE_ITEMS"
    final characteristicResponse = await Supabase.instance.client
        .from('characteristic')
        .select('name')
        .eq('id', characteristicId)
        .single();

    if (characteristicResponse != null &&
        characteristicResponse['name'] == 'COMPLETE_ITEMS') {
      return true; 
    }

    return false; 
  } catch (e) {
    print('Errore nella verifica della completezza: $e');
    return false;
  }
}























  Future<void> updateCollection(
      String collectionId, String name, String description) async {
    await Supabase.instance.client.from('collections').update({
      'name': name,
      'description': description,
    }).eq('id', collectionId);
  }

  Future<void> deleteCollection(String collectionId) async {
    await Supabase.instance.client
        .from('collections')
        .delete()
        .eq('id', collectionId);
  }


  






}
