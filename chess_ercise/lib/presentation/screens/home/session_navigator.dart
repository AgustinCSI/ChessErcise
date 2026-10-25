import 'package:flutter/material.dart';

import 'home_screen.dart';

// Al terminar la sesión se destruye también la pila de pantallas privadas.
class SessionNavigator extends StatefulWidget {
  const SessionNavigator({super.key});

  @override
  State<SessionNavigator> createState() => _SessionNavigatorState();
}

class _SessionNavigatorState extends State<SessionNavigator> {
  final _navigator = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) => NavigatorPopHandler<void>(
    onPopWithResult: (_) => _navigator.currentState!.pop(),
    child: Navigator(
      key: _navigator,
      onGenerateRoute: (_) =>
          MaterialPageRoute<void>(builder: (_) => const HomeScreen()),
    ),
  );
}
