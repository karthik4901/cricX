import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/match_state.dart';
import '../../../services/persistence_service.dart';

/// MatchStateNotifier is responsible for managing the state of a cricket match.
/// It acts as the "brain" that controls how the match state can change over time.
/// This class handles all the logic for updating scores, wickets, overs, etc.
class MatchStateNotifier extends StateNotifier<MatchState> {
  final List<MatchState> _history = [];
  final PersistenceService _persistenceService = PersistenceService();

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

  /// Creates a MatchStateNotifier with a provided initial state.
  MatchStateNotifier.fromState(MatchState initialState) : super(initialState) {
    _persistenceService.saveMatchState(initialState);
  }

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
    _persistenceService.saveMatchState(state);
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
    _persistenceService.saveMatchState(state);
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
    _persistenceService.saveMatchState(state);
  }

  void addRuns(int runs) {
    _history.add(state);

    if (state.striker == null || state.bowler == null) return; // Safety check

    // Update striker stats
    final updatedStriker = state.striker!.copyWith(
      runsScored: state.striker!.runsScored + runs,
      ballsFaced: state.striker!.ballsFaced + 1,
      fours: runs == 4 ? state.striker!.fours + 1 : state.striker!.fours,
      sixes: runs == 6 ? state.striker!.sixes + 1 : state.striker!.sixes,
    );

    // Update bowler stats
    // Calculate new oversBowled value, handling the transition from .5 to the next whole over
    double newOversBowled = state.bowler!.oversBowled + 0.1; // Add 1 ball (0.1 overs)
    if (newOversBowled.toStringAsFixed(1).endsWith('.6')) {
      // If we have 6 balls, increment to the next over
      newOversBowled = newOversBowled.floorToDouble() + 1.0;
    }

    final updatedBowler = state.bowler!.copyWith(
      oversBowled: newOversBowled,
      runsConceded: state.bowler!.runsConceded + runs,
    );

    if (state.currentInnings == 1) {
      final newBalls = state.teamAInnings.balls + 1;
      final newOvers = state.teamAInnings.overs + (newBalls == 6 ? 1 : 0);
      final updatedBattingPlayers = _updatePlayerInList(state.teamAInnings.players, updatedStriker);
      final updatedBowlingPlayers = _updatePlayerInList(state.teamBInnings.players, updatedBowler);

      state = MatchState(
        teamAInnings: TeamInnings(
          score: state.teamAInnings.score + runs,
          wickets: state.teamAInnings.wickets,
          overs: newOvers,
          balls: newBalls % 6,
          players: updatedBattingPlayers,
        ),
        teamBInnings: TeamInnings(
          score: state.teamBInnings.score,
          wickets: state.teamBInnings.wickets,
          overs: state.teamBInnings.overs,
          balls: state.teamBInnings.balls,
          players: updatedBowlingPlayers,
        ),
        currentInnings: state.currentInnings,
        striker: updatedStriker,
        nonStriker: state.nonStriker,
        bowler: updatedBowler,
        matchDate: state.matchDate,
        location: state.location,
      );
    } else {
      final newBalls = state.teamBInnings.balls + 1;
      final newOvers = state.teamBInnings.overs + (newBalls == 6 ? 1 : 0);
      final updatedBattingPlayers = _updatePlayerInList(state.teamBInnings.players, updatedStriker);
      final updatedBowlingPlayers = _updatePlayerInList(state.teamAInnings.players, updatedBowler);

      state = MatchState(
        teamAInnings: TeamInnings(
          score: state.teamAInnings.score,
          wickets: state.teamAInnings.wickets,
          overs: state.teamAInnings.overs,
          balls: state.teamAInnings.balls,
          players: updatedBowlingPlayers,
        ),
        teamBInnings: TeamInnings(
          score: state.teamBInnings.score + runs,
          wickets: state.teamBInnings.wickets,
          overs: newOvers,
          balls: newBalls % 6,
          players: updatedBattingPlayers,
        ),
        currentInnings: state.currentInnings,
        striker: updatedStriker,
        nonStriker: state.nonStriker,
        bowler: updatedBowler,
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

    // Save the updated state
    _persistenceService.saveMatchState(state);
  }

  // This method is kept for backward compatibility
  void recordWicket() {
    _history.add(state);

    if (state.bowler == null) return; // Safety check

    // Update bowler stats
    // Calculate new oversBowled value, handling the transition from .5 to the next whole over
    double newOversBowled = state.bowler!.oversBowled + 0.1; // Add 1 ball (0.1 overs)
    if (newOversBowled.toStringAsFixed(1).endsWith('.6')) {
      // If we have 6 balls, increment to the next over
      newOversBowled = newOversBowled.floorToDouble() + 1.0;
    }

    final updatedBowler = state.bowler!.copyWith(
      wicketsTaken: state.bowler!.wicketsTaken + 1,
      oversBowled: newOversBowled,
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

    // Save the updated state
    _persistenceService.saveMatchState(state);
  }

  // This method is kept for backward compatibility
  void handleWicketDismissal({
    required DismissalType dismissalType,
    required Player nextBatsman,
    Player? fielder,
  }) {
    // Create a local variable to fix the reference to newBatsman
    final newBatsman = nextBatsman;
    _history.add(state);

    if (state.striker == null || state.nonStriker == null || state.bowler == null) return; // Safety check

    // Update bowler stats
    // Calculate new oversBowled value, handling the transition from .5 to the next whole over
    double newOversBowled = state.bowler!.oversBowled + 0.1; // Add 1 ball (0.1 overs)
    if (newOversBowled.toStringAsFixed(1).endsWith('.6')) {
      // If we have 6 balls, increment to the next over
      newOversBowled = newOversBowled.floorToDouble() + 1.0;
    }

    final updatedBowler = state.bowler!.copyWith(
      wicketsTaken: state.bowler!.wicketsTaken + 1,
      oversBowled: newOversBowled,
    );

    // In this method, we always assume the striker is dismissed
    final bool isStrikerDismissed = true;

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
        striker: isStrikerDismissed ? nextBatsman : state.striker,
        nonStriker: isStrikerDismissed ? state.nonStriker : nextBatsman,
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
        striker: isStrikerDismissed ? newBatsman : state.striker,
        nonStriker: isStrikerDismissed ? state.nonStriker : newBatsman,
        bowler: updatedBowler,
        matchDate: state.matchDate,
        location: state.location,
      );
    }

    // Save the updated state
    _persistenceService.saveMatchState(state);
  }

  /// Advanced method to handle a wicket dismissal.
  /// 
  /// This method allows specifying which batsman (striker or non-striker) is being dismissed.
  /// 
  /// Parameters:
  /// - dismissedBatsman: The batsman who is being dismissed (either striker or non-striker)
  /// - dismissalType: The type of dismissal (bowled, caught, lbw, etc.)
  /// - newBatsman: The new batsman who will replace the dismissed batsman
  void handleWicketDismissalAdvanced({
    required Player dismissedBatsman,
    required DismissalType dismissalType,
    required Player newBatsman,
  }) {
    _history.add(state);

    if (state.striker == null || state.nonStriker == null || state.bowler == null) return; // Safety check

    // Update bowler stats
    // Calculate new oversBowled value, handling the transition from .5 to the next whole over
    double newOversBowled = state.bowler!.oversBowled + 0.1; // Add 1 ball (0.1 overs)
    if (newOversBowled.toStringAsFixed(1).endsWith('.6')) {
      // If we have 6 balls, increment to the next over
      newOversBowled = newOversBowled.floorToDouble() + 1.0;
    }

    final updatedBowler = state.bowler!.copyWith(
      wicketsTaken: state.bowler!.wicketsTaken + 1,
      oversBowled: newOversBowled,
    );

    // Determine if the striker or non-striker was dismissed
    final bool isStrikerDismissed = dismissedBatsman.id == state.striker!.id;

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
        striker: isStrikerDismissed ? newBatsman : state.striker,
        nonStriker: isStrikerDismissed ? state.nonStriker : newBatsman,
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
        striker: isStrikerDismissed ? newBatsman : state.striker,
        nonStriker: isStrikerDismissed ? state.nonStriker : newBatsman,
        bowler: updatedBowler,
        matchDate: state.matchDate,
        location: state.location,
      );
    }

    // Save the updated state
    _persistenceService.saveMatchState(state);
  }

  void recordExtra({required ExtraType type, int runs = 1}) {
    _history.add(state);

    if (type == ExtraType.wide || type == ExtraType.noBall) {
      if (state.bowler == null) return; // Safety check

      // Calculate new oversBowled value for no-balls, handling the transition from .5 to the next whole over
      double newOversBowled = state.bowler!.oversBowled;
      if (type == ExtraType.noBall) {
        newOversBowled += 0.1; // Add 1 ball (0.1 overs) for no-balls only
        if (newOversBowled.toStringAsFixed(1).endsWith('.6')) {
          // If we have 6 balls, increment to the next over
          newOversBowled = newOversBowled.floorToDouble() + 1.0;
        }
      }

      final updatedBowler = state.bowler!.copyWith(
        runsConceded: state.bowler!.runsConceded + runs,
        oversBowled: newOversBowled,
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
        _persistenceService.saveMatchState(state);
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
        _persistenceService.saveMatchState(state);
      }
    } else if (type == ExtraType.bye || type == ExtraType.legBye) {
      if (state.bowler == null) return; // Safety check

      // Update bowler stats
      double newOversBowled = state.bowler!.oversBowled + 0.1; // Add 1 ball (0.1 overs)
      if (newOversBowled.toStringAsFixed(1).endsWith('.6')) {
        // If we have 6 balls, increment to the next over
        newOversBowled = newOversBowled.floorToDouble() + 1.0;
      }

      final updatedBowler = state.bowler!.copyWith(
        oversBowled: newOversBowled,
      );

      if (state.currentInnings == 1) {
        // Team A batting, Team B bowling
        final newBalls = state.teamAInnings.balls + 1;
        final newOvers = state.teamAInnings.overs + (newBalls == 6 ? 1 : 0);
        final updatedBowlingTeamPlayers = _updatePlayerInList(state.teamBInnings.players, updatedBowler);

        state = MatchState(
          teamAInnings: TeamInnings(
            score: state.teamAInnings.score + runs,
            wickets: state.teamAInnings.wickets,
            overs: newOvers,
            balls: newBalls % 6,
            players: state.teamAInnings.players,
          ),
          teamBInnings: TeamInnings(
            score: state.teamBInnings.score,
            wickets: state.teamBInnings.wickets,
            overs: state.teamBInnings.overs,
            balls: state.teamBInnings.balls,
            players: updatedBowlingTeamPlayers,
          ),
          currentInnings: state.currentInnings,
          striker: state.striker,
          nonStriker: state.nonStriker,
          bowler: updatedBowler,
          matchDate: state.matchDate,
          location: state.location,
        );
      } else {
        // Team B batting, Team A bowling
        final newBalls = state.teamBInnings.balls + 1;
        final newOvers = state.teamBInnings.overs + (newBalls == 6 ? 1 : 0);
        final updatedBowlingTeamPlayers = _updatePlayerInList(state.teamAInnings.players, updatedBowler);

        state = MatchState(
          teamAInnings: TeamInnings(
            score: state.teamAInnings.score,
            wickets: state.teamAInnings.wickets,
            overs: state.teamAInnings.overs,
            balls: state.teamAInnings.balls,
            players: updatedBowlingTeamPlayers,
          ),
          teamBInnings: TeamInnings(
            score: state.teamBInnings.score + runs,
            wickets: state.teamBInnings.wickets,
            overs: newOvers,
            balls: newBalls % 6,
            players: state.teamBInnings.players,
          ),
          currentInnings: state.currentInnings,
          striker: state.striker,
          nonStriker: state.nonStriker,
          bowler: updatedBowler,
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

      // Save the updated state
      _persistenceService.saveMatchState(state);
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
      _persistenceService.saveMatchState(state);
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

/// The default match state provider with a new match state
final matchStateProvider =
    StateNotifierProvider<MatchStateNotifier, MatchState>((ref) {
  return MatchStateNotifier();
});

/// A provider that creates a MatchStateNotifier with a saved match state
final savedMatchStateProvider = Provider<MatchState?>((ref) => null);

/// A provider that creates a MatchStateNotifier with the provided initial state
final loadedMatchStateProvider = StateNotifierProviderFamily<MatchStateNotifier, MatchState, MatchState>(
  (ref, initialState) => MatchStateNotifier.fromState(initialState),
);
