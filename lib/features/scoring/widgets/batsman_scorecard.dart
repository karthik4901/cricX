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
    final scoreString = player != null ? '${player.runsScored} (${player.ballsFaced})' : '-';
    final playerName = player != null ? (isStriker ? '${player.name}*': player.name) : (isStriker ? 'Striker' : 'Non-Striker');

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          playerName,
          style: textTheme.titleMedium,
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: Text(
            scoreString,
            key: ValueKey<String>(scoreString + (player?.id ?? '')), // Unique key for animation
            style: textTheme.bodyLarge,
          ),
        ),
      ],
    );
  }
}
