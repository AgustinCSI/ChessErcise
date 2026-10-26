import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/puzzles_provider.dart';

import 'main_screen.dart';

// Al terminar la sesión se destruye también la pila de pantallas privadas.
class SessionNavigator extends StatefulWidget {
  const SessionNavigator({super.key, required this.userId});

  final String userId;

  @override
  State<SessionNavigator> createState() => _SessionNavigatorState();
}

class _SessionNavigatorState extends State<SessionNavigator>
    with WidgetsBindingObserver {
  final _navigator = GlobalKey<NavigatorState>();

  late final _puzzles = PuzzlesProvider(userId: widget.userId);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _puzzles.precargar();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _puzzles.precargar();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _puzzles.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider.value(
    value: _puzzles,
    child: NavigatorPopHandler<void>(
      onPopWithResult: (_) => _navigator.currentState!.pop(),
      child: Navigator(
        key: _navigator,
        onGenerateRoute: (_) =>
            MaterialPageRoute<void>(builder: (_) => const MainScreen()),
      ),
    ),
  );
}
