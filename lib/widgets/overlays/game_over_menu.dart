import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:spacesurvival/game/game.dart';
import 'package:spacesurvival/game/routes.dart';
import 'package:spacesurvival/widgets/overlays/pause_button.dart';
// import 'package:spacesurvival/game/game.dart';

class GameOverMenu extends StatelessWidget {
  static const String id = 'GameOverMenu';
  final SpaceSurvivalGame gameRef;

  const GameOverMenu({super.key, required this.gameRef});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 50),
            child: Text(
              'Game Over',
              style: TextStyle(
                fontSize: 35,
                color: Colors.black,
                shadows: [
                  Shadow(
                      blurRadius: 30, color: Colors.white, offset: Offset(0, 0))
                ],
              ),
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width / 3,
            child: ElevatedButton(
                onPressed: () {
                  gameRef.overlays.remove(GameOverMenu.id);
                  gameRef.overlays.add(PauseButton.id);
                  gameRef.reset();
                  gameRef.resumeEngine();
                },
                child: const Text('Restart')),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width / 3,
            child: ElevatedButton(
                onPressed: () {
                  gameRef.overlays.remove(GameOverMenu.id);
                  gameRef.resumeEngine();
                  gameRef.reset();
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil(mainMenuRoute, (route) => false);
                },
                child: const Text('Exit')),
          ),
        ],
      ),
    );
  }
}
