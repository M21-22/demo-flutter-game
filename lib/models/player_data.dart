import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';
import 'package:spacesurvival/models/spaceship_details.dart';

part 'player_data.g.dart';

@HiveType(typeId: 0)
class PlayerData extends ChangeNotifier with HiveObjectMixin {
  @HiveField(0)
  SpaceshipType spaceshipType;

  @HiveField(1)
  final List<SpaceshipType> ownedSpaceships;

  @HiveField(2)
  final int highScore;

  @HiveField(3)
  int money;

  int currentScore = 0;

  PlayerData({
    required this.spaceshipType,
    required this.ownedSpaceships,
    required this.money,
    required this.highScore,
  });

  PlayerData.fromMap(Map<String, dynamic> map)
      : spaceshipType = map['currentSpaceshipType'],
        ownedSpaceships = map['ownedSpaceshipTypes']
            .map((e) => e as SpaceshipType)
            .cast<SpaceshipType>()
            .toList(),
        highScore = map['highScore'],
        money = map['money'];

  static Map<String, dynamic> defaultData = {
    'currentSpaceshipType': SpaceshipType.canary,
    'ownedSpaceshipTypes': [],
    'highScore': 0,
    'money': 0,
  };

  bool isOwned(SpaceshipType spaceshipType) {
    return ownedSpaceships.contains(spaceshipType);
  }

  bool canBuy(SpaceshipType spaceshipType) {
    return money >= Spaceship.getSpaceshipByType(spaceshipType).cost;
  }

  bool isEquipped(SpaceshipType spaceshipType) {
    return (this.spaceshipType == spaceshipType);
  }

  void buy(SpaceshipType spaceshipType) {
    if (canBuy(spaceshipType) == true && !isOwned(spaceshipType)) {
      money -= Spaceship.getSpaceshipByType(spaceshipType).cost;
      ownedSpaceships.add(spaceshipType);
      notifyListeners();
      save();
    }
  }

  void equip(SpaceshipType spaceshipType) {
    this.spaceshipType = spaceshipType;
    notifyListeners();
    save();
  }
}
