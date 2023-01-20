import 'package:flutter/material.dart';
import 'package:flutter_carousel_slider/carousel_slider.dart';
import 'package:provider/provider.dart';
import 'package:spacesurvival/game/routes.dart';
import 'package:spacesurvival/models/player_data.dart';
import 'package:spacesurvival/models/spaceship_details.dart';

class SelectSpaceship extends StatelessWidget {
  const SelectSpaceship({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 50),
              child: Text(
                'Select',
                style: TextStyle(
                  fontSize: 35,
                  color: Colors.black,
                  shadows: [
                    Shadow(
                        blurRadius: 20,
                        color: Colors.white,
                        offset: Offset(0, 0))
                  ],
                ),
              ),
            ),
            Consumer<PlayerData>(builder: ((context, playerData, child) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                      'Equipped ship: ${Spaceship.spaceships.keys.where((shiptype) => playerData.isEquipped(shiptype)).single.name}'),
                  Text('Money: ${playerData.money}'),
                ],
              );
            })),
            SizedBox(
              height: MediaQuery.of(context).size.height * .5,
              child: CarouselSlider.builder(
                slideBuilder: ((index) {
                  final spaceship =
                      Spaceship.spaceships.entries.elementAt(index).value;
                  return Column(
                    children: [
                      Image.asset(spaceship.assetPath),
                      Text(spaceship.name),
                      Text('Speed: ${spaceship.speed}'),
                      Text('Level: ${spaceship.level}'),
                      Text('Cost: ${spaceship.cost}'),
                      Consumer<PlayerData>(
                          builder: (context, playerData, child) {
                        final type =
                            Spaceship.spaceships.entries.elementAt(index).key;
                        final isEquipped = playerData.isEquipped(type);
                        final isOwned = playerData.isOwned(type);
                        final canBuy = playerData.canBuy(type);
                        return ElevatedButton(
                          onPressed: isEquipped
                              ? null
                              : () {
                                  isOwned
                                      ? playerData.equip(type)
                                      : canBuy
                                          ? playerData.buy(type)
                                          : showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  backgroundColor: Colors.red,
                                                  title: const Text(
                                                    'Not enough money',
                                                    textAlign: TextAlign.center,
                                                  ),
                                                  content: Text(
                                                    'Need ${spaceship.cost - playerData.money} more coins',
                                                    textAlign: TextAlign.center,
                                                  ),
                                                );
                                              },
                                            );
                                },
                          child: Text(isEquipped
                              ? 'Equipped'
                              : isOwned
                                  ? 'Select'
                                  : 'Buy'),
                        );
                      })
                    ],
                  );
                }),
                itemCount: Spaceship.spaceships.length,
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width / 3,
              child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      startRoute,
                      (route) => false,
                    );
                  },
                  child: const Text('Start')),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width / 3,
              child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      mainMenuRoute,
                      (route) => false,
                    );
                  },
                  child: const Icon(Icons.arrow_back_sharp)),
            ),
          ],
        ),
      ),
    );
  }
}
