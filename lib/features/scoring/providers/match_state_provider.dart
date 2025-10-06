import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/match_state.dart';

/// MatchStateNotifier is responsible for managing the state of a cricket match.
/// It acts as the "brain" that controls how the match state can change over time.
/// This class handles all the logic for updating scores, wickets, overs, etc.
class MatchStateNotifier extends StateNotifier<MatchState> {
  final List<MatchState> _history = [];

  /// Creates a new MatchStateNotifier with initial default values.
  /// All scores and wickets are initialized to 0, and we start with the first innings.
  MatchStateNotifier()
      : super(
          MatchState(
            teamAInnings: const TeamInnings(
              score: 0,
              wickets: 0,
              overs: 0,
              balls: 0,
              players: [],
            ),
            teamBInnings: const TeamInnings(
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

  /// Adds the lists of players to their respective teams.
  void addPlayers({
    required List<Player> teamAPlayers,
    required List<Player> teamBPlayers,
  }) {
    _history.add(state);

    final updatedTeamAInnings = TeamInnings(
      score: state.teamAInnings.score,
      wickets: state.teamAInnings.wickets,
      overs: state.teamAInnings.overs,
      balls: state.teamAInnings.balls,
      players: teamAPlayers,
    );

    final updatedTeamBInnings = TeamInnings(
      score: state.teamBInnings.score,
      wickets: state.teamBInnings.wickets,
      overs: state.teamBInnings.overs,
      balls: state.teamBInnings.balls,
      players: teamBPlayers,
    );

    state = MatchState(
      teamAInnings: updatedTeamAInnings,
      teamBInnings: updatedTeamBInnings,
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

  /// Updates the score by adding the specified number of runs to the current innings.
  ///
  /// This method creates a new state object rather than modifying the existing one.
  /// Immutability is crucial for Riverpod because it detects state changes by comparing
  /// object references (not their content). By creating a new object, we ensure that
  /// Riverpod recognizes the state has changed and notifies all listeners, triggering
  /// UI updates in widgets that depend on this state.
  void addRuns(int runs) {
    _history.add(state);
    // Determine which team's innings to update based on currentInnings
    if (state.currentInnings == 1) {
      final newBalls = state.teamAInnings.balls + 1;
      final newOvers = state.teamAInnings.overs + (newBalls == 6 ? 1 : 0);
      // Update Team A's innings
      final updatedTeamAInnings = TeamInnings(
        score: state.teamAInnings.score + runs,
        wickets: state.teamAInnings.wickets,
        overs: newOvers,
        balls: newBalls % 6,
        players: state.teamAInnings.players,
      );

      // Create a new state with the updated innings
      state = MatchState(
        teamAInnings: updatedTeamAInnings,
        teamBInnings: state.teamBInnings,
        currentInnings: state.currentInnings,
        striker: state.striker,
        nonStriker: state.nonStriker,
        bowler: state.bowler,
        matchDate: state.matchDate,
        location: state.location,
      );
    } else {
      final newBalls = state.teamBInnings.balls + 1;
      final newOvers = state.teamBInnings.overs + (newBalls == 6 ? 1 : 0);
      // Update Team B's innings
      final updatedTeamBInnings = TeamInnings(
        score: state.teamBInnings.score + runs,
        wickets: state.teamBInnings.wickets,
        overs: newOvers,
        balls: newBalls % 6,
        players: state.teamBInnings.players,
      );

      // Create a new state with the updated innings
      state = MatchState(
        teamAInnings: state.teamAInnings,
        teamBInnings: updatedTeamBInnings,
        currentInnings: state.currentInnings,
        striker: state.striker,
        nonStriker: state.nonStriker,
        bowler: state.bowler,
        matchDate: state.matchDate,
        location: state.location,
      );
    }
  }

  /// Updates the wickets count by incrementing it by 1 for the current innings.
  ///
  /// This method creates a new state object rather than modifying the existing one.
  /// Immutability is crucial for Riverpod because it detects state changes by comparing
  /// object references (not their content). By creating a new object, we ensure that
  /// Riverpod recognizes the state has changed and notifies all listeners, triggering
  /// UI updates in widgets that depend on this state.
  void recordWicket() {
    _history.add(state);
    // Determine which team's innings to update based on currentInnings
    if (state.currentInnings == 1) {
      final newBalls = state.teamAInnings.balls + 1;
      final newOvers = state.teamAInnings.overs + (newBalls == 6 ? 1 : 0);
      // Update Team A's innings
      final updatedTeamAInnings = TeamInnings(
        score: state.teamAInnings.score,
        wickets: state.teamAInnings.wickets + 1,
        overs: newOvers,
        balls: newBalls % 6,
        players: state.teamAInnings.players,
      );

      // Create a new state with the updated innings
      state = MatchState(
        teamAInnings: updatedTeamAInnings,
        teamBInnings: state.teamBInnings,
        currentInnings: state.currentInnings,
        striker: state.striker,
        nonStriker: state.nonStriker,
        bowler: state.bowler,
        matchDate: state.matchDate,
        location: state.location,
      );
    } else {
      final newBalls = state.teamBInnings.balls + 1;
      final newOvers = state.teamBInnings.overs + (newBalls == 6 ? 1 : 0);
      // Update Team B's innings
      final updatedTeamBInnings = TeamInnings(
        score: state.teamBInnings.score,
        wickets: state.teamBInnings.wickets + 1,
        overs: newOvers,
        balls: newBalls % 6,
        players: state.teamBInnings.players,
      );

      // Create a new state with the updated innings
      state = MatchState(
        teamAInnings: state.teamAInnings,
        teamBInnings: updatedTeamBInnings,
        currentInnings: state.currentInnings,
        striker: state.striker,
        nonStriker: state.nonStriker,
        bowler: state.bowler,
        matchDate: state.matchDate,
        location: state.location,
      );
    }
  }

  /// Records an extra run (e.g., wide, no-ball, bye, leg-bye).
  ///
  /// For a wide or no-ball, the score is updated, but the ball count does not increase.
  /// For a bye or leg-bye, the score is updated, and the ball count increases.
  void recordExtra({required ExtraType type, int runs = 1}) {
    if (type == ExtraType.wide || type == ExtraType.noBall) {
      _history.add(state);
      TeamInnings currentInnings =
          state.currentInnings == 1 ? state.teamAInnings : state.teamBInnings;

      TeamInnings updatedInnings = TeamInnings(
        score: currentInnings.score + runs,
        wickets: currentInnings.wickets,
        overs: currentInnings.overs,
        balls: currentInnings.balls,
        players: currentInnings.players,
      );

      state = MatchState(
        teamAInnings:
            state.currentInnings == 1 ? updatedInnings : state.teamAInnings,
        teamBInnings:
            state.currentInnings == 2 ? updatedInnings : state.teamBInnings,
        currentInnings: state.currentInnings,
        striker: state.striker,
        nonStriker: state.nonStriker,
        bowler: state.bowler,
        matchDate: state.matchDate,
        location: state.location,
      );
    } else if (type == ExtraType.bye || type == ExtraType.legBye) {
      addRuns(runs);
    }
  }

  void undoLastAction() {
    if (_history.isNotEmpty) {
      state = _history.removeLast();
    }
  }
}

/// The matchStateProvider is the access point for the MatchState throughout the app.
/// It creates and exposes the MatchStateNotifier to widgets that need to:
/// 1. Read the current match state
/// 2. Listen for changes to the match state
/// 3. Modify the match state through the notifier
final matchStateProvider =
    StateNotifierProvider<MatchStateNotifier, MatchState>((ref) {
  return MatchStateNotifier();
});
