import 'package:flutter/foundation.dart';
import 'package:whats_app_flutter/model/chat_message.dart';
import 'package:whats_app_flutter/model/user.dart';
import 'package:whats_app_flutter/service/service_api.dart';

class UserProvider extends ChangeNotifier {
  final ServiceApi serviceApi = ServiceApi();
  List<User> users = [];
  List<User> activeChats = [];
  bool isLoading = false;

  // Chaîne de recherche pour filtrer les discussions
  String _searchQuery = '';

  String get searchQuery => _searchQuery;

  // Obtenir la liste filtrée
  List<User> get filteredActiveChats {
    if (_searchQuery.trim().isEmpty) {
      return activeChats;
    }
    final query = _searchQuery.toLowerCase().trim();
    return activeChats.where((user) {
      return user.firstName.toLowerCase().contains(query) ||
          user.lastName.toLowerCase().contains(query);
    }).toList();
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Stockage de l'historique des messages par ID d'utilisateur
  final Map<int, List<ChatMessage>> _messages = {};

  Future fetchUser() async {
    isLoading = true;
    notifyListeners();
    try {
      users = await serviceApi.getUsers();
      if (activeChats.isEmpty && users.isNotEmpty) {
        // Initialiser avec les 3 premiers utilisateurs par défaut
        activeChats = users.take(3).toList();
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void addActiveChat(User user) {
    if (!activeChats.any((u) => u.id == user.id)) {
      activeChats.add(user);
      notifyListeners();
    }
  }

  // Stockage de l'état "En train d'écrire..." pour chaque utilisateur
  final Map<int, bool> _typingStates = {};

  bool isTyping(int userId) => _typingStates[userId] ?? false;

  void setTyping(int userId, bool typing) {
    _typingStates[userId] = typing;
    notifyListeners();
  }

  // Récupérer l'historique d'un utilisateur (génère des messages de départ si vide)
  List<ChatMessage> getMessagesForUser(int userId) {
    if (!_messages.containsKey(userId)) {
      _messages[userId] = [
        ChatMessage(
          userId: userId,
          text: "Salut ! Comment ça va ?",
          isMe: false,
          timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
        ),
        ChatMessage(
          userId: userId,
          text: "Hello, ça va super et toi ?",
          isMe: true,
          timestamp: DateTime.now().subtract(const Duration(minutes: 8)),
        ),
        ChatMessage(
          userId: userId,
          text: "Bien merci ! Tu fais quoi de beau ?",
          isMe: false,
          timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        ),
      ];
    }
    return _messages[userId]!;
  }

  // Générer une réponse réaliste selon le contenu saisi par l'utilisateur
  String _generateRealisticResponse(String userMessage) {
    final query = userMessage.toLowerCase().trim();

    if (query.contains("bonjour") || query.contains("salut") || query.contains("hello") || query.contains("cc") || query.contains("hey")) {
      return "Bonjour ! Comment puis-je vous aider aujourd'hui avec votre comptabilité ou votre dossier fiscal sur expertycompt ? 💼";
    }

    if (query.contains("compta") || query.contains("comptabilité") || query.contains("facture") || 
        query.contains("tva") || query.contains("impot") || query.contains("bilan") || query.contains("déclaration")) {
      return "Concernant cet aspect comptable, pensez à bien uploader tous les justificatifs (factures d'achats/ventes) correspondants sur expertycompt pour que nous puissions valider les écritures. 📊";
    }

    // Vérifier si le message ne contient que des émojis
    final emojiRegex = RegExp(r'^[\u2000-\u3300\ud83c-\udfff\ud83d-\udfff\ud83e-\udfff\s]+$');
    if (emojiRegex.hasMatch(userMessage)) {
      return "Haha, j'adore cette réaction ! 😄 Des questions sur vos bilans ou prévisionnels aujourd'hui ?";
    }

    // Réponses aléatoires réalistes sur la compta
    final responses = [
      "Bien reçu ! N'oubliez pas que la date limite de soumission de vos pièces pour la déclaration de TVA approche. ⏰",
      "Entendu, merci pour ces précisions. Je mets à jour votre dossier sur expertycompt. 👍",
      "C'est noté. Avez-vous besoin que je génère une simulation ou un état financier intermédiaire ?",
      "Très bien. Pensez à vérifier que la facture est bien conforme aux normes d'expertycompt avant de la valider. 🔎"
    ];

    return responses[DateTime.now().millisecond % responses.length];
  }

  // Envoyer un message et déclencher une réponse automatique simulée
  void sendMessage(int userId, String text) {
    if (text.trim().isEmpty) return;

    final list = getMessagesForUser(userId);
    list.add(ChatMessage(
      userId: userId,
      text: text.trim(),
      isMe: true,
      timestamp: DateTime.now(),
    ));
    notifyListeners();

    // Déclencher "En train d'écrire..." après 800ms
    Future.delayed(const Duration(milliseconds: 800), () {
      setTyping(userId, true);

      // Répondre après 1.5s supplémentaire (2.3s de délai total)
      Future.delayed(const Duration(milliseconds: 1500), () {
        setTyping(userId, false);
        final replyText = _generateRealisticResponse(text);
        list.add(ChatMessage(
          userId: userId,
          text: replyText,
          isMe: false,
          timestamp: DateTime.now(),
        ));
        notifyListeners();
      });
    });
  }

  // Envoyer un message contenant une image
  void sendImageMessage(int userId, String imagePath) {
    if (imagePath.isEmpty) return;

    final list = getMessagesForUser(userId);
    list.add(ChatMessage(
      userId: userId,
      text: "",
      isMe: true,
      timestamp: DateTime.now(),
      imagePath: imagePath,
    ));
    notifyListeners();

    // Déclencher "En train d'écrire..." après 800ms
    Future.delayed(const Duration(milliseconds: 800), () {
      setTyping(userId, true);

      // Répondre après 1.5s supplémentaire
      Future.delayed(const Duration(milliseconds: 1500), () {
        setTyping(userId, false);
        list.add(ChatMessage(
          userId: userId,
          text: "J'ai bien reçu votre document/image ! 📸 Je l'intègre immédiatement à vos pièces comptables sur expertycompt.",
          isMe: false,
          timestamp: DateTime.now(),
        ));
        notifyListeners();
      });
    });
  }
}