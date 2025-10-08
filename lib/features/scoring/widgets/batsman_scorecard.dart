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
            // Header row
            _buildHeaderRow(context),
            const SizedBox(height: 8),
            // Striker row
            _buildPlayerScoreRow(context, striker, isStriker: true),
            const Divider(height: 16),
            // Non-striker row
            _buildPlayerScoreRow(context, nonStriker, isStriker: false),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderRow(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final headerStyle = textTheme.bodySmall?.copyWith(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );

    return Row(
      children: [
        // Batsman column
        Expanded(
          flex: 4,
          child: Text(
            'Batsman',
            style: headerStyle,
            textAlign: TextAlign.left,
          ),
        ),
        // Runs column
        Expanded(
          flex: 1,
          child: Text(
            'R',
            style: headerStyle,
            textAlign: TextAlign.right,
          ),
        ),
        // Balls column
        Expanded(
          flex: 1,
          child: Text(
            'B',
            style: headerStyle,
            textAlign: TextAlign.right,
          ),
        ),
        // 4s column
        Expanded(
          flex: 1,
          child: Text(
            '4s',
            style: headerStyle,
            textAlign: TextAlign.right,
          ),
        ),
        // 6s column
        Expanded(
          flex: 1,
          child: Text(
            '6s',
            style: headerStyle,
            textAlign: TextAlign.right,
          ),
        ),
        // Strike Rate column
        Expanded(
          flex: 2,
          child: Text(
            'SR',
            style: headerStyle,
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerScoreRow(BuildContext context, Player? player, {required bool isStriker}) {
    final textTheme = Theme.of(context).textTheme;

    // Default values for when player is null
    final playerName = player != null 
        ? (isStriker ? '${player.name}*' : player.name) 
        : (isStriker ? 'Striker' : 'Non-Striker');
    final runs = player != null ? '${player.runsScored}' : '-';
    final balls = player != null ? '${player.ballsFaced}' : '-';
    final fours = player != null ? '${player.fours}' : '-';
    final sixes = player != null ? '${player.sixes}' : '-';

    // Calculate strike rate
    final strikeRate = player != null && player.ballsFaced > 0
        ? ((player.runsScored / player.ballsFaced) * 100).toStringAsFixed(1)
        : '0.0';

    return Row(
      children: [
        // Batsman name (left-aligned)
        Expanded(
          flex: 4,
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
              key: ValueKey<String>('runs-${player?.id ?? ''}'),
              style: textTheme.bodyLarge,
              textAlign: TextAlign.right,
            ),
          ),
        ),
        // Balls faced (right-aligned)
        Expanded(
          flex: 1,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: Text(
              balls,
              key: ValueKey<String>('balls-${player?.id ?? ''}'),
              style: textTheme.bodyLarge,
              textAlign: TextAlign.right,
            ),
          ),
        ),
        // 4s (right-aligned)
        Expanded(
          flex: 1,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: Text(
              fours,
              key: ValueKey<String>('fours-${player?.id ?? ''}'),
              style: textTheme.bodyLarge,
              textAlign: TextAlign.right,
            ),
          ),
        ),
        // 6s (right-aligned)
        Expanded(
          flex: 1,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: Text(
              sixes,
              key: ValueKey<String>('sixes-${player?.id ?? ''}'),
              style: textTheme.bodyLarge,
              textAlign: TextAlign.right,
            ),
          ),
        ),
        // Strike Rate (right-aligned)
        Expanded(
          flex: 2,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: Text(
              strikeRate,
              key: ValueKey<String>('sr-${player?.id ?? ''}'),
              style: textTheme.bodyLarge,
              textAlign: TextAlign.right,
            ),
          ),
        ),
      ],
    );
  }
}
