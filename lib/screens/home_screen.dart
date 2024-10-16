// Importation des bibliothèques nécessaires
import 'dart:async';  // Pour utiliser Timer
import 'package:flutter/material.dart';  // Widgets de base de Flutter
import 'package:provider/provider.dart';  // Pour la gestion d'état
import 'package:share_plus/share_plus.dart';  // Pour partager du contenu
import 'package:google_fonts/google_fonts.dart';  // Pour utiliser Google Fonts
import '../providers/citation_provider.dart';  // Notre provider personnalisé
import '../models/citation.dart';  // Notre modèle de données pour les citations
import 'package:flutter/painting.dart';  // Pour des fonctionnalités de peinture avancées

// Définition du widget principal de l'écran d'accueil
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

// Définition de l'état du widget HomeScreen
class _HomeScreenState extends State<HomeScreen> {
  // Contrôleur pour gérer le défilement des pages de citations
  PageController _pageController = PageController();
  
  // Timer pour changer automatiquement de citation
  Timer? _timer;
  
  // Index de la page (citation) actuellement affichée
  int _currentPage = 0;
  
  // Liste de couleurs pour les fonds des citations
  List<Color> backgroundColors = [
    Color(0xFF1E555C),  // Bleu-vert foncé
    Color(0xFF4E4187),  // Violet
    Color(0xFFDE5B6D),  // Rose
    Color(0xFFF0B775),  // Orange clair
    Color(0xFF367E18),  // Vert
  ];

  @override
  void initState() {
    super.initState();
    // Chargement initial des citations
    Future.microtask(() => context.read<CitationProvider>().fetchCitations());
    
    // Configuration du timer pour changer de citation toutes les 30 secondes
    _timer = Timer.periodic(Duration(seconds: 30), (Timer timer) {
      // Vérification si on n'est pas à la dernière citation
      if (_currentPage <
          context.read<CitationProvider>().citations.length - 1) {
        _currentPage++;  // Passage à la citation suivante
      } else {
        _currentPage = 0;  // Retour à la première citation si on était à la dernière
      }
      // Animation pour changer de page
      _pageController.animateToPage(
        _currentPage,
        duration: Duration(milliseconds: 350),  // Durée de l'animation
        curve: Curves.easeIn,  // Type de courbe d'animation
      );
    });
  }

