import 'package:supabase_flutter/supabase_flutter.dart';

class Settings {
  static Future<int> saveItemToBackend(Map<String, dynamic> formData,
      {String? productID, String? collectionId}) async {
    final client = Supabase.instance.client;
    int nextstep = 0;
    try {
      // Verifica se ProductID è presente per determinare se è un aggiornamento
      if (productID != null && productID.isNotEmpty) {
        final itemData = {
          'name': formData['name_item'],
          'description': formData['description_item'] ?? '',
          'inventory_qty': int.parse(formData['inventory_qty']),
          'wish_qty': int.parse(formData['wish_qty']),
        };

        final response =
            await client.from('items').update(itemData).eq('id', productID);
        nextstep = 2;
      } else if (collectionId != null && collectionId.isNotEmpty) {
        // Se ProductID non è presente ma collectionId lo è, è un nuovo inserimento
        final itemData = {
          'collection_id': collectionId,
          'name': formData['name_item'],
          'description': formData['description_item'] ?? '',
          'inventory_qty': int.parse(formData['inventory_qty']),
          'wish_qty': int.parse(formData['wish_qty']),
        };

        await client.from('items').insert(itemData).select().single();
        nextstep = 1;
      }
    } catch (e) {
      print('Errore durante il salvataggio dei dati: $e');
    }

    return nextstep;
  }

  // Funzione per eliminare un prodotto
  static Future<bool> deleteItem(String productID) async {
    try {
      final response = await Supabase.instance.client
          .from('items')
          .delete()
          .eq('id', productID);
      return true;
    } catch (e) {
      print('Errore durante l\'eliminazione: $e');
      return false;
    }
  }
}
