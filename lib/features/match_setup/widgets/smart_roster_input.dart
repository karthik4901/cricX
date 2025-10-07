import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SmartRosterInput extends ConsumerStatefulWidget {
  final TextEditingController controller;

  const SmartRosterInput({
    super.key,
    required this.controller,
  });

  @override
  ConsumerState<SmartRosterInput> createState() => _SmartRosterInputState();
}

class _SmartRosterInputState extends ConsumerState<SmartRosterInput> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: widget.controller,
          decoration: const InputDecoration(
            labelText: 'Enter player names, separated by commas',
            border: OutlineInputBorder(),
          ),
          maxLines: 5,
        ),
        const SizedBox(height: 16),
        Container(), // Placeholder for player chips
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            // Logic to be added later
          },
          child: const Text('Confirm Team Roster'),
        ),
      ],
    );
  }
}
