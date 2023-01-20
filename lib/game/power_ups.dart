import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:spacesurvival/game/command.dart';
import 'package:spacesurvival/game/enemy.dart';
import 'package:spacesurvival/game/enemy_manager.dart';
import 'package:spacesurvival/game/game.dart';
import 'package:spacesurvival/game/player.dart';
import 'package:spacesurvival/game/power_up_manager.dart';

abstract class PowerUps extends SpriteComponent
    with HasGameRef<SpaceSurvivalGame>, CollisionCallbacks {
  late Timer _timer;

  Sprite getSprite();
  void onActivated();

  PowerUps({
    Vector2? position,
    Vector2? size,
    Sprite? sprite,
  }) : super(
          position: position,
          size: size,
          sprite: sprite,
        ) {
    _timer = Timer(3, onTick: removeFromParent, autoStart: false);
  }

  @override
  void update(double dt) {
    _timer.update(dt);
    super.update(dt);
  }

  @override
  Future<void>? onLoad() async {
    await super.onLoad();
  }

  @override
  void onMount() {
    sprite = getSprite();

    add(CircleHitbox(
      anchor: Anchor.center,
      position: size / 2,
      radius: size.x * .5,
    ));
    _timer.start();
    super.onMount();
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Player) {
      onActivated();
      removeFromParent();
    }

    super.onCollisionStart(intersectionPoints, other);
  }
}

class Nuke extends PowerUps {
  Nuke({Vector2? position, Vector2? size})
      : super(
          position: position,
          size: size,
        );

  @override
  Sprite getSprite() =>
      Sprite(gameRef.images.fromCache('kenney_simplespace/icon_nuke.png'));

  @override
  void onActivated() {
    final command = Command<Enemy>(action: (enemy) {
      enemy.destroy();
    });
    gameRef.addCommand(command);
  }
}

class Health extends PowerUps {
  Health({Vector2? position, Vector2? size})
      : super(
          position: position,
          size: size,
        );

  @override
  Sprite getSprite() =>
      Sprite(gameRef.images.fromCache('kenney_simplespace/icon_plusSmall.png'));

  @override
  void onActivated() {
    final command = Command<Player>(action: (player) {
      player.increaseHealthBy(10);
    });
    gameRef.addCommand(command);
  }
}

class Freeze extends PowerUps {
  Freeze({Vector2? position, Vector2? size})
      : super(
          position: position,
          size: size,
        );

  @override
  Sprite getSprite() =>
      Sprite(gameRef.images.fromCache('kenney_simplespace/icon_freeze.png'));

  @override
  void onActivated() {
    final command1 = Command<Enemy>(action: (enemy) {
      enemy.freeze();
    });
    gameRef.addCommand(command1);

    final command2 = Command<EnemyManager>(action: (enemyManager) {
      enemyManager.freeze();
    });
    gameRef.addCommand(command2);

    final command3 = Command<PowerUpManager>(action: (powerUpManager) {
      powerUpManager.freeze();
    });
    gameRef.addCommand(command3);
  }
}

class MultiShot extends PowerUps {
  MultiShot({Vector2? position, Vector2? size})
      : super(
          position: position,
          size: size,
        );

  @override
  Sprite getSprite() =>
      Sprite(gameRef.images.fromCache('kenney_simplespace/icon_multishot.png'));

  @override
  void onActivated() {
    final command = Command<Player>(action: (player) {
      player.shootMultipleBullets();
    });
    gameRef.addCommand(command);
  }
}
