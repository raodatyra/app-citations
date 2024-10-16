// Importation des packages et fichiers nécessaires
import 'package:flutter/material.dart';
import '../models/citation.dart';
import '../services/citation_service.dart';

// Définition de la classe CitationProvider qui étend ChangeNotifier pour la gestion d'état
class CitationProvider with ChangeNotifier {
  // Variables privées pour stocker l'état
  List<Citation> _citations = [];  // Liste des citations
  Set<int> _favorites = {};  // Ensemble des IDs des citations favorites
  bool _isLoading = false;  // Indicateur de chargement
  String? _error;  // Message d'erreur éventuel

  // Getters pour accéder aux variables privées
  List<Citation> get citations => _citations;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Méthode pour récupérer les citations
  Future<void> fetchCitations() async {
    _isLoading = true;  // Début du chargement
    _error = null;  // Réinitialisation de l'erreur
    notifyListeners();  // Notification des écouteurs

    try {
      // Tentative de récupération des citations locales
      _citations = await CitationService.getLocalCitations();
      // Si aucune citation locale, récupération depuis l'API
      if (_citations.isEmpty) {
        _citations = await CitationService.fetchQuotes();
      }
      // Récupération des favoris
      _favorites = await CitationService.getFavorites();
    } catch (error) {
      // Gestion des erreurs
      _error = error.toString();
      print('Error fetching citations: $_error');
    }

    _isLoading = false;  // Fin du chargement
    notifyListeners();  // Notification des écouteurs
  }

  // Méthode pour rafraîchir les citations depuis l'API
  Future<void> refreshCitations() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _citations = await CitationService.fetchQuotes();
    } catch (error) {
      _error = error.toString();
      print('Error refreshing citations: $_error');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Méthode pour vérifier si une citation est favorite
  bool isFavorite(Citation citation) {
    return _favorites.contains(citation.id);
  }

  // Méthode pour basculer l'état favori d'une citation
  Future<void> toggleFavorite(Citation citation) async {
    if (isFavorite(citation)) {
      _favorites.remove(citation.id);
      await CitationService.removeFavorite(citation.id!);
    } else {
      _favorites.add(citation.id!);
      await CitationService.addFavorite(citation.id!);
    }
    notifyListeners();
  }

  // Méthode pour rechercher des citations
  List<Citation> searchCitations(String query) {
    return _citations.where((citation) =>
        citation.text.toLowerCase().contains(query.toLowerCase()) ||
        citation.author.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }
}
