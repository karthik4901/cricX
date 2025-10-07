enum ExtraType { wide, noBall, bye, legBye }

class Player {
  final String id;
  final String name;

  // Batting Stats
  final int runsScored;
  final int ballsFaced;
  final int fours;
  final int sixes;

  // Bowling Stats
  final int wicketsTaken;
  final double oversBowled;
  final int runsConceded;
  final int maidens;

  Player({
    required this.id,
    required this.name,
    this.runsScored = 0,
    this.ballsFaced = 0,
    this.fours = 0,
    this.sixes = 0,
    this.wicketsTaken = 0,
    this.oversBowled = 0.0,
    this.runsConceded = 0,
    this.maidens = 0,
  });

  Player copyWith({
    String? id,
    String? name,
    int? runsScored,
    int? ballsFaced,
    int? fours,
    int? sixes,
    int? wicketsTaken,
    double? oversBowled,
    int? runsConceded,
    int? maidens,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      runsScored: runsScored ?? this.runsScored,
      ballsFaced: ballsFaced ?? this.ballsFaced,
      fours: fours ?? this.fours,
      sixes: sixes ?? this.sixes,
      wicketsTaken: wicketsTaken ?? this.wicketsTaken,
      oversBowled: oversBowled ?? this.oversBowled,
      runsConceded: runsConceded ?? this.runsConceded,
      maidens: maidens ?? this.maidens,
    );
  }
}

class TeamInnings {
  final int score;
  final int wickets;
  final int overs;
  final int balls;
  final List<Player> players;

  const TeamInnings({
    required this.score,
    required this.wickets,
    required this.overs,
    required this.balls,
    required this.players,
  });
}

class MatchState {
  final TeamInnings teamAInnings;
  final TeamInnings teamBInnings;
  final int currentInnings;
  final Player? striker;
  final Player? nonStriker;
  final Player? bowler;
  final DateTime matchDate;
  final String location;

  const MatchState({
    required this.teamAInnings,
    required this.teamBInnings,
    required this.currentInnings,
    this.striker,
    this.nonStriker,
    this.bowler,
    required this.matchDate,
    required this.location,
  });
}
