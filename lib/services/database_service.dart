import 'package:firebase_database/firebase_database.dart';

class DatabaseService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

    // Función para verificar si un dato existe en la DB
  Future<bool> checkIfUserExists(String userId) async {
    final DatabaseReference userRef = _database.child("users/$userId");

    // Imprimir la URL a la que se está apuntando
    print("Consultando: ${userRef.path}");

    try {
      DataSnapshot snapshot = await userRef.get();

      if (snapshot.exists) {
        print("USER EXIST IN DATABASE");
        return true;
      } else {
        print("USER DOES NOT EXIST IN DATABASE");
        return false;
      }
    } catch (e) {
      print("ERROR WHILE VERIFIYING USER: $e");
      return false;
    }
  }

  // Leer datos una sola vez
  Future<DataSnapshot> readData(String key) async {
    return await _database.child(key).get();
  }

  // Escuchar cambios en tiempo real
  void listenToChanges(String key, Function(DatabaseEvent) onDataChanged) {
    _database.child(key).onValue.listen(onDataChanged);
  }
}