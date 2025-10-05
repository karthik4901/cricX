import 'package:flutter/material.dart';
import '../../scoring/view/scoring_screen.dart';

class MatchSetupScreen extends StatefulWidget {
  const MatchSetupScreen({super.key});

  @override
  State<MatchSetupScreen> createState() => _MatchSetupScreenState();
}

class _MatchSetupScreenState extends State<MatchSetupScreen> {
  final _teamAController = TextEditingController();
  final _teamBController = TextEditingController();

  @override
  void dispose() {
    _teamAController.dispose();
    _teamBController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setup New Match'),
      ),
      body: Padding(
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
            TextField(
              controller: _teamBController,
              decoration: const InputDecoration(
                labelText: 'Team B Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Overs selection will go here.'),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                final teamAName = _teamAController.text.isNotEmpty
                    ? _teamAController.text
                    : 'Team A';
                final teamBName = _teamBController.text.isNotEmpty
                    ? _teamBController.text
                    : 'Team B';

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
