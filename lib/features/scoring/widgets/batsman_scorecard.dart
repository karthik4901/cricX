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

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Column(
        children: [
          _buildPlayerScoreRow(context, striker, isStriker: true),
          const SizedBox(height: 8),
          _buildPlayerScoreRow(context, nonStriker, isStriker: false),
        ],
      ),
    );
  }

  Widget _buildPlayerScoreRow(BuildContext context, Player? player, {required bool isStriker}) {
    final textTheme = Theme.of(context).textTheme;

    if (player == null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            isStriker ? 'Striker' : 'Non-Striker',
            style: textTheme.titleMedium?.copyWith(color: Colors.grey),
          ),
          Text(
            '-',
            style: textTheme.bodyLarge?.copyWith(color: Colors.grey),
          ),
        ],
      );
    }

    final playerName = isStriker ? '${player.name}*' : player.name;
    final scoreString = '${player.runsScored} (${player.ballsFaced})';

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
            key: ValueKey<String>(scoreString), // Crucial for AnimatedSwitcher to detect change
            style: textTheme.bodyLarge,
          ),
        ),
      ],
    );
  }
}
