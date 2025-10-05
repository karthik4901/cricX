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
              style: Theme.of(context).textTheme.displayLarge,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const MatchSetupScreen(),
                  ),
                );
              },
              child: const Text('Start New Match'),
            ),
          ],
        ),
      ),
    );
  }
}
