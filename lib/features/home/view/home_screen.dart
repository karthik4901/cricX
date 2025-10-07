import 'package:flutter/material.dart';
import '../../../features/match_setup/view/match_setup_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
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
