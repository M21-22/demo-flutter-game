import 'package:flutter/material.dart';
import 'package:spacesurvival/game/game.dart';
import 'package:spacesurvival/widgets/overlays/pause_menu.dart';

class PauseButton extends StatelessWidget {
  const PauseButton({super.key, required this.gameRef});

  static const String id = 'PauseButton';
  final SpaceSurvivalGame gameRef;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: TextButton(
        child: Icon(
          Icons.pause_rounded,
          color: Colors.white,
        ),
        onPressed: () {
          gameRef.pauseEngine();
          gameRef.overlays.add(PauseMenu.id);
          gameRef.overlays.remove(PauseButton.id);
        },
      ),
    );
  }
}
