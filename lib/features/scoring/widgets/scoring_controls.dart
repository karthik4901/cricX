import 'package:flutter/material.dart';

class ScoringControls extends StatelessWidget {
  const ScoringControls({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top Row: Most important run buttons (1, 4)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildPrimaryRunButton(context, '1'),
              _buildPrimaryRunButton(context, '4'),
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
              _buildPrimaryRunButton(context, '0'),
              _buildPrimaryRunButton(context, '6'),
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
              _buildSecondaryRunButton(context, '2'),
              _buildSecondaryRunButton(context, '3'),
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
              _buildActionButton(context, 'Wicket'),
              _buildActionButton(context, 'Extras'),
              _buildActionButton(context, 'Undo'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPrimaryRunButton(BuildContext context, String label) {
    return SizedBox(
      width: 120,
      height: 80,
      child: FilledButton(
        onPressed: () {},
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

  Widget _buildSecondaryRunButton(BuildContext context, String label) {
    return SizedBox(
      width: 120,
      height: 80,
      child: FilledButton.tonal(
        onPressed: () {},
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

  Widget _buildActionButton(BuildContext context, String label) {
    return OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      child: Text(label),
    );
  }
}
