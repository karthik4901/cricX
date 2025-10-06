enum ExtraType { wide, noBall, bye, legBye }

class TeamInnings {
  final int score;
  final int wickets;
  final int overs;
  final int balls;

  const TeamInnings({
    required this.score,
    required this.wickets,
    required this.overs,
    required this.balls,
  });
}

class MatchState {
  final TeamInnings teamAInnings;
  final TeamInnings teamBInnings;
  final int currentInnings;

  const MatchState({
    required this.teamAInnings,
    required this.teamBInnings,
    required this.currentInnings,
  });
}
