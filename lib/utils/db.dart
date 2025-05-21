import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

class DB {
  static final DB _singleton = DB._internal();

  factory DB() => _singleton;

  DB._internal();

  late final LazyBox _hiveBox;

  LazyBox get box => _hiveBox;

  Future<void> init() async {
    final directory = await getApplicationDocumentsDirectory();
    _hiveBox = await Hive.openLazyBox("quick_note", path: directory.path);

    if (kProfileMode || kDebugMode) {
      final demoNotes = {
        '2025-05-08':
            'Had a self-care night with a face mask 🧘‍♀️—so relaxing!\n\nWoke up refreshed and slayed my morning routine 🌞.',
        '2025-05-09':
            'Stayed up late scrolling TikTok 📱—I’m obsessed!\n\nStill managed to glow up and handle my to-do list 💖.',
        '2025-05-10':
            'Tried a new smoothie recipe 🥤 and it was straight fire!\n\nKept the good vibes going with a lit playlist all day 🎶.',
        '2025-05-11':
            'Went for a sunset walk 🌅 and it was giving all the vibes.\n\nEnergy was on point today, got so much done! ⚡',
        '2025-05-12':
            'Had the best coffee date with friends ☕—we spilled all the tea!\n\nFelt super chill and productive after, total win! 🌈',
        '2025-05-13':
            'Binged my fave show on Netflix 🍿 till midnight—oops!\n\nStill had big main character energy all day tho 🌟.',
        '2025-05-14':
            'Crushed a late-night study sesh 📚 and still got some solid Zzz’s.\n\nWoke up feeling like a total vibe—ready to slay the day! 💅',
        '2025-05-15':
            'Hit up a thrift store haul 🛒 and scored some vintage drip—lowkey obsessed!\n\nRocked my new fit and felt like a whole vibe all day 🔥.',
        '2025-05-16':
            'Stayed up late making a bomb playlist 🎧—it’s giving summer vibes!\n\nShared it with the squad and we were all vibin’ hard 🕺.',
        '2025-05-17':
            'Went on a sunrise hike 🌄 and the views were straight bussin’—nature slay!\n\nEnergy was poppin’ all day, got so much done 📈.',
      };

      for (var entry in demoNotes.entries) {
        await addNote(entry.key, entry.value);
      }
    }
  }

  Future<void> addNote(String key, String value) async => await _hiveBox.put(key, value);

  Future<String?> fetchNote(String key) async {
    final val = await _hiveBox.get(key, defaultValue: null) as String?;
    return val;
  }
}
