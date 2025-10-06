import 'package:cricx/features/scoring/models/match_state.dart';
import 'package:cricx/features/scoring/providers/match_state_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../scoring/view/scoring_screen.dart';

class MatchSetupScreen extends ConsumerStatefulWidget {
  const MatchSetupScreen({super.key});

  @override
  ConsumerState<MatchSetupScreen> createState() => _MatchSetupScreenState();
}

class _MatchSetupScreenState extends ConsumerState<MatchSetupScreen> {
  final _teamAController = TextEditingController();
  final _teamBController = TextEditingController();
  final List<TextEditingController> _teamAPlayerControllers =
      List.generate(11, (_) => TextEditingController());
  final List<TextEditingController> _teamBPlayerControllers =
      List.generate(11, (_) => TextEditingController());

  final _uuid = const Uuid();

  @override
  void dispose() {
    _teamAController.dispose();
    _teamBController.dispose();
    for (var controller in _teamAPlayerControllers) {
      controller.dispose();
    }
    for (var controller in _teamBPlayerControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setup New Match'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _teamAController,
              decoration: const InputDecoration(
                labelText: 'Team A Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Text('Team A Players', style: Theme.of(context).textTheme.titleMedium),
            ...List.generate(
                11,
                (index) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: TextField(
                        controller: _teamAPlayerControllers[index],
                        decoration: InputDecoration(
                          labelText: 'Player ${index + 1}',
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    )),
            const SizedBox(height: 24),
            TextField(
              controller: _teamBController,
              decoration: const InputDecoration(
                labelText: 'Team B Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Text('Team B Players', style: Theme.of(context).textTheme.titleMedium),
            ...List.generate(
                11,
                (index) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: TextField(
                        controller: _teamBPlayerControllers[index],
                        decoration: InputDecoration(
                          labelText: 'Player ${index + 1}',
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    )),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                final teamAName = _teamAController.text.isNotEmpty
                    ? _teamAController.text
                    : 'Team A';
                final teamBName = _teamBController.text.isNotEmpty
                    ? _teamBController.text
                    : 'Team B';

                final teamAPlayers = _teamAPlayerControllers.map((controller) {
                  return Player(
                    id: _uuid.v4(),
                    name: controller.text.isNotEmpty
                        ? controller.text
                        : 'Player',
                  );
                }).toList();

                final teamBPlayers = _teamBPlayerControllers.map((controller) {
                  return Player(
                    id: _uuid.v4(),
                    name: controller.text.isNotEmpty
                        ? controller.text
                        : 'Player',
                  );
                }).toList();

                ref.read(matchStateProvider.notifier).addPlayers(
                      teamAPlayers: teamAPlayers,
                      teamBPlayers: teamBPlayers,
                    );

                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ScoringScreen(
                      teamAName: teamAName,
                      teamBName: teamBName,
                    ),
                  ),
                );
              },
              child: const Text('Start Scoring'),
            ),
          ],
        ),
      ),
    );
  }
}
