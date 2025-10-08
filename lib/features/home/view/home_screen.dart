import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/match_setup/view/match_setup_screen.dart';
import '../../../features/scoring/view/scoring_screen.dart';
import '../../../features/scoring/models/match_state.dart';
import '../../../features/scoring/providers/match_state_provider.dart';
import '../../../services/persistence_service.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  MatchState? _savedMatch;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedMatch();
  }

  Future<void> _loadSavedMatch() async {
    final persistenceService = PersistenceService();
    final savedMatch = await persistenceService.loadMatchState();

    setState(() {
      _savedMatch = savedMatch;
      _isLoading = false;
    });
  }

  void _continueInProgressMatch() {
    if (_savedMatch != null) {
      // Navigate to the ScoringScreen with the saved match state
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ProviderScope(
            overrides: [
              // Override the default matchStateProvider with our saved state
              matchStateProvider.overrideWith(
                (ref) => MatchStateNotifier.fromState(_savedMatch!),
              ),
            ],
            child: ScoringScreen(
              teamAName: _savedMatch!.teamAInnings.players.isNotEmpty 
                  ? 'Team A' // You might want to store team names in MatchState
                  : 'Team A',
              teamBName: _savedMatch!.teamBInnings.players.isNotEmpty 
                  ? 'Team B'
                  : 'Team B',
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'CricX',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Score, Connect, Compete',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 48),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const MatchSetupScreen(),
                          ),
                        );
                      },
                      child: const Text('Start New Match'),
                    ),
                  ),
                  if (_savedMatch != null) ...[
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ElevatedButton(
                        onPressed: _continueInProgressMatch,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.secondary,
                        ),
                        child: const Text('Continue In-Progress Match'),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          // TODO: Implement View Matches navigation
                        },
                        child: const Text('View Matches'),
                      ),
                      const SizedBox(width: 16),
                      OutlinedButton(
                        onPressed: () {
                          // TODO: Implement Profile navigation
                        },
                        child: const Text('Profile'),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
