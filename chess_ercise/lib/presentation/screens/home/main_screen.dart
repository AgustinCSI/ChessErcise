import 'package:chessground/chessground.dart';
import 'package:dartchess/dartchess.dart';
import 'package:flutter/material.dart';

import '../profile/profile_screen.dart';
import 'home_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _indice = 0;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: IndexedStack(
      index: _indice,
      children: const [HomeScreen(), ProfileScreen()],
    ),
    bottomNavigationBar: NavigationBar(
      selectedIndex: _indice,
      onDestinationSelected: (index) => setState(() => _indice = index),
      destinations: [
        NavigationDestination(
          label: 'Inicio',
          icon: Image(
            image: PieceSet
                .cburnett
                .assets[const Piece(color: Side.white, role: Role.king).kind]!,
            width: 28,
            height: 28,
          ),
        ),
        const NavigationDestination(
          label: 'Perfil',
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
        ),
      ],
    ),
  );
}
