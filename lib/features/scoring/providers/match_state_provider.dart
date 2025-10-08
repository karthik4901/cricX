import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/match_state.dart';

/// MatchStateNotifier is responsible for managing the state of a cricket match.
/// It acts as the "brain" that controls how the match state can change over time.
/// This class handles all the logic for updating scores, wickets, overs, etc.
class MatchStateNotifier extends StateNotifier<MatchState> {
  final List<MatchState> _history = [];

  /// Creates a new MatchStateNotifier with initial default values.
  MatchStateNotifier()
      : super(
          MatchState(
            teamAInnings: TeamInnings(
              score: 0,
              wickets: 0,
              overs: 0,
              balls: 0,
              players: [],
            ),
            teamBInnings: TeamInnings(
              score: 0,
              wickets: 0,
              overs: 0,
              balls: 0,
              players: [],
            ),
            currentInnings: 1,
            matchDate: DateTime.now(),
            location: '',
          ),
        );

  // Helper to update a player in a list immutably
  List<Player> _updatePlayerInList(List<Player> players, Player updatedPlayer) {
    return players.map((p) => p.id == updatedPlayer.id ? updatedPlayer : p).toList();
  }

  void setMatchMetadata({required DateTime matchDate, required String location}) {
    _history.add(state);
    state = MatchState(
      teamAInnings: state.teamAInnings,
      teamBInnings: state.teamBInnings,
      currentInnings: state.currentInnings,
      striker: state.striker,
      nonStriker: state.nonStriker,
      bowler: state.bowler,
      matchDate: matchDate,
      location: location,
    );
  }

  void addPlayers({
    required List<Player> teamAPlayers,
    required List<Player> teamBPlayers,
  }) {
    _history.add(state);
    state = MatchState(
      teamAInnings: TeamInnings(
        score: state.teamAInnings.score,
        wickets: state.teamAInnings.wickets,
        overs: state.teamAInnings.overs,
        balls: state.teamAInnings.balls,
        players: teamAPlayers,
      ),
      teamBInnings: TeamInnings(
        score: state.teamBInnings.score,
        wickets: state.teamBInnings.wickets,
        overs: state.teamBInnings.overs,
        balls: state.teamBInnings.balls,
        players: teamBPlayers,
      ),
      currentInnings: state.currentInnings,
      striker: state.striker,
      nonStriker: state.nonStriker,
      bowler: state.bowler,
      matchDate: state.matchDate,
      location: state.location,
    );
  }

  void setOpeningPlayers({
    required Player striker,
    required Player nonStriker,
    required Player bowler,
  }) {
    _history.add(state);
    state = MatchState(
      teamAInnings: state.teamAInnings,
      teamBInnings: state.teamBInnings,
      currentInnings: state.currentInnings,
      striker: striker,
      nonStriker: nonStriker,
      bowler: bowler,
      matchDate: state.matchDate,
      location: state.location,
    );
  }

  void addRuns(int runs) {
    _history.add(state);

    if (state.striker == null) return; // Safety check

    // Update striker stats
    final updatedStriker = state.striker!.copyWith(
      runsScored: state.striker!.runsScored + runs,
      ballsFaced: state.striker!.ballsFaced + 1,
      fours: runs == 4 ? state.striker!.fours + 1 : state.striker!.fours,
      sixes: runs == 6 ? state.striker!.sixes + 1 : state.striker!.sixes,
    );

    if (state.currentInnings == 1) {
      final newBalls = state.teamAInnings.balls + 1;
      final newOvers = state.teamAInnings.overs + (newBalls == 6 ? 1 : 0);
      final updatedPlayers = _updatePlayerInList(state.teamAInnings.players, updatedStriker);

      state = MatchState(
        teamAInnings: TeamInnings(
          score: state.teamAInnings.score + runs,
          wickets: state.teamAInnings.wickets,
          overs: newOvers,
          balls: newBalls % 6,
          players: updatedPlayers,
        ),
        teamBInnings: state.teamBInnings,
        currentInnings: state.currentInnings,
        striker: updatedStriker,
        nonStriker: state.nonStriker,
        bowler: state.bowler,
        matchDate: state.matchDate,
        location: state.location,
      );
    } else {
      final newBalls = state.teamBInnings.balls + 1;
      final newOvers = state.teamBInnings.overs + (newBalls == 6 ? 1 : 0);
      final updatedPlayers = _updatePlayerInList(state.teamBInnings.players, updatedStriker);

      state = MatchState(
        teamAInnings: state.teamAInnings,
        teamBInnings: TeamInnings(
          score: state.teamBInnings.score + runs,
          wickets: state.teamBInnings.wickets,
          overs: newOvers,
          balls: newBalls % 6,
          players: updatedPlayers,
        ),
        currentInnings: state.currentInnings,
        striker: updatedStriker,
        nonStriker: state.nonStriker,
        bowler: state.bowler,
        matchDate: state.matchDate,
        location: state.location,
      );
    }

    // Rotate strike if runs are odd (1 or 3)
    if (runs == 1 || runs == 3) {
      _rotateStrike();
    }

    // Rotate strike at the end of an over
    final currentBalls = state.currentInnings == 1 
        ? state.teamAInnings.balls 
        : state.teamBInnings.balls;
    if (currentBalls == 0 && (state.currentInnings == 1 
        ? state.teamAInnings.overs > 0 
        : state.teamBInnings.overs > 0)) {
      _rotateStrike();
    }
  }

