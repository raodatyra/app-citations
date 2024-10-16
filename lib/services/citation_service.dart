// Importation des packages nécessaires
import 'package:http/http.dart' as http; // Pour les requêtes HTTP
import 'package:sqflite/sqflite.dart'; // Pour la gestion de la base de données SQLite
import 'package:path/path.dart'; // Pour la gestion des chemins de fichiers
import '../models/citation.dart'; // Importe le modèle Citation (non fourni dans l'extrait)

class CitationService {
  // URL de l'API pour récupérer les citations
  static const String API_URL = 'https://zenquotes.io/api/quotes/';
  
  // Instance de la base de données
  static Database? _database;

  // Getter pour obtenir l'instance de la base de données
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Initialisation de la base de données
  static Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'citations_database.db');
    return await openDatabase(
      path,
      version: 3,
      onCreate: _createDb,
      onUpgrade: _upgradeDb,
    );
  }

  // Création des tables de la base de données
  static Future _createDb(Database db, int version) async {
    // Création de la table citations
    await db.execute('''
      CREATE TABLE citations(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        text TEXT,
        author TEXT
      )
    ''');
    // Création de la table favorites
    await db.execute('''
      CREATE TABLE favorites(
        id INTEGER PRIMARY KEY
      )
    ''');
  }

  // Mise à jour de la base de données si nécessaire
  static Future _upgradeDb(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      // Ajout de la table favorites si la version est inférieure à 3
      await db.execute('''
        CREATE TABLE favorites(
          id INTEGER PRIMARY KEY
        )
      ''');
    }
  }

  // Récupération des citations depuis l'API
  static Future<List<Citation>> fetchQuotes() async {
    final response = await http.get(Uri.parse(API_URL));
    if (response.statusCode == 200) {
      List<Citation> citations = Citation.parseQuotes(response.body);
      await saveCitations(citations);
      return citations;
    } else {
      throw Exception('Failed to load quotes');
    }
  }

  // Sauvegarde des citations dans la base de données locale
  static Future<void> saveCitations(List<Citation> citations) async {
    final db = await database;
    await db.transaction((txn) async {
      for (var citation in citations) {
        await txn.insert('citations', citation.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace);
      }
    });
  }

  // Récupération des citations depuis la base de données locale
  static Future<List<Citation>> getLocalCitations() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('citations');
    return List.generate(maps.length, (i) {
      return Citation(
        id: maps[i]['id'],
        text: maps[i]['text'],
        author: maps[i]['author'],
      );
    });
  }

  // Récupération des favoris
  static Future<Set<int>> getFavorites() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('favorites');
    return Set.from(maps.map((map) => map['id'] as int));
  }

  // Ajout d'un favori
  static Future<void> addFavorite(int id) async {
    final db = await database;
    await db.insert('favorites', {'id': id}, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  // Suppression d'un favori
  static Future<void> removeFavorite(int id) async {
    final db = await database;
    await db.delete('favorites', where: 'id = ?', whereArgs: [id]);
  }
}