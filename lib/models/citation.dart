// Importe la bibliothèque dart:convert pour la manipulation JSON
import 'dart:convert';

// Définition de la classe Citation
class Citation {
  // Propriétés de la classe
  final int? id;  // L'ID est optionnel (peut être null)
  final String text;  // Le texte de la citation
  final String author;  // L'auteur de la citation

  // Constructeur de la classe
  // L'ID est optionnel, le texte et l'auteur sont obligatoires
  Citation({this.id, required this.text, required this.author});

  // Constructeur factory pour créer une instance de Citation à partir d'un JSON
  factory Citation.fromJson(Map<String, dynamic> json) {
    return Citation(
      text: json['q'] as String,  // 'q' représente le texte de la citation
      author: json['a'] as String,  // 'a' représente l'auteur de la citation
    );
  }

  // Méthode pour convertir l'instance de Citation en Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'author': author,
    };
  }

  // Méthode statique pour analyser une chaîne JSON et retourner une liste de Citations
  static List<Citation> parseQuotes(String responseBody) {
    // Décode la chaîne JSON en une liste de Map
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    // Convertit chaque Map en instance de Citation et retourne la liste
    return parsed.map<Citation>((json) => Citation.fromJson(json)).toList();
  }
}













































// import 'dart:convert';

// class Citation {
//   final int? id;
//   final String text;
//   final String author;

//   Citation({this.id, required this.text, required this.author});

//   factory Citation.fromJson(Map<String, dynamic> json) {
//     return Citation(
//       text: json['q'] as String,
//       author: json['a'] as String,
//     );
//   }

//   Map<String, dynamic> toMap() {
//     return {
//       'id': id,
//       'text': text,
//       'author': author,
//     };
//   }

//   static List<Citation> parseQuotes(String responseBody) {
//     final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
//     return parsed.map<Citation>((json) => Citation.fromJson(json)).toList();
//   }
// }
