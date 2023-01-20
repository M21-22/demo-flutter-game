import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:spacesurvival/game/enemy.dart';
import 'package:spacesurvival/game/power_ups.dart';

enum PowerUpTypes { health, nuke, freeze, multiShot }

class PowerUpManager extends Component with HasGameRef {
  late Timer _spawnTimer;
  late Timer _freezeTimer;

  // set timer(Timer timer) {
  //   _spawnTimer = timer;
  // }

  static final Map<PowerUpTypes,
      PowerUps Function(Vector2 position, Vector2 size)> _powerUpMap = {
    PowerUpTypes.health: ((position, size) => Health(
          position: position,
          size: size,
        )),
    PowerUpTypes.freeze: ((position, size) => Freeze(
          position: position,
          size: size,
        )),
    PowerUpTypes.nuke: ((position, size) => Nuke(
          position: position,
          size: size,
        )),
    PowerUpTypes.multiShot: ((position, size) => MultiShot(
          position: position,
          size: size,
        )),
  };

  SpriteSheet spriteSheet;
  Random random = Random();

  PowerUpManager({required this.spriteSheet}) : super() {
    _spawnTimer = Timer(
      5,
      onTick: _spawnPowerUp,
      repeat: true,
      autoStart: true,
    );
    _freezeTimer = Timer(
      2,
      onTick: () {
        _spawnTimer.start();
      },
      autoStart: false,
    );
  }

  void _spawnPowerUp() {
    Vector2 initialSize = Vector2(64, 64);

    Vector2 position = Vector2(
      random.nextDouble() * gameRef.size.x,
      random.nextDouble() * gameRef.size.y,
    );
    position.clamp(
      Vector2.zero() + initialSize / 2,
      gameRef.size - initialSize / 2,
    );
    position.y -= initialSize.y;

    int randomIndex = random.nextInt(PowerUpTypes.values.length);
    final fn = _powerUpMap[PowerUpTypes.values.elementAt(randomIndex)];

    var powerUp = fn?.call(position, initialSize);

    powerUp?.anchor = Anchor.center;
    if (powerUp != null) {
      gameRef.add(powerUp);
    }
  }

  @override
  void onRemove() {
    super.onRemove();
    _spawnTimer.stop();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _spawnTimer.update(dt);
    _freezeTimer.update(dt);
  }

  void reset() {
    _spawnTimer.stop();
    _spawnTimer.start();
  }

  void freeze() {
    _spawnTimer.stop();
    _freezeTimer.stop();
    _freezeTimer.start();
  }
}
