import 'package:cricx/features/scoring/models/match_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/match_state_provider.dart';

/// A ConsumerWidget that provides controls for scoring in a cricket match.
///
/// This widget uses Riverpod to interact with the match state.
class ScoringControls extends ConsumerWidget {
  const ScoringControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    /// Note on ref.watch() vs ref.read():
    /// - ref.watch() is used when you want to listen for changes to a provider's state
    ///   and rebuild the widget when that state changes. It's used for displaying state.
    /// - ref.read() is used for one-time reads of a provider, typically in callbacks
    ///   like button presses. It doesn't set up a listener, so it won't cause rebuilds.
    ///   It's used for performing actions that modify state.
    return Column(
      children: [
        // Top Row: Most important run buttons (1, 4)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildPrimaryRunButton(context, '1', ref),
              _buildPrimaryRunButton(context, '4', ref),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Second Row: Next most important buttons (0, 6)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildPrimaryRunButton(context, '0', ref),
              _buildPrimaryRunButton(context, '6', ref),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Third Row: Less common runs (2, 3)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSecondaryRunButton(context, '2', ref),
              _buildSecondaryRunButton(context, '3', ref),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Bottom Action Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(context, 'Wicket', ref),
              _buildActionButton(context, 'Extras', ref),
              _buildActionButton(context, 'Undo', ref),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPrimaryRunButton(
      BuildContext context, String label, WidgetRef ref) {
    return SizedBox(
      width: 120,
      height: 80,
      child: FilledButton(
        onPressed: () {
          // Call addRuns with the corresponding number of runs
          // Using ref.read() for actions that modify state
          ref.read(matchStateProvider.notifier).addRuns(int.parse(label));
        },
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildSecondaryRunButton(
      BuildContext context, String label, WidgetRef ref) {
    return SizedBox(
      width: 120,
      height: 80,
      child: FilledButton.tonal(
        onPressed: () {
          // Call addRuns with the corresponding number of runs
          // Using ref.read() for actions that modify state
          ref.read(matchStateProvider.notifier).addRuns(int.parse(label));
        },
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, String label, WidgetRef ref) {
    return OutlinedButton(
      onPressed: () {
        if (label == 'Wicket') {
          ref.read(matchStateProvider.notifier).recordWicket();
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
                            ref.read(matchStateProvider.notifier).recordExtra(
                                type: ExtraType.wide, runs: 1);
                            Navigator.pop(context);
                          },
                          child: const Text('Wide'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            ref.read(matchStateProvider.notifier).recordExtra(
                                type: ExtraType.noBall, runs: 1);
                            Navigator.pop(context);
                          },
                          child: const Text('No Ball'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            ref.read(matchStateProvider.notifier).recordExtra(
                                type: ExtraType.bye, runs: 1);
                            Navigator.pop(context);
                          },
                          child: const Text('Bye'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            ref.read(matchStateProvider.notifier).recordExtra(
                                type: ExtraType.legBye, runs: 1);
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
        }
      },
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      child: Text(label),
    );
  }
}
