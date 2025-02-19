import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

class ItemSettings {
  static Future<String> getList(String collectionId) async {
    try {
      final response = await Supabase.instance.client
          .from('collections')
          .select('name')
          .eq('id', collectionId)
          .single();
      return response['name'] ?? '';
    } catch (e) {
      print('Errore durante il recupero della lista: $e');
      return '';
    }
  }

  static Future<Map<String, dynamic>> loadItemData(String productId) async {
    try {
      final response = await Supabase.instance.client
          .from('items')
          .select()
          .eq('id', productId)
          .single();

      if (response != null) {
        return {
          'name_item': response['name'] ?? '',
          'inventory_qty': response['inventory_qty'].toString() ?? '',
          'wish_qty': response['wish_qty'].toString() ?? '',
          'description_item': response['description'] ?? '',
        };
      }
    } catch (e) {
      print('Errore durante il recupero dei dati: $e');
    }
    return {};
  }

}
