import 'dart:math';

/// Generates pseudonymous usernames (e.g. cedar.hayes) and
/// 5-word recovery phrases from curated word lists.
class UsernameGenerator {
  static const _firstNames = [
    'cedar', 'jade', 'marco', 'sofia', 'alex', 'river', 'quinn', 'blake',
    'morgan', 'avery', 'drew', 'casey', 'riley', 'taylor', 'hayden',
    'dakota', 'ember', 'forest', 'ash', 'rowan', 'wren', 'nova', 'eden',
    'lane', 'grey', 'vale', 'sloane', 'skye', 'indigo', 'sage', 'remy',
    'finley', 'elliot', 'reese', 'sable', 'briar', 'cove', 'flint', 'luca',
    'milo', 'arlo', 'noel', 'pax', 'reed', 'true', 'vesper', 'wilder',
  ];

  static const _lastNames = [
    'hayes', 'miller', 'ross', 'novak', 'kim', 'chen', 'park', 'brooks',
    'cole', 'shaw', 'grant', 'ford', 'west', 'hart', 'bell', 'marsh',
    'stone', 'hunt', 'fox', 'moon', 'wade', 'duke', 'cain', 'dean',
    'levy', 'bass', 'york', 'nash', 'cross', 'wolf', 'price', 'ray',
    'day', 'bloom', 'crane', 'dale', 'fern', 'gale', 'heath', 'isle',
    'jade', 'knoll', 'lake', 'moor', 'oaks', 'pine', 'vale', 'wren',
  ];

  static const _recoveryWords = [
    'maple', 'storm', 'river', 'cloud', 'ember', 'frost', 'dusk', 'dawn',
    'cedar', 'amber', 'coral', 'forge', 'grove', 'haven', 'isle', 'kelp',
    'lodge', 'mist', 'north', 'opal', 'pine', 'quill', 'ridge', 'slate',
    'tide', 'umber', 'wave', 'birch', 'delta', 'echo', 'flint', 'grain',
    'haze', 'iron', 'jewel', 'knoll', 'lark', 'mesa', 'nook', 'ochre',
    'prism', 'quest', 'raven', 'shore', 'thorn', 'void', 'wisp', 'acorn',
    'briar', 'chalk', 'drift', 'elder', 'fable', 'glow', 'heron', 'icicle',
    'joule', 'kite', 'linen', 'moose', 'nymph', 'orbit', 'plume', 'quartz',
    'robin', 'sable', 'trout', 'umbra', 'veil', 'waltz', 'xenon', 'yarrow',
    'zeal', 'adobe', 'basil', 'cactus', 'dune', 'finch', 'garnet', 'hazel',
    'igloo', 'jasper', 'karma', 'lotus', 'magic', 'nimbus', 'onyx', 'petal',
  ];

  static final _rng = Random.secure();

  static String generateUsername() {
    final first = _firstNames[_rng.nextInt(_firstNames.length)];
    final last = _lastNames[_rng.nextInt(_lastNames.length)];
    return '$first.$last';
  }

  static List<String> generateRecoveryPhrase() {
    final shuffled = List<String>.from(_recoveryWords)..shuffle(_rng);
    return shuffled.take(5).toList();
  }
}
