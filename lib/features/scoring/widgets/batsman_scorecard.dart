import 'package:cricx/features/scoring/models/match_state.dart';
import 'package:cricx/features/scoring/providers/match_state_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BatsmanScorecard extends ConsumerWidget {
  const BatsmanScorecard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matchState = ref.watch(matchStateProvider);
    final striker = matchState.striker;
    final nonStriker = matchState.nonStriker;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildPlayerScoreRow(context, striker, isStriker: true),
            const Divider(height: 24),
            _buildPlayerScoreRow(context, nonStriker, isStriker: false),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerScoreRow(BuildContext context, Player? player, {required bool isStriker}) {
    final textTheme = Theme.of(context).textTheme;
    final runs = player != null ? '${player.runsScored}' : '-';
    final balls = player != null ? '(${player.ballsFaced})' : '(-)';
    final playerName = player != null ? (isStriker ? '${player.name}*': player.name) : (isStriker ? 'Striker' : 'Non-Striker');

    return Row(
      children: [
        // Player name (left-aligned)
        Expanded(
          flex: 3,
          child: Text(
            playerName,
            style: textTheme.titleMedium,
            textAlign: TextAlign.left,
          ),
        ),
        // Runs (right-aligned)
        Expanded(
          flex: 1,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: Text(
              runs,
              key: ValueKey<String>('runs-${player?.id ?? ''}'), // Unique key for animation
              style: textTheme.bodyLarge,
              textAlign: TextAlign.right,
            ),
          ),
        ),
        // Balls faced (left-aligned)
        Expanded(
          flex: 1,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: Text(
              balls,
              key: ValueKey<String>('balls-${player?.id ?? ''}'), // Unique key for animation
              style: textTheme.bodyLarge,
              textAlign: TextAlign.left,
            ),
          ),
        ),
      ],
    );
  }
}
