import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:whats_app_flutter/provider/user_provider.dart';
import 'package:whats_app_flutter/view/menu_tab/appel.dart';
import 'package:whats_app_flutter/view/menu_tab/chat.dart';
import 'package:whats_app_flutter/view/menu_tab/groups.dart';
import 'package:whats_app_flutter/view/menu_tab/status.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int selectIndex = 0;

  final List<Widget> pageList = [
    const Chat(),
    const Status(),
    const Groups(),
    const Appel(),
  ];

  void onTapSelect(int index) {
    setState(() {
      selectIndex = index;
    });
  }

  Future<void> _openCamera() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.camera);
      if (image != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Photo prise : ${image.name}"),
            backgroundColor: const Color(0xFF00A884),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erreur d'ouverture de la caméra : $e"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0B141A),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0B141A),
          elevation: 0,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "OurChats0"00000000,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: Colors.white,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.camera_alt_outlined, color: Colors.white),
              onPressed: _openCamera,
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onSelected: (value) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Action sélectionnée : $value")),
                );
              },
              itemBuilder: (BuildContext context) {
                return [
                  "Nouveau groupe",
                  "Nouvelle diffusion",
                  "Appareils connectés",
                  "Messages importants",
                  "Paramètres",
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
        body: pageList.elementAt(selectIndex),
        bottomNavigationBar: NavigationBarTheme(
          data: NavigationBarThemeData(
            backgroundColor: const Color(0xFF0F1C24),
            indicatorColor: const Color(0xFF10352A),
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                );
              }
              return const TextStyle(color: Color(0xFF8696A0), fontSize: 12);
            }),
            iconTheme: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return const IconThemeData(color: Color(0xFFE9EDEF));
              }
              return const IconThemeData(color: Color(0xFF8696A0));
            }),
          ),
          child: NavigationBar(
            selectedIndex: selectIndex,
            onDestinationSelected: onTapSelect,
            destinations: const [
              NavigationDestination(
                icon: Badge(
                  label: Text("99+"),
                  backgroundColor: Color(0xFF00A884),
                  textColor: Color(0xFF0B141A),
                  child: Icon(Icons.chat_bubble_outline),
                ),
                selectedIcon: Badge(
                  label: Text("99+"),
                  backgroundColor: Color(0xFF00A884),
                  textColor: Color(0xFF0B141A),
                  child: Icon(Icons.chat_bubble),
                ),
                label: "Discussions",
              ),
              NavigationDestination(
                icon: Icon(Icons.donut_large_outlined),
                selectedIcon: Icon(Icons.donut_large),
                label: "Actus",
              ),
              NavigationDestination(
                icon: Icon(Icons.groups_outlined),
                selectedIcon: Icon(Icons.groups),
                label: "Communautés",
              ),
              NavigationDestination(
                icon: Badge(
                  label: Text("2"),
                  backgroundColor: Color(0xFF00A884),
                  textColor: Color(0xFF0B141A),
                  child: Icon(Icons.call_outlined),
                ),
                selectedIcon: Badge(
                  label: Text("2"),
                  backgroundColor: Color(0xFF00A884),
                  textColor: Color(0xFF0B141A),
                  child: Icon(Icons.call),
                ),
                label: "Appels",
              ),
            ],
          ),
        ),
        floatingActionButton: selectIndex == 0
            ? FloatingActionButton(
                backgroundColor: const Color(0xFF00A884),
                foregroundColor: const Color(0xFF0B141A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                onPressed: () {
                  final provider = Provider.of<UserProvider>(context, listen: false);
                  Chat.showAddContactBottomSheet(context, provider);
                },
                child: const Icon(Icons.chat_bubble),
              )
            : null,
      ),
    );
  }
}