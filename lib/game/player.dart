import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flutter/painting.dart';
import 'package:provider/provider.dart';
import 'package:spacesurvival/game/bullet.dart';
import 'package:spacesurvival/game/enemy.dart';
import 'dart:math';
import 'package:spacesurvival/game/game.dart';
import 'package:spacesurvival/models/player_data.dart';
import 'package:spacesurvival/models/spaceship_details.dart';

class Player extends SpriteComponent
    with HasGameRef<SpaceSurvivalGame>, CollisionCallbacks {
  Vector2 _moveDirection = Vector2.zero();
  final Random _random = Random();

  int _health = 100;

  SpaceshipType spaceshipType;
  Spaceship _spaceship;
  late Timer _powerUpTimer;
  bool _shootMultipleBullets = false;

  int get health => _health;

  late PlayerData _playerData;
  int get score => _playerData.currentScore;
  Vector2 getRandomVector() =>
      (Vector2.random(_random) - Vector2(0.5, -1)) * 300;

  Player({
    Sprite? sprite,
    Vector2? position,
    Vector2? size,
    required this.spaceshipType,
  })  : _spaceship = Spaceship.getSpaceshipByType(spaceshipType),
        super(
          sprite: sprite,
          position: position,
          size: size,
        ) {
    _powerUpTimer = Timer(
      4,
      onTick: () {
        _shootMultipleBullets = false;
      },
      autoStart: true,
    );
  }

  @override
  Future<void>? onLoad() async {
    await super.onLoad();

    add(
      CircleHitbox(
        radius: size.x * .4,
        anchor: Anchor.center,
        position: size / 2,
      ),
    );
    // debugMode = true;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _powerUpTimer.update(dt);
    position += _moveDirection.normalized() * _spaceship.speed * dt;
    position.clamp(Vector2.zero() + size / 2, gameRef.size - size / 2);

//final particleComponent =

    ParticleSystemComponent engine(double a, double b) =>
        ParticleSystemComponent(
            particle: Particle.generate(
          generator: ((p0) => AcceleratedParticle(
                acceleration: getRandomVector(),
                speed: getRandomVector(),
                position: (position.clone() + Vector2(a, b)),
                child: CircleParticle(
                  paint: Paint()
                    ..color = const Color.fromARGB(99, 223, 213, 213),
                  radius: 1,
                ),
              )),
          count: 20,
          lifespan: 0.1,
        ));

    gameRef.add(engine(-size.x / 5, size.y / 6));
    gameRef.add(engine(size.x / 5, size.y / 6));
    gameRef.add(engine(0, 0));
  }

  void setMoveDirection(Vector2 newMoveDirection) {
    _moveDirection = newMoveDirection;
  }

  @override
  void onMount() {
    _playerData = Provider.of<PlayerData>(gameRef.buildContext!, listen: false);
    super.onMount();
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Enemy) {
      gameRef.camera.shake(intensity: 10);

      _health -= 10;
      if (_health <= 0) {
        _health = 0;
      }
    }
  }

  void addToScore(int points) {
    _playerData.currentScore += points;
    _playerData.money += points;
    _playerData.save();
  }

  void reset() {
    _playerData.currentScore = 0;
    _health = 100;
    position = Vector2(gameRef.size.x / 2, gameRef.size.y * .65);
  }

  void setSpaceshipType(SpaceshipType spaceshipType) {
    this.spaceshipType = spaceshipType;
    _spaceship = Spaceship.getSpaceshipByType(spaceshipType);
    sprite = gameRef.spriteSheet.getSpriteById(_spaceship.spriteId);
  }

  void increaseHealthBy(int points) {
    _health += points;
    if (_health > 100) {
      _health = 100;
    }
  }

  void fire() {
    Bullet bullet = Bullet(
        sprite: gameRef.spriteSheet.getSpriteById(28),
        size: Vector2(64, 64),
        position: absolutePosition.clone(),
        level: _spaceship.level);
    bullet.anchor = Anchor.center;
    gameRef.add(bullet);

    if (_shootMultipleBullets == true) {
      for (int i = -1; i < 2; i += 2) {
        Bullet bullet = Bullet(
            sprite: gameRef.spriteSheet.getSpriteById(28),
            size: Vector2(64, 64),
            position: absolutePosition.clone(),
            level: _spaceship.level);
        bullet.anchor = Anchor.center;
        bullet.direction.rotate(i * pi / 9);
        gameRef.add(bullet);
      }
    }
  }

  void shootMultipleBullets() {
    _shootMultipleBullets = true;
    _powerUpTimer.stop();
    _powerUpTimer.start();
  }
}
