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
            totalOvers: 20, // Default to 20 overs
            isFirstInningsComplete: false, // Default to false
            isMatchComplete: false, // Default to false
            playersPerSide: 11, // Default to 11 players per side
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

  void setMatchMetadata({required DateTime matchDate, required String location, required int totalOvers}) {
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
      totalOvers: totalOvers,
      isFirstInningsComplete: state.isFirstInningsComplete,
      isMatchComplete: state.isMatchComplete,
      playersPerSide: state.playersPerSide,
    );
    _persistenceService.saveMatchState(state);
  }

  /// Sets the number of players per side for the match.
  void setPlayersPerSide(int count) {
    print('[DEBUG_LOG] Setting players per side to: $count');
    _history.add(state);
    state = MatchState(
      teamAInnings: state.teamAInnings,
      teamBInnings: state.teamBInnings,
      currentInnings: state.currentInnings,
      striker: state.striker,
      nonStriker: state.nonStriker,
      bowler: state.bowler,
      matchDate: state.matchDate,
      location: state.location,
      totalOvers: state.totalOvers,
      isFirstInningsComplete: state.isFirstInningsComplete,
      isMatchComplete: state.isMatchComplete,
      playersPerSide: count,
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
      totalOvers: state.totalOvers,
      isFirstInningsComplete: state.isFirstInningsComplete,
      isMatchComplete: state.isMatchComplete,
    );
    _persistenceService.saveMatchState(state);
  }

  void setOpeningPlayers({
    required Player striker,
    required Player nonStriker,
    required Player bowler,
  }) {
    print('[DEBUG_LOG] setOpeningPlayers called');
    print('[DEBUG_LOG] Striker: ${striker.name}');
    print('[DEBUG_LOG] Non-striker: ${nonStriker.name}');
    print('[DEBUG_LOG] Bowler: ${bowler.name}');
    print('[DEBUG_LOG] Current innings: ${state.currentInnings}');
    print('[DEBUG_LOG] isFirstInningsComplete: ${state.isFirstInningsComplete}');
    print('[DEBUG_LOG] isMatchComplete: ${state.isMatchComplete}');

    _history.add(state);

    // Always set isFirstInningsComplete to false when setting up players for the second innings
    // This ensures the UI reflects that we're now in the second innings
    final bool shouldResetFirstInningsComplete = state.currentInnings == 2;

    state = MatchState(
      teamAInnings: state.teamAInnings,
      teamBInnings: state.teamBInnings,
      currentInnings: state.currentInnings,
      striker: striker,
      nonStriker: nonStriker,
      bowler: bowler,
      matchDate: state.matchDate,
      location: state.location,
      totalOvers: state.totalOvers,
      isFirstInningsComplete: shouldResetFirstInningsComplete ? false : state.isFirstInningsComplete,
      isMatchComplete: state.isMatchComplete,
    );

    print('[DEBUG_LOG] State updated in setOpeningPlayers');
    print('[DEBUG_LOG] shouldResetFirstInningsComplete: $shouldResetFirstInningsComplete');
    print('[DEBUG_LOG] New striker: ${state.striker?.name}');
    print('[DEBUG_LOG] New non-striker: ${state.nonStriker?.name}');
    print('[DEBUG_LOG] New bowler: ${state.bowler?.name}');
    print('[DEBUG_LOG] New isFirstInningsComplete: ${state.isFirstInningsComplete}');
    print('[DEBUG_LOG] New isMatchComplete: ${state.isMatchComplete}');

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

      // Check if the over is complete
      final isOverComplete = newBalls == 6;

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
        bowler: isOverComplete ? null : updatedBowler, // Set bowler to null if over is complete
        matchDate: state.matchDate,
        location: state.location,
        totalOvers: state.totalOvers,
        isFirstInningsComplete: state.isFirstInningsComplete,
        isMatchComplete: state.isMatchComplete,
      );
    } else {
      final newBalls = state.teamBInnings.balls + 1;
      final newOvers = state.teamBInnings.overs + (newBalls == 6 ? 1 : 0);
      final updatedBattingPlayers = _updatePlayerInList(state.teamBInnings.players, updatedStriker);
      final updatedBowlingPlayers = _updatePlayerInList(state.teamAInnings.players, updatedBowler);

      // Check if the over is complete
      final isOverComplete = newBalls == 6;

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
        bowler: isOverComplete ? null : updatedBowler, // Set bowler to null if over is complete
        matchDate: state.matchDate,
        location: state.location,
        totalOvers: state.totalOvers,
        isFirstInningsComplete: state.isFirstInningsComplete,
        isMatchComplete: state.isMatchComplete,
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

    // Check if the innings is over
    _checkForEndOfInnings();

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
        totalOvers: state.totalOvers,
        isFirstInningsComplete: state.isFirstInningsComplete,
        isMatchComplete: state.isMatchComplete,
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
        totalOvers: state.totalOvers,
        isFirstInningsComplete: state.isFirstInningsComplete,
        isMatchComplete: state.isMatchComplete,
      );
    }

    // Save the updated state
    _persistenceService.saveMatchState(state);
  }


  /// Advanced method to handle a wicket dismissal.
  /// 
  /// This method allows specifying which batsman is being dismissed, the type of dismissal,
  /// and the new batsman who will replace the dismissed player.
  /// 
  /// Parameters:
  /// - dismissedBatsman: The batsman who is being dismissed
  /// - dismissalType: The type of dismissal (bowled, caught, lbw, runOut, stumped)
  /// - newBatsman: The new batsman who will replace the dismissed batsman. Can be null for the last wicket.
  void handleWicketDismissal({
    required Player dismissedBatsman,
    required DismissalType dismissalType,
    Player? newBatsman,
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

    // Update the dismissed player's status to out
    final updatedDismissedBatsman = dismissedBatsman.copyWith(
      status: PlayerStatus.out,
    );

    // Determine if the striker or non-striker was dismissed
    final bool isStrikerDismissed = dismissedBatsman.id == state.striker!.id;

    if (state.currentInnings == 1) {
      // Team A is batting, Team B is bowling
      final newBalls = state.teamAInnings.balls + 1;
      final newOvers = state.teamAInnings.overs + (newBalls == 6 ? 1 : 0);
      final updatedBowlingTeamPlayers = _updatePlayerInList(state.teamBInnings.players, updatedBowler);

      // Update the batting team's players list with the updated dismissed player
      final updatedBattingTeamPlayers = _updatePlayerInList(state.teamAInnings.players, updatedDismissedBatsman);

      // Check if the over is complete
      final isOverComplete = newBalls == 6;

      state = MatchState(
        teamAInnings: TeamInnings(
          score: state.teamAInnings.score,
          wickets: state.teamAInnings.wickets + 1,
          overs: newOvers,
          balls: newBalls % 6,
          players: updatedBattingTeamPlayers,
        ),
        teamBInnings: TeamInnings(
            score: state.teamBInnings.score,
            wickets: state.teamBInnings.wickets,
            overs: state.teamBInnings.overs,
            balls: state.teamBInnings.balls,
            players: updatedBowlingTeamPlayers),
        currentInnings: state.currentInnings,
        striker: newBatsman == null ? null : (isStrikerDismissed ? newBatsman : state.striker),
        nonStriker: newBatsman == null ? null : (isStrikerDismissed ? state.nonStriker : newBatsman),
        bowler: isOverComplete ? null : updatedBowler, // Set bowler to null if over is complete
        matchDate: state.matchDate,
        location: state.location,
        totalOvers: state.totalOvers,
        isFirstInningsComplete: state.isFirstInningsComplete,
        isMatchComplete: state.isMatchComplete,
        playersPerSide: state.playersPerSide,
      );
    } else {
      // Team B is batting, Team A is bowling
      final newBalls = state.teamBInnings.balls + 1;
      final newOvers = state.teamBInnings.overs + (newBalls == 6 ? 1 : 0);
      final updatedBowlingTeamPlayers = _updatePlayerInList(state.teamAInnings.players, updatedBowler);

      // Update the batting team's players list with the updated dismissed player
      final updatedBattingTeamPlayers = _updatePlayerInList(state.teamBInnings.players, updatedDismissedBatsman);

      // Check if the over is complete
      final isOverComplete = newBalls == 6;

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
          players: updatedBattingTeamPlayers,
        ),
        currentInnings: state.currentInnings,
        striker: newBatsman == null ? null : (isStrikerDismissed ? newBatsman : state.striker),
        nonStriker: newBatsman == null ? null : (isStrikerDismissed ? state.nonStriker : newBatsman),
        bowler: isOverComplete ? null : updatedBowler, // Set bowler to null if over is complete
        matchDate: state.matchDate,
        location: state.location,
        totalOvers: state.totalOvers,
        isFirstInningsComplete: state.isFirstInningsComplete,
        isMatchComplete: state.isMatchComplete,
        playersPerSide: state.playersPerSide,
      );
    }

    // Check if the innings is over
    _checkForEndOfInnings();

    // Save the updated state
    _persistenceService.saveMatchState(state);
  }


  void recordExtra({required ExtraType type, int runs = 1}) {
    _history.add(state);

    // Determine which extra counter to increment based on the type
    int newWides = 0;
    int newNoBalls = 0;
    int newByes = 0;
    int newLegByes = 0;

    switch (type) {
      case ExtraType.wide:
        newWides = 1;
        break;
      case ExtraType.noBall:
        newNoBalls = 1;
        break;
      case ExtraType.bye:
        newByes = 1;
        break;
      case ExtraType.legBye:
        newLegByes = 1;
        break;
    }

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
          teamAInnings: state.teamAInnings.copyWith(
            score: state.teamAInnings.score + runs,
            wides: state.teamAInnings.wides + newWides,
            noBalls: state.teamAInnings.noBalls + newNoBalls,
            byes: state.teamAInnings.byes + newByes,
            legByes: state.teamAInnings.legByes + newLegByes,
          ),
          teamBInnings: state.teamBInnings.copyWith(players: updatedBowlingTeamPlayers),
          currentInnings: state.currentInnings,
          striker: state.striker,
          nonStriker: state.nonStriker,
          bowler: updatedBowler,
          matchDate: state.matchDate,
          location: state.location,
          totalOvers: state.totalOvers,
          isFirstInningsComplete: state.isFirstInningsComplete,
          isMatchComplete: state.isMatchComplete,
        );

        // Check if the innings is over
        _checkForEndOfInnings();

        _persistenceService.saveMatchState(state);
      } else {
        // Team B batting, Team A bowling
        final updatedBowlingTeamPlayers = _updatePlayerInList(state.teamAInnings.players, updatedBowler);
        state = MatchState(
          teamAInnings: state.teamAInnings.copyWith(players: updatedBowlingTeamPlayers),
          teamBInnings: state.teamBInnings.copyWith(
            score: state.teamBInnings.score + runs,
            wides: state.teamBInnings.wides + newWides,
            noBalls: state.teamBInnings.noBalls + newNoBalls,
            byes: state.teamBInnings.byes + newByes,
            legByes: state.teamBInnings.legByes + newLegByes,
          ),
          currentInnings: state.currentInnings,
          striker: state.striker,
          nonStriker: state.nonStriker,
          bowler: updatedBowler,
          matchDate: state.matchDate,
          location: state.location,
          totalOvers: state.totalOvers,
          isFirstInningsComplete: state.isFirstInningsComplete,
          isMatchComplete: state.isMatchComplete,
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

        // Check if the over is complete
        final isOverComplete = newBalls == 6;

        state = MatchState(
          teamAInnings: TeamInnings(
            score: state.teamAInnings.score + runs,
            wickets: state.teamAInnings.wickets,
            overs: newOvers,
            balls: newBalls % 6,
            players: state.teamAInnings.players,
            wides: state.teamAInnings.wides + newWides,
            noBalls: state.teamAInnings.noBalls + newNoBalls,
            byes: state.teamAInnings.byes + newByes,
            legByes: state.teamAInnings.legByes + newLegByes,
          ),
          teamBInnings: TeamInnings(
            score: state.teamBInnings.score,
            wickets: state.teamBInnings.wickets,
            overs: state.teamBInnings.overs,
            balls: state.teamBInnings.balls,
            players: updatedBowlingTeamPlayers,
            wides: state.teamBInnings.wides,
            noBalls: state.teamBInnings.noBalls,
            byes: state.teamBInnings.byes,
            legByes: state.teamBInnings.legByes,
          ),
          currentInnings: state.currentInnings,
          striker: state.striker,
          nonStriker: state.nonStriker,
          bowler: isOverComplete ? null : updatedBowler, // Set bowler to null if over is complete
          matchDate: state.matchDate,
          location: state.location,
          totalOvers: state.totalOvers,
          isFirstInningsComplete: state.isFirstInningsComplete,
          isMatchComplete: state.isMatchComplete,
        );
      } else {
        // Team B batting, Team A bowling
        final newBalls = state.teamBInnings.balls + 1;
        final newOvers = state.teamBInnings.overs + (newBalls == 6 ? 1 : 0);
        final updatedBowlingTeamPlayers = _updatePlayerInList(state.teamAInnings.players, updatedBowler);

        // Check if the over is complete
        final isOverComplete = newBalls == 6;

        state = MatchState(
          teamAInnings: TeamInnings(
            score: state.teamAInnings.score,
            wickets: state.teamAInnings.wickets,
            overs: state.teamAInnings.overs,
            balls: state.teamAInnings.balls,
            players: updatedBowlingTeamPlayers,
            wides: state.teamAInnings.wides,
            noBalls: state.teamAInnings.noBalls,
            byes: state.teamAInnings.byes,
            legByes: state.teamAInnings.legByes,
          ),
          teamBInnings: TeamInnings(
            score: state.teamBInnings.score + runs,
            wickets: state.teamBInnings.wickets,
            overs: newOvers,
            balls: newBalls % 6,
            players: state.teamBInnings.players,
            wides: state.teamBInnings.wides + newWides,
            noBalls: state.teamBInnings.noBalls + newNoBalls,
            byes: state.teamBInnings.byes + newByes,
            legByes: state.teamBInnings.legByes + newLegByes,
          ),
          currentInnings: state.currentInnings,
          striker: state.striker,
          nonStriker: state.nonStriker,
          bowler: isOverComplete ? null : updatedBowler, // Set bowler to null if over is complete
          matchDate: state.matchDate,
          location: state.location,
          totalOvers: state.totalOvers,
          isFirstInningsComplete: state.isFirstInningsComplete,
          isMatchComplete: state.isMatchComplete,
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

      // Check if the innings is over
      _checkForEndOfInnings();

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
      totalOvers: state.totalOvers,
      isFirstInningsComplete: state.isFirstInningsComplete,
      isMatchComplete: state.isMatchComplete,
    );
  }

  /// Checks if the current innings is over and switches to the second innings if needed.
  /// An innings is over if:
  /// 1. All Out: The number of wickets has reached 10, or
  /// 2. Overs Complete: The number of overs bowled has reached the totalOvers for the match.
  void _checkForEndOfInnings() {
    // Determine the current batting team based on the innings
    final currentBattingTeam = state.currentInnings == 1 ? state.teamAInnings : state.teamBInnings;

    // For second innings, determine the bowling team (which was the batting team in first innings)
    final currentBowlingTeam = state.currentInnings == 1 ? state.teamBInnings : state.teamAInnings;

    // Check if all out (playersPerSide - 1 wickets)
    final isAllOut = currentBattingTeam.wickets >= (state.playersPerSide - 1);

    // Check if overs complete
    final isOversComplete = currentBattingTeam.overs >= state.totalOvers;

    // Check if target chased (only applicable in second innings)
    final isTargetChased = state.currentInnings == 2 && currentBattingTeam.score > currentBowlingTeam.score;

    // Debug information
    print('[DEBUG_LOG] Checking for end of innings:');
    print('[DEBUG_LOG] Current innings: ${state.currentInnings}');
    print('[DEBUG_LOG] Current overs: ${currentBattingTeam.overs}, Total overs: ${state.totalOvers}');
    print('[DEBUG_LOG] Current wickets: ${currentBattingTeam.wickets}');
    print('[DEBUG_LOG] Is all out: $isAllOut, Is overs complete: $isOversComplete');
    if (state.currentInnings == 2) {
      print('[DEBUG_LOG] Batting team score: ${currentBattingTeam.score}, Bowling team score: ${currentBowlingTeam.score}');
      print('[DEBUG_LOG] Is target chased: $isTargetChased');
    }
    print('[DEBUG_LOG] Current isFirstInningsComplete: ${state.isFirstInningsComplete}');

    // If any end condition is true, handle end of innings
    if (isAllOut || isOversComplete || isTargetChased) {
      if (state.currentInnings == 1) {
        // First innings is over, switch to second innings
        print('[DEBUG_LOG] INNINGS OVER! Switching to second innings.');
        print('[DEBUG_LOG] Reason: ${isAllOut ? "All out" : "Overs complete"}');

        state = MatchState(
          teamAInnings: state.teamAInnings,
          teamBInnings: state.teamBInnings,
          currentInnings: 2, // Switch to second innings
          striker: null, // Reset batsmen and bowler
          nonStriker: null,
          bowler: null,
          matchDate: state.matchDate,
          location: state.location,
          totalOvers: state.totalOvers,
          isFirstInningsComplete: true, // Mark first innings as complete
          playersPerSide: state.playersPerSide, // Maintain players per side
        );

        print('[DEBUG_LOG] State updated - currentInnings: ${state.currentInnings}');
        print('[DEBUG_LOG] State updated - isFirstInningsComplete: ${state.isFirstInningsComplete}');
      } else {
        // Second innings is over, match is complete
        print('[DEBUG_LOG] MATCH OVER! Second innings complete.');
        if (isTargetChased) {
          print('[DEBUG_LOG] Reason: Target chased');
        } else {
          print('[DEBUG_LOG] Reason: ${isAllOut ? "All out" : "Overs complete"}');
        }

        // Update state to mark match as complete
        state = MatchState(
          teamAInnings: state.teamAInnings,
          teamBInnings: state.teamBInnings,
          currentInnings: state.currentInnings,
          striker: state.striker,
          nonStriker: state.nonStriker,
          bowler: state.bowler,
          matchDate: state.matchDate,
          location: state.location,
          totalOvers: state.totalOvers,
          isFirstInningsComplete: state.isFirstInningsComplete,
          isMatchComplete: true, // Mark match as complete
          playersPerSide: state.playersPerSide, // Maintain players per side
        );

        print('[DEBUG_LOG] State updated - isMatchComplete: ${state.isMatchComplete}');
      }
    }
  }

  void undoLastAction() {
    if (_history.isNotEmpty) {
      state = _history.removeLast();
      _persistenceService.saveMatchState(state);
    }
  }

  /// Handles a batsman retiring hurt.
  /// 
  /// This method updates the retiring batsman's status to PlayerStatus.retiredHurt
  /// and replaces them in the active batting position with the new batsman.
  /// 
  /// Parameters:
  /// - retiringBatsman: The batsman who is retiring hurt
  /// - newBatsman: The new batsman who will replace the retiring batsman
  void retireBatsman({
    required Player retiringBatsman,
    required Player newBatsman,
  }) {
    _history.add(state);

    if (state.striker == null || state.nonStriker == null) return; // Safety check

    // Update the retiring player's status to retiredHurt
    final updatedRetiringBatsman = retiringBatsman.copyWith(
      status: PlayerStatus.retiredHurt,
    );

    // Determine if the striker or non-striker is retiring
    final bool isStrikerRetiring = retiringBatsman.id == state.striker!.id;

    if (state.currentInnings == 1) {
      // Team A is batting
      // Update the batting team's players list with the updated retiring player
      final updatedBattingTeamPlayers = _updatePlayerInList(state.teamAInnings.players, updatedRetiringBatsman);

      state = MatchState(
        teamAInnings: TeamInnings(
          score: state.teamAInnings.score,
          wickets: state.teamAInnings.wickets,
          overs: state.teamAInnings.overs,
          balls: state.teamAInnings.balls,
          players: updatedBattingTeamPlayers,
        ),
        teamBInnings: state.teamBInnings,
        currentInnings: state.currentInnings,
        striker: isStrikerRetiring ? newBatsman : state.striker,
        nonStriker: isStrikerRetiring ? state.nonStriker : newBatsman,
        bowler: state.bowler,
        matchDate: state.matchDate,
        location: state.location,
        totalOvers: state.totalOvers,
        isFirstInningsComplete: state.isFirstInningsComplete,
        isMatchComplete: state.isMatchComplete,
      );
    } else {
      // Team B is batting
      // Update the batting team's players list with the updated retiring player
      final updatedBattingTeamPlayers = _updatePlayerInList(state.teamBInnings.players, updatedRetiringBatsman);

      state = MatchState(
        teamAInnings: state.teamAInnings,
        teamBInnings: TeamInnings(
          score: state.teamBInnings.score,
          wickets: state.teamBInnings.wickets,
          overs: state.teamBInnings.overs,
          balls: state.teamBInnings.balls,
          players: updatedBattingTeamPlayers,
        ),
        currentInnings: state.currentInnings,
        striker: isStrikerRetiring ? newBatsman : state.striker,
        nonStriker: isStrikerRetiring ? state.nonStriker : newBatsman,
        bowler: state.bowler,
        matchDate: state.matchDate,
        location: state.location,
        totalOvers: state.totalOvers,
        isFirstInningsComplete: state.isFirstInningsComplete,
        isMatchComplete: state.isMatchComplete,
      );
    }

    // Save the updated state
    _persistenceService.saveMatchState(state);
  }

  /// Sets a new bowler for the current innings.
  /// This is used when a new over starts and a new bowler needs to be selected.
  void setBowler(Player bowler) {
    _history.add(state);

    state = MatchState(
      teamAInnings: state.teamAInnings,
      teamBInnings: state.teamBInnings,
      currentInnings: state.currentInnings,
      striker: state.striker,
      nonStriker: state.nonStriker,
      bowler: bowler,
      matchDate: state.matchDate,
      location: state.location,
      totalOvers: state.totalOvers,
      isFirstInningsComplete: state.isFirstInningsComplete,
      isMatchComplete: state.isMatchComplete,
      playersPerSide: state.playersPerSide,
    );

    _persistenceService.saveMatchState(state);
  }

  /// Replaces the current bowler with a new bowler in the middle of an over.
  /// The incomplete over's stats will remain with the original bowler.
  /// 
  /// Parameters:
  /// - newBowler: The new bowler who will replace the current bowler
  void replaceBowlerMidOver({required Player newBowler}) {
    _history.add(state);

    state = MatchState(
      teamAInnings: state.teamAInnings,
      teamBInnings: state.teamBInnings,
      currentInnings: state.currentInnings,
      striker: state.striker,
      nonStriker: state.nonStriker,
      bowler: newBowler,
      matchDate: state.matchDate,
      location: state.location,
      totalOvers: state.totalOvers,
      isFirstInningsComplete: state.isFirstInningsComplete,
      isMatchComplete: state.isMatchComplete,
    );

    _persistenceService.saveMatchState(state);
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
