import 'package:cricx/features/scoring/widgets/batsman_scorecard.dart';
import 'package:cricx/features/scoring/widgets/bowler_figures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/scoring_controls.dart';
import '../widgets/select_bowler_dialog.dart';
import '../widgets/select_opening_players_dialog.dart';
import '../providers/match_state_provider.dart';
import '../models/match_state.dart';

class ScoringScreen extends ConsumerStatefulWidget {
  final String teamAName;
  final String teamBName;

  const ScoringScreen({
    super.key,
    required this.teamAName,
    required this.teamBName,
  });

  @override
  ConsumerState<ScoringScreen> createState() => _ScoringScreenState();
}

class _ScoringScreenState extends ConsumerState<ScoringScreen> {
  @override
  void initState() {
    super.initState();
  }

  // Function to show the innings complete dialog
  void _showInningsCompleteDialog() async {
    print('[DEBUG_LOG] _showInningsCompleteDialog called');
    final matchState = ref.read(matchStateProvider);
    print('[DEBUG_LOG] Current innings: ${matchState.currentInnings}');
    print('[DEBUG_LOG] isFirstInningsComplete: ${matchState.isFirstInningsComplete}');

    try {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Innings Complete!'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.teamAName} scored ${matchState.teamAInnings.score}-${matchState.teamAInnings.wickets}.',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  '${widget.teamBName} needs ${matchState.teamAInnings.score + 1} to win.',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () async {
                  print('[DEBUG_LOG] Start 2nd Innings button pressed');
                  // First, close the "Innings Break" dialog
                  Navigator.of(context).pop();
                  print('[DEBUG_LOG] Innings Complete dialog closed');

                  // Read the current state from the matchStateProvider to get the rosters
                  final state = ref.read(matchStateProvider);
                  print('[DEBUG_LOG] Team B players count: ${state.teamBInnings.players.length}');
                  print('[DEBUG_LOG] Team A players count: ${state.teamAInnings.players.length}');

                  // Show dialog to select opening players for the second innings
                  print('[DEBUG_LOG] Showing SelectOpeningPlayersDialog');
                  try {
                    final selectedPlayers = await showDialog<Map<String, Player>>(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        return SelectOpeningPlayersDialog(
                          battingTeam: state.teamBInnings.players,
                          bowlingTeam: state.teamAInnings.players,
                        );
                      },
                    );

                    print('[DEBUG_LOG] SelectOpeningPlayersDialog returned: $selectedPlayers');
                    // If players were selected, set them for the second innings
                    if (selectedPlayers != null) {
                      print('[DEBUG_LOG] Setting opening players for second innings');
                      ref.read(matchStateProvider.notifier).setOpeningPlayers(
                        striker: selectedPlayers['striker']!,
                        nonStriker: selectedPlayers['nonStriker']!,
                        bowler: selectedPlayers['bowler']!,
                      );
                      print('[DEBUG_LOG] Opening players set for second innings');
                    } else {
                      print('[DEBUG_LOG] No players selected for second innings');
                    }
                  } catch (e) {
                    print('[DEBUG_LOG] Error showing SelectOpeningPlayersDialog: $e');
                  }
                },
                child: const Text('Start 2nd Innings'),
              ),
            ],
          );
        },
      );
      print('[DEBUG_LOG] showDialog for innings complete returned');
    } catch (e) {
      print('[DEBUG_LOG] Error showing innings complete dialog: $e');
    }
  }

  // Function to show the match complete dialog
  void _showMatchCompleteDialog() async {
    print('[DEBUG_LOG] _showMatchCompleteDialog called');
    final matchState = ref.read(matchStateProvider);
    print('[DEBUG_LOG] Current innings: ${matchState.currentInnings}');
    print('[DEBUG_LOG] isMatchComplete: ${matchState.isMatchComplete}');

    // Determine the winner
    String resultText;
    if (matchState.teamAInnings.score > matchState.teamBInnings.score) {
      resultText = '${widget.teamAName} won by ${matchState.teamAInnings.score - matchState.teamBInnings.score} runs!';
    } else if (matchState.teamBInnings.score > matchState.teamAInnings.score) {
      resultText = '${widget.teamBName} won by ${10 - matchState.teamBInnings.wickets} wickets!';
    } else {
      resultText = 'The match ended in a tie!';
    }

    try {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Match Complete!'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.teamAName}: ${matchState.teamAInnings.score}-${matchState.teamAInnings.wickets}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  '${widget.teamBName}: ${matchState.teamBInnings.score}-${matchState.teamBInnings.wickets}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                Text(
                  resultText,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  print('[DEBUG_LOG] Return to Home button pressed');
                  // Close the dialog
                  Navigator.of(context).pop();
                  // Navigate back to the home screen
                  Navigator.of(context).pop();
                },
                child: const Text('Return to Home'),
              ),
            ],
          );
        },
      );
      print('[DEBUG_LOG] showDialog for match complete returned');
    } catch (e) {
      print('[DEBUG_LOG] Error showing match complete dialog: $e');
    }
  }


  // Function to show the select bowler dialog
  void _showSelectBowlerDialog() async {
    final matchState = ref.read(matchStateProvider);

    // Determine which team is bowling based on the current innings
    final bowlingTeam = matchState.currentInnings == 1 
        ? matchState.teamBInnings.players 
        : matchState.teamAInnings.players;

    // Get the previous bowler to exclude from the list
    final previousBowlerIndex = bowlingTeam.indexWhere(
      (player) => player.oversBowled > 0 && 
                  player.oversBowled.toStringAsFixed(1).endsWith('.0')
    );

    final previousBowler = previousBowlerIndex != -1 ? bowlingTeam[previousBowlerIndex] : null;

    // Show the dialog to select a bowler
    final selectedBowler = await showDialog<Player>(
      context: context,
      barrierDismissible: false, // User must select a bowler
      builder: (BuildContext context) {
        return SelectBowlerDialog(
          bowlingTeam: bowlingTeam,
          previousBowler: previousBowler,
        );
      },
    );

    // If a bowler was selected, update the state
    if (selectedBowler != null) {
      ref.read(matchStateProvider.notifier).setBowler(selectedBowler);
    }
  }

  @override
  Widget build(BuildContext context) {
    final matchState = ref.watch(matchStateProvider);
    print('[DEBUG_LOG] Build method - currentInnings: ${matchState.currentInnings}');
    print('[DEBUG_LOG] Build method - isFirstInningsComplete: ${matchState.isFirstInningsComplete}');
    print('[DEBUG_LOG] Build method - isMatchComplete: ${matchState.isMatchComplete}');
    print('[DEBUG_LOG] Build method - bowler: ${matchState.bowler?.name}');

    // Listen for changes in the match state
    ref.listen<MatchState>(matchStateProvider, (previous, current) {
      print('[DEBUG_LOG] Previous isFirstInningsComplete: ${previous?.isFirstInningsComplete}');
      print('[DEBUG_LOG] Current isFirstInningsComplete: ${current.isFirstInningsComplete}');
      print('[DEBUG_LOG] Previous isMatchComplete: ${previous?.isMatchComplete}');
      print('[DEBUG_LOG] Current isMatchComplete: ${current.isMatchComplete}');

      // Check if the match just completed
      if (current.isMatchComplete && 
          (previous == null || !previous.isMatchComplete)) {
        print('[DEBUG_LOG] Match just completed, showing match complete dialog');
        // Show the match complete dialog
        _showMatchCompleteDialog();
      }
      // Check if the first innings just completed (and match is not complete)
      else if (current.isFirstInningsComplete && 
          (previous == null || !previous.isFirstInningsComplete) &&
          !current.isMatchComplete) {
        print('[DEBUG_LOG] First innings just completed, showing innings complete dialog');
        // Show the innings complete dialog
        _showInningsCompleteDialog();
      }
    });

    // Debug which UI component will be shown
    if (matchState.isFirstInningsComplete) {
      print('[DEBUG_LOG] UI will show empty Container (innings complete)');
    } else if (matchState.bowler == null) {
      print('[DEBUG_LOG] UI will show Select Next Bowler button (end of over)');
    } else {
      print('[DEBUG_LOG] UI will show ScoringControls (normal play)');
    }

    final scoreStringA = '${matchState.teamAInnings.score}-${matchState.teamAInnings.wickets} (${matchState.teamAInnings.overs}.${matchState.teamAInnings.balls} / ${matchState.totalOvers})';
    final scoreStringB = '${matchState.teamBInnings.score}-${matchState.teamBInnings.wickets} (${matchState.teamBInnings.overs}.${matchState.teamBInnings.balls} / ${matchState.totalOvers})';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Match'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Zone 1: Team Score Dashboard
            Row(
              children: [
                Expanded(
                  child: Card(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            widget.teamAName,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder: (Widget child, Animation<double> animation) {
                              return FadeTransition(opacity: animation, child: child);
                            },
                            child: Text(
                              scoreStringA,
                              key: ValueKey<String>(scoreStringA),
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Card(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            widget.teamBName,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder: (Widget child, Animation<double> animation) {
                              return FadeTransition(opacity: animation, child: child);
                            },
                            child: Text(
                              scoreStringB,
                              key: ValueKey<String>(scoreStringB),
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Zone 2: Player Stats Dashboard (Flexible)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: const [
                  // Batsmen information
                  Expanded(
                    flex: 2,
                    child: BatsmanScorecard(),
                  ),
                  SizedBox(height: 8),
                  // Bowler information
                  BowlerFigures(),
                ],
              ),
            ),
            // Zone 3: Scoring Controls or Select Bowler Button
            if (matchState.isMatchComplete)
              // If match is complete, show empty container (match is over)
              Container()
            else if (matchState.isFirstInningsComplete)
              // If first innings is complete, show empty container (dialog is handling UI)
              Container()
            else if (matchState.bowler == null)
              // Show select bowler button if bowler is null (end of over)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: () {
                    print('[DEBUG_LOG] Select Next Bowler button pressed');
                    // Show dialog to select next bowler
                    _showSelectBowlerDialog();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                  ),
                  child: const Text('Select Next Bowler', style: TextStyle(fontSize: 18)),
                ),
              )
            else
              // Show scoring controls for normal play
              const ScoringControls(),
          ],
        ),
      ),
    );
  }
}
