// import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/palette.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spacesurvival/game/bullet.dart';
import 'package:spacesurvival/game/command.dart';
import 'package:spacesurvival/game/enemy.dart';
import 'package:spacesurvival/game/enemy_manager.dart';
import 'package:spacesurvival/game/knows_game_size.dart';
import 'package:spacesurvival/game/player.dart';
import 'package:spacesurvival/game/power_up_manager.dart';
import 'package:spacesurvival/game/power_ups.dart';
import 'package:spacesurvival/models/player_data.dart';
import 'package:spacesurvival/models/spaceship_details.dart';
import 'package:spacesurvival/widgets/overlays/game_over_menu.dart';
import 'package:spacesurvival/widgets/overlays/pause_button.dart';
import 'package:spacesurvival/widgets/overlays/pause_menu.dart';

class SpaceSurvivalGame extends FlameGame
    with KnowsGameSize, HasDraggables, HasTappables, HasCollisionDetection {
  late Player _player;
  late SpriteSheet _spriteSheet;
  late EnemyManager _enemyManager;
  late PowerUpManager _powerUpManager;
  late TextComponent _playerScore;
  late TextComponent _playerHealth;
  late JoystickComponent joystick;
  late HudButtonComponent fireButton;
  late HudButtonComponent missilesButton;
  final _commandList = List<Command>.empty(growable: true);
  final _addLaterCommandList = List<Command>.empty(growable: true);

  SpriteSheet get spriteSheet => _spriteSheet;

  bool _isAlreadyLoaded = false;

  @override
  Future<void> onLoad() async {
    if (!_isAlreadyLoaded) {
      await images.loadAll([
        'kenney_simplespace/Tilesheet/simpleSpace_tilesheet.png',
        'kenney_simplespace/icon_freeze.png',
        'kenney_simplespace/icon_multishot.png',
        'kenney_simplespace/icon_nuke.png',
        'kenney_simplespace/icon_plusSmall.png',
      ]);

      _spriteSheet = SpriteSheet.fromColumnsAndRows(
        image: images.fromCache(
            'kenney_simplespace/Tilesheet/simpleSpace_tilesheet.png'),
        columns: 8,
        rows: 6,
      );

      _playerScore = TextComponent(
          text: 'Score: 0',
          position: Vector2(10, 10),
          textRenderer: TextPaint(
              style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontFamily: 'Zen_Dots',
          )));

      add(_playerScore);

      _playerHealth = TextComponent(
          text: 'HP: 100%',
          position: Vector2(size.x * .50, size.y * .97),
          textRenderer: TextPaint(
              style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Zen_Dots',
          )));

      _playerHealth.anchor = Anchor.bottomCenter;

      // _playerHealth. = true;

      add(_playerHealth);

      const spaceType = SpaceshipType.canary;
      final spaceship = Spaceship.getSpaceshipByType(spaceType);
      _player = Player(
        spaceshipType: spaceType,
        sprite: _spriteSheet.getSpriteById(spaceship.spriteId),
        size: Vector2(64, 64),
        position: Vector2(size.x / 2, size.y * .65),
      );

      _player.anchor = Anchor.center;
      add(_player);

      _enemyManager = EnemyManager(spriteSheet: _spriteSheet);
      add(_enemyManager);

      _powerUpManager = PowerUpManager(spriteSheet: _spriteSheet);
      add(_powerUpManager);

      // debugMode = true;
      joystick = JoystickComponent(
        knob: CircleComponent(
          radius: 25,
          paint: BasicPalette.darkGray.withAlpha(200).paint(),
        ),
        background: CircleComponent(
          radius: 50,
          paint: BasicPalette.darkGray.withAlpha(100).paint(),
        ),
        margin: const EdgeInsets.only(left: 50, bottom: 100),
      );

      fireButton = HudButtonComponent(
        button: CircleComponent(
          radius: 25,
          paint: BasicPalette.darkGray.withAlpha(200).paint(),
        ),
        margin: const EdgeInsets.only(right: 90, bottom: 120),
      );

      missilesButton = HudButtonComponent(
        button: CircleComponent(
          radius: 25,
          paint: BasicPalette.red.withAlpha(200).paint(),
        ),
        margin: const EdgeInsets.only(right: 30, bottom: 120),
      );

      add(joystick);
      add(fireButton);
      // add(missilesButton);

      // final nuke = MultiShot(
      //   size: Vector2(64, 64),
      //   position: Vector2(size.x / 2, size.y * .65 + 150),
      // );
      // add(nuke);
      _isAlreadyLoaded = true;
    }
  }

  @override
  void onAttach() {
    if (buildContext != null) {
      final playerData = Provider.of<PlayerData>(buildContext!, listen: false);
      _player.setSpaceshipType(playerData.spaceshipType);
    }
    super.onAttach();
  }

  @override
  void update(double dt) {
    super.update(dt);

    for (var command in _commandList) {
      for (var component in children) {
        command.run(component);
      }
    }

    _commandList.clear();
    _commandList.addAll(_addLaterCommandList);
    _addLaterCommandList.clear();

    _playerScore.text = 'Score: ${_player.score}';
    _playerHealth.text = 'HP: ${_player.health} %';

    _player.position.add(joystick.relativeDelta * 300 * dt);

    fireButton.onPressed = () {
      _player.fire();
    };

    missilesButton.onPressed = () {
      final command = Command<Enemy>(action: (enemy) {
        enemy.destroy();
      });
      addCommand(command);
    };

    if (_player.health <= 0 && !camera.shaking) {
      pauseEngine();
      overlays.remove(PauseButton.id);
      overlays.add(GameOverMenu.id);
    }
  }

  @override
  void lifecycleStateChange(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        // TODO: Handle this case.
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        if (_player.health > 0) {
          pauseEngine();
          overlays.remove(PauseButton.id);
          overlays.add(PauseMenu.id);
        }
        break;
    }
    super.lifecycleStateChange(state);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    canvas.drawRect(
      Rect.fromLTWH(size.x * .1, size.y * .949, size.x * .8, size.y * .02),
      BasicPalette.darkGray.withAlpha(50).paint(),
    );

    final Paint paint;
    if (_player.health <= 20) {
      paint = BasicPalette.red.withAlpha(100).paint();
    } else if (_player.health > 50) {
      paint = BasicPalette.green.withAlpha(100).paint();
    } else {
      paint = BasicPalette.yellow.withAlpha(100).paint();
    }

    canvas.drawRect(
      Rect.fromLTWH(size.x * .1, size.y * .949,
          size.x * .8 * _player.health / 100, size.y * .02),
      paint,
    );
  }

  void addCommand(Command command) {
    _addLaterCommandList.add(command);
  }

  void reset() {
    _player.reset();
    _enemyManager.reset();
    _powerUpManager.reset();

    children.whereType<Enemy>().forEach((element) {
      element.removeFromParent();
    });

    children.whereType<Bullet>().forEach((element) {
      element.removeFromParent();
    });
    children.whereType<PowerUps>().forEach((element) {
      element.removeFromParent();
    });
  }
}
