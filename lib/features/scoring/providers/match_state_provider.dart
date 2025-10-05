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
              overs: 0.0,
            ),
            teamBInnings: const TeamInnings(
              score: 0,
              wickets: 0,
              overs: 0.0,
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
      // Update Team A's innings
      final updatedTeamAInnings = TeamInnings(
        score: state.teamAInnings.score + runs,
        wickets: state.teamAInnings.wickets,
        overs: state.teamAInnings.overs,
      );

      // Create a new state with the updated innings
      state = MatchState(
        teamAInnings: updatedTeamAInnings,
        teamBInnings: state.teamBInnings,
        currentInnings: state.currentInnings,
      );
    } else {
      // Update Team B's innings
      final updatedTeamBInnings = TeamInnings(
        score: state.teamBInnings.score + runs,
        wickets: state.teamBInnings.wickets,
        overs: state.teamBInnings.overs,
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
      // Update Team A's innings
      final updatedTeamAInnings = TeamInnings(
        score: state.teamAInnings.score,
        wickets: state.teamAInnings.wickets + 1,
        overs: state.teamAInnings.overs,
      );

      // Create a new state with the updated innings
      state = MatchState(
        teamAInnings: updatedTeamAInnings,
        teamBInnings: state.teamBInnings,
        currentInnings: state.currentInnings,
      );
    } else {
      // Update Team B's innings
      final updatedTeamBInnings = TeamInnings(
        score: state.teamBInnings.score,
        wickets: state.teamBInnings.wickets + 1,
        overs: state.teamBInnings.overs,
      );

      // Create a new state with the updated innings
      state = MatchState(
        teamAInnings: state.teamAInnings,
        teamBInnings: updatedTeamBInnings,
        currentInnings: state.currentInnings,
      );
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
