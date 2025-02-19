import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

// Funzione per convertire la data da UTC a ora locale e formattarla
String formatDateToLocal(DateTime utcDate) {
  // Converte da UTC a ora locale (Italia)
  DateTime localDate = utcDate.toLocal();

  // Formatta la data nel formato desiderato "Giorno/Mese/Anno Ore:Minuti"
  final DateFormat dateFormat = DateFormat("dd/MM/yyyy HH:mm");
  return dateFormat.format(localDate);
}

class Settings {
  Future<List<Map<String, dynamic>>> fetchDataFromDatabase() async {
    try {
      // Fetch collections data
      final collectionsResponse = await Supabase.instance.client
          .from('collections')
          .select('id, name, description, created_at, employeeid')
          .order('updated_at', ascending: false);

      // Fetch employees data
      final employeesResponse =
          await Supabase.instance.client.from('employees').select('id, email');

      // Create a map of employee id to email
      final employeeMap = {
        for (var e in employeesResponse) e['id']: e['email']
      };

      // Merge collections data with employee email
      final result = collectionsResponse.map((item) {
        final createdAt = item['created_at'] != null
            ? formatDateToLocal(DateTime.parse(item['created_at']))
            : 'N/A';
        return {
          'id': item['id'],
          'name': item['name'],
          'description': item['description'],
          'created_at': createdAt,
          'user_name': employeeMap[item['employeeid']],
        };
      }).toList();

      print(result);

      return result;
    } catch (e) {
      throw Exception('Errore nel caricamento dei dati: $e');
    }
  }

  // Save a new collection
  Future<void> saveCollection(String createList, String createListDesc) async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception("User is not authenticated");
      }
      final response = await Supabase.instance.client
          .from('employees')
          .select('id')
          .eq('_id_auth', userId)
          .single();

      // Ottieni l'employee_id dal risultato
      final employeeId = response['id'];
      await Supabase.instance.client.from('collections').insert({
        'name': createList,
        'description': createListDesc,
        'employeeid': employeeId
      });
    } catch (error) {
      throw Exception('Errore nella creazione della lista: $error');
    }
  }

  // Filter the collection list
  List<Map<String, dynamic>> filterList(
      String query, List<Map<String, dynamic>> allItems) {
    List<Map<String, dynamic>> results = [];
    if (query.isEmpty) {
      results = allItems;
    } else {
      results = allItems
          .where((item) =>
              item['name'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    return results;
  }
}
