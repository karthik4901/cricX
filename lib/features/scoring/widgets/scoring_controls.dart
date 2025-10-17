import 'package:cricx/features/scoring/models/match_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/match_state_provider.dart';
import '../widgets/fall_of_wicket_dialog.dart';
import '../widgets/retire_batsman_dialog.dart';

// A private stateful widget to manage the button's animation state.
class _AnimatedRunButton extends StatefulWidget {
  final String label;
  final bool isPrimary;
  final VoidCallback onPressed;

  const _AnimatedRunButton({
    required this.label,
    required this.onPressed,
    this.isPrimary = false,
  });

  @override
  State<_AnimatedRunButton> createState() => _AnimatedRunButtonState();
}

class _AnimatedRunButtonState extends State<_AnimatedRunButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    // The actual button widget, which will be animated.
    // The button's own onPressed is empty because the GestureDetector handles the tap.
    final button = widget.isPrimary
        ? FilledButton(
            onPressed: () {},
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              widget.label,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
          )
        : FilledButton.tonal(
            onPressed: () {},
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.all(16), // Correctly placed inside styleFrom
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              widget.label,
              style: const TextStyle(fontSize: 24),
            ),
          );

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed(); // Trigger the action on release
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        child: SizedBox(
          width: 120,
          height: 80,
          // AbsorbPointer prevents the button's own tap events from firing,
          // ensuring only the GestureDetector handles the interaction.
          child: AbsorbPointer(child: button),
        ),
      ),
    );
  }
}

class ScoringControls extends ConsumerWidget {
  const ScoringControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _AnimatedRunButton(label: '1', onPressed: () => ref.read(matchStateProvider.notifier).addRuns(1), isPrimary: true),
              _AnimatedRunButton(label: '4', onPressed: () => ref.read(matchStateProvider.notifier).addRuns(4), isPrimary: true),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _AnimatedRunButton(label: '0', onPressed: () => ref.read(matchStateProvider.notifier).addRuns(0), isPrimary: true),
              _AnimatedRunButton(label: '6', onPressed: () => ref.read(matchStateProvider.notifier).addRuns(6), isPrimary: true),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _AnimatedRunButton(label: '2', onPressed: () => ref.read(matchStateProvider.notifier).addRuns(2)),
              _AnimatedRunButton(label: '3', onPressed: () => ref.read(matchStateProvider.notifier).addRuns(3)),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(context, 'Wicket', ref),
              _buildActionButton(context, 'Extras', ref),
              _buildActionButton(context, 'Undo', ref),
              _buildActionButton(context, 'More', ref),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, String label, WidgetRef ref) {
    return OutlinedButton(
      onPressed: () async {
        if (label == 'Wicket') {
          final matchState = ref.read(matchStateProvider);
          final striker = matchState.striker;
          final nonStriker = matchState.nonStriker;

          // Determine which team is batting
          final List<Player> battingTeam;
          final List<Player> bowlingTeam;

          if (matchState.currentInnings == 1) {
            // Team A is batting, Team B is bowling
            battingTeam = matchState.teamAInnings.players;
            bowlingTeam = matchState.teamBInnings.players;
          } else {
            // Team B is batting, Team A is bowling
            battingTeam = matchState.teamBInnings.players;
            bowlingTeam = matchState.teamAInnings.players;
          }

          // Get the list of remaining batsmen (exclude current striker and non-striker)
          final List<Player> remainingBatsmen = battingTeam
              .where((player) => 
                  player.id != striker?.id && 
                  player.id != nonStriker?.id)
              .toList();

          // Show the FallOfWicketDialog
          final dismissalDetails = await showDialog<Map<String, dynamic>>(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return FallOfWicketDialog(
                remainingBatsmen: remainingBatsmen,
                fieldingTeam: bowlingTeam,
              );
            },
          );

          // Process the result from the dialog
          if (dismissalDetails != null) {
            // Call the handleWicketDismissal method with the correct parameters
            ref.read(matchStateProvider.notifier).handleWicketDismissal(
              dismissedBatsman: striker!,
              dismissalType: dismissalDetails['dismissalType'] as DismissalType,
              newBatsman: dismissalDetails['nextBatsman'] as Player,
            );
          }
        } else if (label == 'Extras') {
          showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return Container(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Record Extras',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16.0),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            ref.read(matchStateProvider.notifier).recordExtra(type: ExtraType.wide, runs: 1);
                            Navigator.pop(context);
                          },
                          child: const Text('Wide'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            ref.read(matchStateProvider.notifier).recordExtra(type: ExtraType.noBall, runs: 1);
                            Navigator.pop(context);
                          },
                          child: const Text('No Ball'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            ref.read(matchStateProvider.notifier).recordExtra(type: ExtraType.bye, runs: 1);
                            Navigator.pop(context);
                          },
                          child: const Text('Bye'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            ref.read(matchStateProvider.notifier).recordExtra(type: ExtraType.legBye, runs: 1);
                            Navigator.pop(context);
                          },
                          child: const Text('Leg Bye'),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        } else if (label == 'Undo') {
          ref.read(matchStateProvider.notifier).undoLastAction();
        } else if (label == 'More') {
          showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.healing),
                    title: const Text('Retired Hurt'),
                    onTap: () async {
                      // Close the bottom sheet
                      Navigator.pop(context);

                      final matchState = ref.read(matchStateProvider);
                      final striker = matchState.striker;
                      final nonStriker = matchState.nonStriker;

                      // Safety check
                      if (striker == null || nonStriker == null) return;

                      // Determine which team is batting
                      final List<Player> battingTeam;
                      if (matchState.currentInnings == 1) {
                        // Team A is batting
                        battingTeam = matchState.teamAInnings.players;
                      } else {
                        // Team B is batting
                        battingTeam = matchState.teamBInnings.players;
                      }

                      // Get the list of remaining batsmen (exclude current striker and non-striker)
                      final List<Player> remainingBatsmen = battingTeam
                          .where((player) => 
                              player.id != striker.id && 
                              player.id != nonStriker.id)
                          .toList();

                      // Show the RetireBatsmanDialog
                      final result = await showDialog<Map<String, dynamic>>(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return RetireBatsmanDialog(
                            striker: striker,
                            nonStriker: nonStriker,
                            remainingBatsmen: remainingBatsmen,
                          );
                        },
                      );

                      // Process the result from the dialog
                      if (result != null) {
                        ref.read(matchStateProvider.notifier).retireBatsman(
                          retiringBatsman: result['retiringBatsman'] as Player,
                          newBatsman: result['newBatsman'] as Player,
                        );
                      }
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.swap_horiz),
                    title: const Text('Change Bowler (Mid-Over)'),
                    onTap: () {
                      // Empty onTap callback as specified
                      Navigator.pop(context);
                    },
                  ),
                ],
              );
            },
          );
        }
      },
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      child: Text(label),
    );
  }
}
