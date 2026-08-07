import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:whats_app_flutter/provider/user_provider.dart';
import 'package:whats_app_flutter/model/user.dart';
import 'package:whats_app_flutter/view/menu_tab/detail.dart';

class Chat extends StatefulWidget {
  const Chat({super.key});

  static void showAddContactBottomSheet(BuildContext context, UserProvider provider) {
    final nonActiveUsers = provider.users
        .where((u) => !provider.activeChats.any((active) => active.id == u.id))
        .toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1F2C34),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "Ajouter un contact aux discussions",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                ),
              ),
              const Divider(color: Color(0xFF2F3B43)),
              if (nonActiveUsers.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Text(
                    "Tous les contacts de l'API sont déjà dans vos discussions.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF8696A0)),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: nonActiveUsers.length,
                    itemBuilder: (context, index) {
                      final user = nonActiveUsers[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(user.image),
                        ),
                        title: Text(
                          "${user.firstName} ${user.lastName}",
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(user.phone, style: const TextStyle(color: Color(0xFF8696A0))),
                        onTap: () {
                          provider.addActiveChat(user);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: const Color(0xFF00A884),
                              content: Text(
                                "${user.firstName} ${user.lastName} ajouté aux discussions actives.",
                                style: const TextStyle(color: Color(0xFF0B141A)),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  int _selectedFilterIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<UserProvider>().fetchUser();
      }
    });
  }

  List<User> _getFilteredChats(List<User> activeChats) {
    if (_selectedFilterIndex == 0) return activeChats;
    if (_selectedFilterIndex == 1) {
      // Non lues : simulation en filtrant les ID impairs
      return activeChats.where((u) => u.id % 2 != 0).toList();
    }
    if (_selectedFilterIndex == 2) {
      // Favoris : simulation en filtrant les ID pairs
      return activeChats.where((u) => u.id % 2 == 0).toList();
    }
    if (_selectedFilterIndex == 3) {
      // Groupes : vide pour l'instant dans ce modèle
      return [];
    }
    return activeChats;
  }

  @override
  Widget build(BuildContext context) {
    final List<String> nameBtn = ['Toutes', 'Non lues', 'Favoris', 'Groupes'];

    return Column(
      children: [
        // 1. Barre de recherche arrondie permanente sous l'appbar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF202C33),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                const SizedBox(width: 15),
                const Icon(Icons.search, color: Color(0xFF8696A0)),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: "Demander à Meta AI ou rechercher",
                      hintStyle: TextStyle(color: Color(0xFF8696A0), fontSize: 15),
                      border: InputBorder.none,
                    ),
                    onChanged: (value) {
                      context.read<UserProvider>().updateSearchQuery(value);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),

        // 2. Filtres stylisés en vert foncé (#00A884)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
          child: SizedBox(
            height: 38,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                ...List.generate(
                  nameBtn.length,
                  (index) {
                    final isSelected = index == _selectedFilterIndex;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedFilterIndex = index;
                          });
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF0A3326) : const Color(0xFF202C33),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? const Color(0xFF00A884) : Colors.transparent,
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              nameBtn[index],
                              style: TextStyle(
                                color: isSelected ? const Color(0xFF00A884) : const Color(0xFF8696A0),
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: InkWell(
                    onTap: () => Chat.showAddContactBottomSheet(
                      context,
                      context.read<UserProvider>(),
                    ),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF202C33),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.add, color: Color(0xFF8696A0), size: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // 3. Section des discussions archivées permanente
        if (_selectedFilterIndex == 0)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Padding(
                padding: EdgeInsets.only(left: 8.0),
                child: Icon(Icons.archive_outlined, color: Color(0xFF8696A0)),
              ),
              title: const Text(
                "Archivées",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              trailing: const Padding(
                padding: EdgeInsets.only(right: 8.0),
                child: Text(
                  "69",
                  style: TextStyle(color: Color(0xFF00A884), fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Discussions archivées (simulation)")),
                );
              },
            ),
          ),

        // 4. Liste des discussions actives dynamiques
        Expanded(
          child: Consumer<UserProvider>(
            builder: (context, value, child) {
              final rawChats = value.filteredActiveChats;
              final activeChats = _getFilteredChats(rawChats);

              if (value.isLoading && activeChats.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF00A884)),
                );
              }

              if (activeChats.isEmpty) {
                if (value.searchQuery.isNotEmpty) {
                  return const Center(
                    child: Text(
                      'Aucun résultat trouvé pour votre recherche',
                      style: TextStyle(color: Color(0xFF8696A0)),
                    ),
                  );
                }
                return const Center(
                  child: Text(
                    'Aucune discussion active',
                    style: TextStyle(color: Color(0xFF8696A0)),
                  ),
                );
              }

              return ListView.builder(
                itemCount: activeChats.length,
                itemBuilder: (context, index) {
                  final activeUser = activeChats[index];
                  final messages = value.getMessagesForUser(activeUser.id);
                  final lastMessage = messages.isNotEmpty ? messages.last : null;
                  final subtitleText = lastMessage != null ? lastMessage.text : activeUser.phone;
                  final isMe = lastMessage != null ? lastMessage.isMe : false;
                  final timeText = lastMessage != null
                      ? "${lastMessage.timestamp.hour.toString().padLeft(2, '0')}:${lastMessage.timestamp.minute.toString().padLeft(2, '0')}"
                      : "12:50";

                  return GestureDetector(
                    onLongPressStart: (_) {
                      showChatPreview(context, activeUser);
                    },
                    onLongPressEnd: (_) {
                      Navigator.of(context).pop();
                    },
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Detail(user: activeUser),
                        ),
                      );
                    },
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      leading: CircleAvatar(
                        radius: 26,
                        backgroundImage: NetworkImage(activeUser.image),
                      ),
                      title: Text(
                        "${activeUser.firstName} ${activeUser.lastName}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Row(
                          children: [
                            if (lastMessage != null && isMe) ...[
                              const Icon(
                                Icons.done_all,
                                color: Color(0xFF53BDEB),
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                            ],
                            Expanded(
                              child: Text(
                                subtitleText,
                                style: const TextStyle(color: Color(0xFF8696A0), fontSize: 14),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      trailing: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            timeText,
                            style: TextStyle(
                              color: (lastMessage != null && !isMe)
                                  ? const Color(0xFF00A884)
                                  : const Color(0xFF8696A0),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 6),
                          if (lastMessage != null && !isMe)
                            CircleAvatar(
                              radius: 10,
                              backgroundColor: const Color(0xFF00A884),
                              child: const Text(
                                "1",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF0B141A),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          else
                            const SizedBox(height: 20, width: 20),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

// Fonction pour afficher l'aperçu sous forme de bulle floutée
void showChatPreview(BuildContext context, User user) {
  HapticFeedback.mediumImpact();
  showDialog(
    context: context,
    barrierColor: const Color.fromRGBO(0, 0, 0, 0.5),
    builder: (context) {
      return _PreviewBubble(user: user);
    },
  );
}

// Classe de bulle d'aperçu de discussion (style WhatsApp)
class _PreviewBubble extends StatelessWidget {
  final User user;
  const _PreviewBubble({required this.user});

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            height: MediaQuery.of(context).size.height * 0.55,
            decoration: BoxDecoration(
              color: const Color(0xFF121B22),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFF222D34), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              children: [
                // En-tête de l'aperçu
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: const BoxDecoration(
                    color: Color(0xFF1F2C34),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(18),
                      topRight: Radius.circular(18),
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundImage: NetworkImage(user.image),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "${user.firstName} ${user.lastName}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(Icons.info_outline, color: Color(0xFF8696A0)),
                    ],
                  ),
                ),
                // Historique abrégé de la discussion
                Expanded(
                  child: Container(
                    color: const Color(0xFF0B141A),
                    child: Consumer<UserProvider>(
                      builder: (context, provider, child) {
                        final messages = provider.getMessagesForUser(user.id);
                        final lastMessages = messages.length > 5
                            ? messages.sublist(messages.length - 5)
                            : messages;

                        if (lastMessages.isEmpty) {
                          return const Center(
                            child: Text(
                              "Aucun message",
                              style: TextStyle(color: Color(0xFF8696A0)),
                            ),
                          );
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          itemCount: lastMessages.length,
                          itemBuilder: (context, index) {
                            final message = lastMessages[index];
                            final hasImage = message.imagePath != null && message.imagePath!.isNotEmpty;

                            return Align(
                              alignment: message.isMe ? Alignment.centerRight : Alignment.centerLeft,
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: message.isMe ? const Color(0xFF005C4B) : const Color(0xFF202C33),
                                  borderRadius: message.isMe
                                      ? const BorderRadius.only(
                                          topLeft: Radius.circular(8),
                                          bottomLeft: Radius.circular(8),
                                          topRight: Radius.circular(8),
                                        )
                                      : const BorderRadius.only(
                                          topRight: Radius.circular(8),
                                          bottomRight: Radius.circular(8),
                                          topLeft: Radius.circular(8),
                                        ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (hasImage) ...[
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(6),
                                        child: Image.file(
                                          File(message.imagePath!),
                                          width: 140,
                                          height: 140,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                    ],
                                    if (message.text.isNotEmpty) ...[
                                      Text(
                                        message.text,
                                        style: const TextStyle(fontSize: 14, color: Colors.white),
                                      ),
                                      const SizedBox(height: 2),
                                    ],
                                    Text(
                                      "${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}",
                                      style: const TextStyle(fontSize: 9, color: Color(0xFF8696A0)),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
                // Bas de l'aperçu
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Color(0xFF1F2C34),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(18),
                      bottomRight: Radius.circular(18),
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      "Relâchez pour fermer",
                      style: TextStyle(
                        color: Color(0xFF8696A0),
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
