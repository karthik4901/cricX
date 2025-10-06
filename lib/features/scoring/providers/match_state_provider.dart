import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/match_state.dart';

/// MatchStateNotifier is responsible for managing the state of a cricket match.
/// It acts as the "brain" that controls how the match state can change over time.
/// This class handles all the logic for updating scores, wickets, overs, etc.
class MatchStateNotifier extends StateNotifier<MatchState> {
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
            ),
            teamBInnings: const TeamInnings(
              score: 0,
              wickets: 0,
              overs: 0,
              balls: 0,
            ),
            currentInnings: 1,
          ),
        );

  // Methods to update the match state can be added here

  /// Updates the score by adding the specified number of runs to the current innings.
  ///
  /// This method creates a new state object rather than modifying the existing one.
  /// Immutability is crucial for Riverpod because it detects state changes by comparing
  /// object references (not their content). By creating a new object, we ensure that
  /// Riverpod recognizes the state has changed and notifies all listeners, triggering
  /// UI updates in widgets that depend on this state.
  void addRuns(int runs) {
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
      );

      // Create a new state with the updated innings
      state = MatchState(
        teamAInnings: updatedTeamAInnings,
        teamBInnings: state.teamBInnings,
        currentInnings: state.currentInnings,
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
      );

      // Create a new state with the updated innings
      state = MatchState(
        teamAInnings: state.teamAInnings,
        teamBInnings: updatedTeamBInnings,
        currentInnings: state.currentInnings,
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
      );

      // Create a new state with the updated innings
      state = MatchState(
        teamAInnings: updatedTeamAInnings,
        teamBInnings: state.teamBInnings,
        currentInnings: state.currentInnings,
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
      );

      // Create a new state with the updated innings
      state = MatchState(
        teamAInnings: state.teamAInnings,
        teamBInnings: updatedTeamBInnings,
        currentInnings: state.currentInnings,
      );
    }
  }

  /// Records an extra run (e.g., wide, no-ball, bye, leg-bye).
  ///
  /// For a wide or no-ball, the score is updated, but the ball count does not increase.
  /// For a bye or leg-bye, the score is updated, and the ball count increases.
  void recordExtra({required ExtraType type, int runs = 1}) {
    if (type == ExtraType.wide || type == ExtraType.noBall) {
      TeamInnings currentInnings =
          state.currentInnings == 1 ? state.teamAInnings : state.teamBInnings;

      TeamInnings updatedInnings = TeamInnings(
        score: currentInnings.score + runs,
        wickets: currentInnings.wickets,
        overs: currentInnings.overs,
        balls: currentInnings.balls, // This was the missing piece
      );

      state = MatchState(
        teamAInnings:
            state.currentInnings == 1 ? updatedInnings : state.teamAInnings,
        teamBInnings:
            state.currentInnings == 2 ? updatedInnings : state.teamBInnings,
        currentInnings: state.currentInnings,
      );
    } else if (type == ExtraType.bye || type == ExtraType.legBye) {
      addRuns(runs);
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