  void recordWicket() {
    _history.add(state);

    if (state.bowler == null) return; // Safety check

    // Update bowler stats
    final updatedBowler = state.bowler!.copyWith(
      wicketsTaken: state.bowler!.wicketsTaken + 1,
    );

    if (state.currentInnings == 1) {
      // Team A is batting, Team B is bowling
      final newBalls = state.teamAInnings.balls + 1;
      final newOvers = state.teamAInnings.overs + (newBalls == 6 ? 1 : 0);
      final updatedBowlingTeamPlayers = _updatePlayerInList(state.teamBInnings.players, updatedBowler);

      state = MatchState(
        teamAInnings: TeamInnings(
          score: state.teamAInnings.score,
          wickets: state.teamAInnings.wickets + 1,
          overs: newOvers,
          balls: newBalls % 6,
          players: state.teamAInnings.players,
        ),
        teamBInnings: TeamInnings(
            score: state.teamBInnings.score,
            wickets: state.teamBInnings.wickets,
            overs: state.teamBInnings.overs,
            balls: state.teamBInnings.balls,
            players: updatedBowlingTeamPlayers),
        currentInnings: state.currentInnings,
        striker: state.striker, // This will be replaced by the new batsman
        nonStriker: state.nonStriker,
        bowler: updatedBowler,
        matchDate: state.matchDate,
        location: state.location,
      );
    } else {
      // Team B is batting, Team A is bowling
      final newBalls = state.teamBInnings.balls + 1;
      final newOvers = state.teamBInnings.overs + (newBalls == 6 ? 1 : 0);
      final updatedBowlingTeamPlayers = _updatePlayerInList(state.teamAInnings.players, updatedBowler);

      state = MatchState(
        teamAInnings: TeamInnings(
            score: state.teamAInnings.score,
            wickets: state.teamAInnings.wickets,
            overs: state.teamAInnings.overs,
            balls: state.teamAInnings.balls,
            players: updatedBowlingTeamPlayers),
        teamBInnings: TeamInnings(
          score: state.teamBInnings.score,
          wickets: state.teamBInnings.wickets + 1,
          overs: newOvers,
          balls: newBalls % 6,
          players: state.teamBInnings.players,
        ),
        currentInnings: state.currentInnings,
        striker: state.striker, // This will be replaced by the new batsman
        nonStriker: state.nonStriker,
        bowler: updatedBowler,
        matchDate: state.matchDate,
        location: state.location,
      );
    }
  }

  void recordExtra({required ExtraType type, int runs = 1}) {
    _history.add(state);

    if (type == ExtraType.wide || type == ExtraType.noBall) {
      if (state.bowler == null) return; // Safety check

      final updatedBowler = state.bowler!.copyWith(
        runsConceded: state.bowler!.runsConceded + runs,
      );

      if (state.currentInnings == 1) {
        // Team A batting, Team B bowling
        final updatedBowlingTeamPlayers = _updatePlayerInList(state.teamBInnings.players, updatedBowler);
        state = MatchState(
          teamAInnings: state.teamAInnings.copyWith(score: state.teamAInnings.score + runs),
          teamBInnings: state.teamBInnings.copyWith(players: updatedBowlingTeamPlayers),
          currentInnings: state.currentInnings,
          striker: state.striker,
          nonStriker: state.nonStriker,
          bowler: updatedBowler,
          matchDate: state.matchDate,
          location: state.location,
        );
      } else {
        // Team B batting, Team A bowling
        final updatedBowlingTeamPlayers = _updatePlayerInList(state.teamAInnings.players, updatedBowler);
        state = MatchState(
          teamAInnings: state.teamAInnings.copyWith(players: updatedBowlingTeamPlayers),
          teamBInnings: state.teamBInnings.copyWith(score: state.teamBInnings.score + runs),
          currentInnings: state.currentInnings,
          striker: state.striker,
          nonStriker: state.nonStriker,
          bowler: updatedBowler,
          matchDate: state.matchDate,
          location: state.location,
        );
      }
    } else if (type == ExtraType.bye || type == ExtraType.legBye) {
      // Note: This currently incorrectly assigns runs to the striker.
      // A future refactoring is needed to handle this properly.
      addRuns(runs);
    }
  }

  // Swaps the striker and nonStriker players
  void _rotateStrike() {
    if (state.striker == null || state.nonStriker == null) return; // Safety check

    state = MatchState(
      teamAInnings: state.teamAInnings,
      teamBInnings: state.teamBInnings,
      currentInnings: state.currentInnings,
      striker: state.nonStriker,
      nonStriker: state.striker,
      bowler: state.bowler,
      matchDate: state.matchDate,
      location: state.location,
    );
  }

  void undoLastAction() {
    if (_history.isNotEmpty) {
      state = _history.removeLast();
    }
  }
}

// Extension methods for easier immutable updates

extension on TeamInnings {
  TeamInnings copyWith({
    int? score,
    int? wickets,
    int? overs,
    int? balls,
    List<Player>? players,
  }) {
    return TeamInnings(
      score: score ?? this.score,
      wickets: wickets ?? this.wickets,
      overs: overs ?? this.overs,
      balls: balls ?? this.balls,
      players: players ?? this.players,
    );
  }
}

final matchStateProvider =
    StateNotifierProvider<MatchStateNotifier, MatchState>((ref) {
  return MatchStateNotifier();
});
