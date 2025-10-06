enum ExtraType { wide, noBall, bye, legBye }

class Player {
  final String id;
  final String name;

  const Player({
    required this.id,
    required this.name,
  });
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
