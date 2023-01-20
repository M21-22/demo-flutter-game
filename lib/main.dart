import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:spacesurvival/game/game.dart';
import 'package:spacesurvival/game/routes.dart';
import 'package:spacesurvival/models/player_data.dart';
import 'package:spacesurvival/models/spaceship_details.dart';
import 'package:spacesurvival/screens/game_play.dart';
import 'package:spacesurvival/screens/main_menu.dart';
import 'package:spacesurvival/screens/select_spaceships.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Flame.device.fullScreen();

  runApp(
    FutureProvider<PlayerData>(
      create: (BuildContext context) => getPlayerData(),
      //
      initialData: PlayerData.fromMap(PlayerData.defaultData),
      //
      builder: (context, child) {
        return ChangeNotifierProvider<PlayerData>.value(
          value: Provider.of<PlayerData>(context),
          // create: (context) => PlayerData.fromMap(PlayerData.defaultData),
          child: child,
        );
      },
      //
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.dark,
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          fontFamily: 'Zen_Dots',
          scaffoldBackgroundColor: Colors.black,
        ),
        routes: {
          startRoute: (context) => const GamePlay(),
          mainMenuRoute: (context) => const MainMenu(),
          shipSelectionRoute: (context) => const SelectSpaceship(),
        },
        home: const MainMenu(),
      ),
    ),
  );
}

final f = ChangeNotifier();

Future<void> initHive() async {
  final dir = await getApplicationDocumentsDirectory();
  Hive.init(dir.path);

  Hive.registerAdapter(PlayerDataAdapter());
  Hive.registerAdapter(SpaceshipTypeAdapter());
}

Future<PlayerData> getPlayerData() async {
  await initHive();
  final box = await Hive.openBox<PlayerData>('PlayerDataBox');
  final playerData = box.get('PlayerData');
  if (playerData == null) {
    box.put('PlayerData', PlayerData.fromMap(PlayerData.defaultData));
  }
  return box.get('PlayerData')!;
}
