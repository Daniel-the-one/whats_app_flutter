import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:whats_app_flutter/model/user.dart';
import 'package:whats_app_flutter/provider/user_provider.dart';

class Detail extends StatefulWidget {
  final User user;
  const Detail({super.key, required this.user});

  @override
  State<Detail> createState() => _DetailState();
}

class _DetailState extends State<Detail> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _showEmojiPicker = false;

  final List<String> _emojis = [
    "😀", "😃", "😄", "😁", "😆", "😅", "😂", "🤣", "😊", "😇",
    "🙂", "🙃", "😉", "😌", "😍", "🥰", "😘", "😗", "😙", "😚",
    "😋", "😛", "😝", "😜", "🤪", "🤨", "🧐", "🤓", "😎", "🥸",
    "🤩", "🥳", "😏", "😒", "😞", "😔", "😟", "😕", "🙁", "☹️",
    "😣", "😖", "😫", "😩", "🥺", "😢", "😭", "😤", "😠", "😡",
    "🤬", "🤯", "😳", "🥵", "🥶", "😱", "😨", "😰", "😥", "😓",
    "🤗", "🤔", "🫣", "🤭", "🤫", "🤥", "😶", "😐", "😑", "😬",
    "🫠", "🫥", "😴", "😷", "🤒", "🤕", "🤢", "🤮", "🤧", "🤠",
    "❤️", "👍", "👎", "👏", "🙌", "🔥", "✨", "🎉", "🌟", "💬"
  ];

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: source);
      if (image != null && mounted) {
        final provider = Provider.of<UserProvider>(context, listen: false);
        provider.sendImageMessage(widget.user.id, image.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur de sélection d'image : $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Déclencher le scroll vers le bas à chaque reconstruction (ex: nouveau message reçu/envoyé)
    _scrollToBottom();

    return Scaffold(
      backgroundColor: const Color(0xFFE5DDD5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF008069),
        foregroundColor: Colors.white,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage(widget.user.image),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${widget.user.firstName} ${widget.user.lastName}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Consumer<UserProvider>(
                    builder: (context, provider, child) {
                      final isTyping = provider.isTyping(widget.user.id);
                      return Text(
                        isTyping ? "En train d'écrire..." : "En ligne",
                        style: TextStyle(
                          fontSize: 11,
                          color: isTyping ? const Color(0xFF00A884) : Colors.white70,
                          fontWeight: isTyping ? FontWeight.bold : FontWeight.normal,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Appel vidéo lancé avec ${widget.user.firstName} (simulation)"),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Appel vocal lancé avec ${widget.user.firstName} (simulation)"),
                ),
              );
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Action de discussion : $value")),
              );
            },
            itemBuilder: (BuildContext context) {
              return [
                "Afficher le contact",
                "Médias, liens et docs",
                "Rechercher",
                "Discussions muettes",
                "Message temporaire",
                "Fond d'écran",
                "Plus",
              ].map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<UserProvider>(
              builder: (context, provider, child) {
                final messages = provider.getMessagesForUser(widget.user.id);
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final hasImage = message.imagePath != null && message.imagePath!.isNotEmpty;

                    return Align(
                      alignment: message.isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: message.isMe ? const Color(0xFFDCF8C6) : Colors.white,
                          borderRadius: message.isMe
                              ? const BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  bottomLeft: Radius.circular(12),
                                  topRight: Radius.circular(12),
                                )
                              : const BorderRadius.only(
                                  topRight: Radius.circular(12),
                                  bottomRight: Radius.circular(12),
                                  topLeft: Radius.circular(12),
                                ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color.fromRGBO(0, 0, 0, 0.06),
                              spreadRadius: 1,
                              blurRadius: 1,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (hasImage) ...[
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(message.imagePath!),
                                  width: 220,
                                  height: 220,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(height: 5),
                            ],
                            if (message.text.isNotEmpty) ...[
                              Text(
                                message.text,
                                style: const TextStyle(fontSize: 16, color: Colors.black87),
                              ),
                              const SizedBox(height: 5),
                            ],
                            Text(
                              "${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}",
                              style: const TextStyle(fontSize: 10, color: Colors.black54),
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromRGBO(0, 0, 0, 0.05),
                          spreadRadius: 1,
                          blurRadius: 1,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 5),
                        IconButton(
                          icon: Icon(
                            _showEmojiPicker ? Icons.keyboard : Icons.sentiment_satisfied_alt,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            if (_showEmojiPicker) {
                              FocusScope.of(context).requestFocus(FocusNode());
                            } else {
                              FocusScope.of(context).unfocus();
                            }
                            setState(() {
                              _showEmojiPicker = !_showEmojiPicker;
                            });
                          },
                        ),
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            decoration: const InputDecoration(
                              hintText: "Message",
                              border: InputBorder.none,
                            ),
                            onTap: () {
                              if (_showEmojiPicker) {
                                setState(() {
                                  _showEmojiPicker = false;
                                });
                              }
                            },
                            onSubmitted: (value) {
                              if (_controller.text.trim().isNotEmpty) {
                                final provider = Provider.of<UserProvider>(context, listen: false);
                                provider.sendMessage(widget.user.id, _controller.text);
                                _controller.clear();
                              }
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.attach_file, color: Colors.grey),
                          onPressed: () => _pickImage(ImageSource.gallery),
                        ),
                        IconButton(
                          icon: const Icon(Icons.camera_alt, color: Colors.grey),
                          onPressed: () => _pickImage(ImageSource.camera),
                        ),
                        const SizedBox(width: 5),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                GestureDetector(
                  onTap: () {
                    if (_controller.text.trim().isNotEmpty) {
                      final provider = Provider.of<UserProvider>(context, listen: false);
                      provider.sendMessage(widget.user.id, _controller.text);
                      _controller.clear();
                      if (_showEmojiPicker) {
                        setState(() {
                          _showEmojiPicker = false;
                        });
                      }
                    }
                  },
                  child: const CircleAvatar(
                    radius: 23,
                    backgroundColor: Color(0xFF008069),
                    child: Icon(Icons.send, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          if (_showEmojiPicker)
            Container(
              height: 220,
              color: const Color(0xFFE5DDD5),
              child: GridView.builder(
                padding: const EdgeInsets.all(8.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 8,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _emojis.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      final text = _controller.text;
                      final selection = _controller.selection;
                      final int start = selection.isValid ? selection.start : text.length;
                      final int end = selection.isValid ? selection.end : text.length;

                      final newText = text.replaceRange(start, end, _emojis[index]);
                      _controller.text = newText;
                      _controller.selection = TextSelection.fromPosition(
                        TextPosition(offset: start + _emojis[index].length),
                      );
                    },
                    child: Center(
                      child: Text(
                        _emojis[index],
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}