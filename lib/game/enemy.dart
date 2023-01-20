import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/palette.dart';
import 'package:flame/particles.dart';
import 'package:flutter/painting.dart';
import 'package:spacesurvival/game/bullet.dart';
import 'package:spacesurvival/game/command.dart';
import 'package:spacesurvival/game/game.dart';
import 'package:spacesurvival/game/player.dart';
import 'package:spacesurvival/models/enemy_data.dart';

class Enemy extends SpriteComponent
    with HasGameRef<SpaceSurvivalGame>, CollisionCallbacks {
  late double _speed;
  final Random _random = Random();
  Vector2 moveDirection = Vector2(0, 1);
  late Timer _freezeTimer;
  final EnemyData enemyData;
  RectangleComponent? _enemyHealthBar;
  late int _hitPoints;

  Vector2 getRandomVector() =>
      (Vector2.random(_random) - Vector2.random(_random)) * 500;

  Vector2 getRandomDirection() =>
      (Vector2.random(_random) - Vector2(0.5, -1).normalized());

  Enemy({
    required Sprite? sprite,
    required this.enemyData,
    required Vector2? position,
    required Vector2? size,
  }) : super(
          sprite: sprite,
          position: position,
          size: size,
        ) {
    angle = pi;
    _speed = enemyData.speed;
    _freezeTimer = Timer(2, onTick: () {
      _speed = enemyData.speed;
    }, autoStart: false);
    _hitPoints = enemyData.level * 10;

    if (enemyData.hMove) {
      moveDirection = getRandomDirection();
    }
  }

  @override
  Future<void>? onLoad() async {
    await super.onLoad();

    // debugMode = true;
  }

  @override
  void onMount() {
    super.onMount();
    add(CircleHitbox(
      anchor: Anchor.center,
      position: size / 2,
      radius: size.x * .4,
    ));
    // add(_hpText);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_hitPoints <= 0) {
      destroy();
    }

    _freezeTimer.update(dt);
    position += moveDirection * _speed * dt;

    if (position.y > gameRef.size.y + size.y / 2) {
      removeFromParent();
    } else if ((position.x > gameRef.size.x - size.x / 2) ||
        (position.x < size.x / 2)) {
      moveDirection.x *= -1;
    }
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Bullet) {
      _hitPoints -= other.level * 10;

      RectangleComponent? healthBar;
      if (healthBar == null) {
        healthBar = RectangleComponent(
          anchor: Anchor.topRight,
          position: size,
          size: Vector2(size.x, 10),
          paint: BasicPalette.darkGray.withAlpha(50).paint(),
        );
        add(healthBar);
      }

      if (_enemyHealthBar != null) {
        remove(_enemyHealthBar!);
        remove(healthBar);
      }

      _enemyHealthBar = RectangleComponent(
        anchor: Anchor.topRight,
        position: size,
        size: Vector2(size.x * _hitPoints / (enemyData.level * 10), 10),
        paint: BasicPalette.red.withAlpha(150).paint(),
      );
      add(_enemyHealthBar!);
    } else if (other is Player) {
      _hitPoints = 0;
    }
  }

  void destroy() {
    removeFromParent();

    final command = Command<Player>(action: (player) {
      player.addToScore(enemyData.killPoint);
    });

    gameRef.addCommand(command);

    final particleComponent = ParticleSystemComponent(
        particle: Particle.generate(
      generator: ((p0) => AcceleratedParticle(
            acceleration: getRandomVector(),
            speed: getRandomVector(),
            position: (position.clone()),
            child: CircleParticle(
              paint: Paint()..color = const Color.fromARGB(99, 223, 213, 213),
              radius: 2,
            ),
          )),
      count: 100,
      lifespan: 0.1,
    ));
    gameRef.add(particleComponent);
  }

  void freeze() {
    _speed = 0;
    _freezeTimer.stop();
    _freezeTimer.start();
  }
}
