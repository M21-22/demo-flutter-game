import 'package:flutter/material.dart';
import 'package:spacesurvival/game/routes.dart';

class MainMenu extends StatelessWidget {
  const MainMenu({super.key});

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
                'SpaceSurvival',
                style: TextStyle(
                  fontSize: 35,
                  color: Colors.black,
                  shadows: [
                    Shadow(
                        blurRadius: 30,
                        color: Colors.white,
                        offset: Offset(0, 0))
                  ],
                ),
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width / 3,
              child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      shipSelectionRoute,
                      (route) => false,
                    );
                  },
                  child: const Text('Play')),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width / 3,
              child: ElevatedButton(
                  onPressed: () {}, child: const Text('Options')),
            ),
          ],
        ),
      ),
    );
  }
}
