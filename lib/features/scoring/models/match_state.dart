class TeamInnings {
  final int score;
  final int wickets;
  final double overs;

  const TeamInnings({
    required this.score,
    required this.wickets,
    required this.overs,
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