  @override
  void dispose() {
    // Annulation du timer pour éviter les fuites de mémoire
    _timer?.cancel();
    // Libération des ressources du contrôleur de page
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Construction de l'interface utilisateur principale
    return Scaffold(
      body: Consumer<CitationProvider>(
        // Utilisation de Consumer pour réagir aux changements du CitationProvider
        builder: (context, citationProvider, child) {
          // Affichage d'un indicateur de chargement si les citations sont en cours de chargement
          if (citationProvider.isLoading) {
            return Center(
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white)));
          }
          // Affichage d'un message d'erreur si le chargement a échoué
          if (citationProvider.error != null) {
            return Center(
                child: Text('Erreur: ${citationProvider.error}',
                    style: GoogleFonts.lato(color: Colors.white)));
          }
          // Affichage d'un message si aucune citation n'est trouvée
          if (citationProvider.citations.isEmpty) {
            return Center(
                child: Text('Aucune citation trouvée.',
                    style: GoogleFonts.lato(color: Colors.white)));
          }
          // Construction de la vue des citations
          return PageView.builder(
            controller: _pageController,
            itemCount: citationProvider.citations.length,
            itemBuilder: (context, index) {
              final citation = citationProvider.citations[index];
              return Container(
                // Couleur de fond dynamique basée sur l'index de la citation
                color: backgroundColors[index % backgroundColors.length],
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Spacer(),  // Espace flexible en haut
                      
                      QuotationMarks(),  // Widget pour afficher les guillemets
                      SizedBox(height: 20),  // Espacement
                      // Texte de la citation
                      Text(
                        citation.text,
                        style: GoogleFonts.lato(
                          textStyle:
                              TextStyle(color: Colors.white, fontSize: 30),
                        ),
                      ),
                      SizedBox(height: 20),  // Espacement
                      // Auteur de la citation
                      Text(
                        '- ${citation.author}',
                        style: GoogleFonts.lato(
                          textStyle: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Spacer(),  // Espace flexible en bas
                      // Ligne de boutons d'action
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Bouton pour ajouter/retirer des favoris
                          _buildActionButton(
                            icon: citationProvider.isFavorite(citation)
                                ? Icons.favorite
                                : Icons.favorite_border,
                            onTap: () =>
                                citationProvider.toggleFavorite(citation),
                          ),
                          SizedBox(width: 20),  // Espacement
                          // Bouton pour partager la citation
                          _buildActionButton(
                            icon: Icons.share,
                            onTap: () => Share.share(
                                '${citation.text} - ${citation.author}'),
                          ),
                          SizedBox(width: 20),  // Espacement
                          // Bouton pour rechercher des citations
                          _buildActionButton(
                            icon: Icons.search,
                            onTap: () => showSearch(
                                context: context, delegate: CitationSearch()),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Méthode pour construire les boutons d'action circulaires
  Widget _buildActionButton(
      {required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(width: 1, color: Colors.white),
        ),
        padding: EdgeInsets.all(10),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}

// Widget pour afficher l'image des guillemets
class QuotationMarks extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Image.asset(
      "assets/quote.png",
      height: 100,
      width: 100,
      color: Colors.white,
    );
  }
}

// Classe pour gérer la recherche de citations
class CitationSearch extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext context) {
    // Action pour effacer le texte de recherche
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';  // Réinitialisation de la requête
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    // Bouton pour revenir en arrière
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');  // Fermeture de la recherche
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // Affichage des résultats de la recherche
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Affichage des suggestions pendant la saisie
    return _buildSearchResults(context);
  }

  // Méthode pour construire les résultats de la recherche
  Widget _buildSearchResults(BuildContext context) {
    final citationProvider = Provider.of<CitationProvider>(context);
    final results = citationProvider.searchCitations(query);

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final citation = results[index];
        return ListTile(
          title: Text(citation.text, style: GoogleFonts.lato()),
          subtitle: Text(citation.author,
              style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
          onTap: () {
            close(context, citation.text);  // Sélection d'une citation
          },
        );
      },
    );
  }
}





















































































































































































































































































































































































































































































// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:google_fonts/google_fonts.dart';
// import '../providers/citation_provider.dart';
// import '../models/citation.dart';
// import 'package:flutter/painting.dart';

// class HomeScreen extends StatefulWidget {
//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   PageController _pageController = PageController();
//   Timer? _timer;
//   int _currentPage = 0;
//   List<Color> backgroundColors = [
//     Color(0xFF1E555C),
//     Color(0xFF4E4187),
//     Color(0xFFDE5B6D),
//     Color(0xFFF0B775),
//     Color(0xFF367E18),
//   ];

//   @override
//   void initState() {
//     super.initState();
//     Future.microtask(() => context.read<CitationProvider>().fetchCitations());
//     _timer = Timer.periodic(Duration(seconds: 30), (Timer timer) {
//       if (_currentPage <
//           context.read<CitationProvider>().citations.length - 1) {
//         _currentPage++;
//       } else {
//         _currentPage = 0;
//       }
//       _pageController.animateToPage(
//         _currentPage,
//         duration: Duration(milliseconds: 350),
//         curve: Curves.easeIn,
//       );
//     });
//   }

//   @override
//   void dispose() {
//     _timer?.cancel();
//     _pageController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Consumer<CitationProvider>(
//         builder: (context, citationProvider, child) {
//           if (citationProvider.isLoading) {
//             return Center(
//                 child: CircularProgressIndicator(
//                     valueColor: AlwaysStoppedAnimation<Color>(Colors.white)));
//           }
//           if (citationProvider.error != null) {
//             return Center(
//                 child: Text('Erreur: ${citationProvider.error}',
//                     style: GoogleFonts.lato(color: Colors.white)));
//           }
//           if (citationProvider.citations.isEmpty) {
//             return Center(
//                 child: Text('Aucune citation trouvée.',
//                     style: GoogleFonts.lato(color: Colors.white)));
//           }
//           return PageView.builder(
//             controller: _pageController,
//             itemCount: citationProvider.citations.length,
//             itemBuilder: (context, index) {
//               final citation = citationProvider.citations[index];
//               return Container(
//                 color: backgroundColors[index % backgroundColors.length],
//                 child: Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Spacer(),
                      
//                       QuotationMarks(),
//                       SizedBox(height: 20),
//                       Text(
//                         citation.text,
//                         style: GoogleFonts.lato(
//                           textStyle:
//                               TextStyle(color: Colors.white, fontSize: 30),
//                         ),
//                       ),
//                       SizedBox(height: 20),
//                       Text(
//                         '- ${citation.author}',
//                         style: GoogleFonts.lato(
//                           textStyle: TextStyle(
//                               color: Colors.white, fontWeight: FontWeight.bold),
//                         ),
//                       ),
//                       Spacer(),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           _buildActionButton(
//                             icon: citationProvider.isFavorite(citation)
//                                 ? Icons.favorite
//                                 : Icons.favorite_border,
//                             onTap: () =>
//                                 citationProvider.toggleFavorite(citation),
//                           ),
//                           SizedBox(width: 20),
//                           _buildActionButton(
//                             icon: Icons.share,
//                             onTap: () => Share.share(
//                                 '${citation.text} - ${citation.author}'),
//                           ),
//                           SizedBox(width: 20),
//                           _buildActionButton(
//                             icon: Icons.search,
//                             onTap: () => showSearch(
//                                 context: context, delegate: CitationSearch()),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildActionButton(
//       {required IconData icon, required VoidCallback onTap}) {
//     return InkWell(
//       onTap: onTap,
//       child: Container(
//         decoration: BoxDecoration(
//           shape: BoxShape.circle,
//           border: Border.all(width: 1, color: Colors.white),
//         ),
//         padding: EdgeInsets.all(10),
//         child: Icon(icon, color: Colors.white),
//       ),
//     );
//   }
// }

// class QuotationMarks extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Image.asset(
//       "assets/quote.png",
//       height: 100,
//       width: 100,
//       color: Colors.white,
//     );
//   }
// }

// class CitationSearch extends SearchDelegate<String> {
//   @override
//   List<Widget> buildActions(BuildContext context) {
//     return [
//       IconButton(
//         icon: Icon(Icons.clear),
//         onPressed: () {
//           query = '';
//         },
//       ),
//     ];
//   }

//   @override
//   Widget buildLeading(BuildContext context) {
//     return IconButton(
//       icon: Icon(Icons.arrow_back),
//       onPressed: () {
//         close(context, '');
//       },
//     );
//   }

//   @override
//   Widget buildResults(BuildContext context) {
//     return _buildSearchResults(context);
//   }

//   @override
//   Widget buildSuggestions(BuildContext context) {
//     return _buildSearchResults(context);
//   }

//   Widget _buildSearchResults(BuildContext context) {
//     final citationProvider = Provider.of<CitationProvider>(context);
//     final results = citationProvider.searchCitations(query);

//     return ListView.builder(
//       itemCount: results.length,
//       itemBuilder: (context, index) {
//         final citation = results[index];
//         return ListTile(
//           title: Text(citation.text, style: GoogleFonts.lato()),
//           subtitle: Text(citation.author,
//               style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
//           onTap: () {
//             close(context, citation.text);
//           },
//         );
//       },
//     );
//   }
// }
