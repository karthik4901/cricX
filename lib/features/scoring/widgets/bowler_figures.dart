import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/match_state_provider.dart';

/// A widget that displays the current bowler's figures in cricket format.
/// 
/// Watches the matchStateProvider to get the current bowler from the MatchState.
/// If the bowler is not null, displays their name and bowling figures.
/// If the bowler is null, displays a placeholder text.
class BowlerFigures extends ConsumerWidget {
  const BowlerFigures({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the matchStateProvider to get the current state
    final matchState = ref.watch(matchStateProvider);
    final bowler = matchState.bowler;

    // If there's no active bowler, display a placeholder
    if (bowler == null) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text(
          'No active bowler',
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
      );
    }

    // Format the bowling figures in standard cricket format:
    // Overs - Maidens - Runs Conceded - Wickets
    // Format oversBowled to ensure it displays correctly (e.g., 3.2 for 3 overs and 2 balls)
    final overs = bowler.oversBowled.floor(); // Complete overs
    final balls = ((bowler.oversBowled - overs) * 10).round(); // Remaining balls
    final formattedOvers = '$overs.$balls';

    final figures = '$formattedOvers - ${bowler.maidens} - ${bowler.runsConceded} - ${bowler.wicketsTaken}';

    // Display the bowler's name and figures
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Bowler's name with titleMedium style
          Text(
            '${bowler.name}:',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(width: 8.0), // Spacing between name and figures
          // Bowling figures with bodyLarge style
          Text(
            figures,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}
