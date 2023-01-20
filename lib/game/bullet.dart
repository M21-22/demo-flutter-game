import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:spacesurvival/game/enemy.dart';

class Bullet extends SpriteComponent with CollisionCallbacks, HasGameRef {
  final double _speed = 450;
  Vector2 direction = Vector2(0, -1);
  final int level;

  Bullet({
    required Sprite? sprite,
    required Vector2? position,
    required Vector2? size,
    required this.level,
  }) : super(
          sprite: sprite,
          position: position,
          size: size,
        );

  @override
  Future<void>? onLoad() async {
    await super.onLoad();
    add(CircleHitbox(
      anchor: Anchor.center,
      position: size / 2,
      radius: size.x * .15,
    ));
    // debugMode = true;
  }

  @override
  void update(double dt) {
    super.update(dt);

    position += direction * _speed * dt;
    if (position.y < 0) {
      removeFromParent();
    }
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Enemy) {
      removeFromParent();
      // print('collision');
    }
  }

  // @override
  // void onMount() {
  //   super.onMount();

  //   final shape = CircleHitbox();
  //   // addhitbox();
  // }
}
