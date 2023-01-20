import 'package:flame/game.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';

import 'package:spacesurvival/game/game.dart';
import 'package:spacesurvival/widgets/overlays/game_over_menu.dart';
import 'package:spacesurvival/widgets/overlays/pause_button.dart';
import 'package:spacesurvival/widgets/overlays/pause_menu.dart';

SpaceSurvivalGame _spaceSurvivalGame = SpaceSurvivalGame();

class GamePlay extends StatelessWidget {
  const GamePlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        onWillPop: () async => false,
        child: GameWidget(
          game: _spaceSurvivalGame,
          initialActiveOverlays: const [PauseButton.id],
          overlayBuilderMap: {
            PauseButton.id: (BuildContext context, SpaceSurvivalGame gameRef) =>
                PauseButton(gameRef: gameRef),
            PauseMenu.id: (BuildContext context, SpaceSurvivalGame gameRef) =>
                PauseMenu(gameRef: gameRef),
            GameOverMenu.id:
                (BuildContext context, SpaceSurvivalGame gameRef) =>
                    GameOverMenu(gameRef: gameRef),
          },
        ),
      ),
    );
  }
}
