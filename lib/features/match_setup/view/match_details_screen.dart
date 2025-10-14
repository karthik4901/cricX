import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// First screen in the match setup wizard that collects basic match details.
class MatchDetailsScreen extends ConsumerStatefulWidget {
  const MatchDetailsScreen({super.key});

  @override
  ConsumerState<MatchDetailsScreen> createState() => _MatchDetailsScreenState();
}

class _MatchDetailsScreenState extends ConsumerState<MatchDetailsScreen> {
  // TextEditingControllers for the input fields
  final _teamANameController = TextEditingController();
  final _teamBNameController = TextEditingController();
  final _totalOversController = TextEditingController(text: '20'); // Default to 20 overs
  final _locationController = TextEditingController();

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks
    _teamANameController.dispose();
    _teamBNameController.dispose();
    _totalOversController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Match Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _teamANameController,
              decoration: const InputDecoration(
                labelText: 'Team A Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _teamBNameController,
              decoration: const InputDecoration(
                labelText: 'Team B Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _totalOversController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Total Overs',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Location',
                border: OutlineInputBorder(),
              ),
            ),
            const Spacer(),
            FilledButton(
              onPressed: () {
                // Read values from all text fields
                final teamAName = _teamANameController.text;
                final teamBName = _teamBNameController.text;
                final totalOvers = int.tryParse(_totalOversController.text) ?? 20;
                final location = _locationController.text;

                // Navigate to RosterSetupScreen, passing the collected data
                // Note: RosterSetupScreen is not yet created, so we're just preparing the navigation
                // Navigator.of(context).push(
                //   MaterialPageRoute(
                //     builder: (context) => RosterSetupScreen(
                //       teamAName: teamAName,
                //       teamBName: teamBName,
                //       totalOvers: totalOvers,
                //       location: location,
                //     ),
                //   ),
                // );
              },
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Next: Add Players'),
            ),
          ],
        ),
      ),
    );
  }
}