// import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:spacesurvival/game/bullet.dart';

class BulletFire extends Component with HasGameRef {
  late Timer timer;
  SpriteSheet spriteSheet;
  Vector2 firePoint;
  // Random random = Random();

  BulletFire({required this.spriteSheet, required this.firePoint}) : super() {
    timer = Timer(
      0.3,
      onTick: _fireBullet,
      repeat: true,
      autoStart: true,
    );
  }

  void _fireBullet() {
    Vector2 initialSize = Vector2(64, 64);

    // Vector2 position = Vector2(random.nextDouble() * gameRef.size.x, 0);
    // position.clamp(
    //     Vector2.zero() + initialSize / 2, gameRef.size - initialSize / 2);

    Bullet bullet = Bullet(
      sprite: spriteSheet.getSpriteById(28),
      size: initialSize,
      position: firePoint,
      level: 1,
    );
    bullet.anchor = Anchor.center;
    gameRef.add(bullet);
  }

  @override
  void onRemove() {
    super.onRemove();
    timer.stop();
  }

  @override
  void update(double dt) {
    super.update(dt);
    timer.update(dt);
  }
}
