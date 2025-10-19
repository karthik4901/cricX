import 'package:flutter/material.dart';
import '../models/match_state.dart';

class SelectBowlerDialog extends StatefulWidget {
  final List<Player> bowlingTeam;
  final Player? previousBowler;

  const SelectBowlerDialog({
    super.key,
    required this.bowlingTeam,
    this.previousBowler,
  });

  @override
  State<SelectBowlerDialog> createState() => _SelectBowlerDialogState();
}

class _SelectBowlerDialogState extends State<SelectBowlerDialog> {
  Player? _selectedBowler;

  @override
  Widget build(BuildContext context) {
    // Filter out the previous bowler from the list
    final availableBowlers = widget.previousBowler != null
        ? widget.bowlingTeam.where((player) => player.id != widget.previousBowler!.id).toList()
        : widget.bowlingTeam;

    return AlertDialog(
      title: const Text('Select Next Bowler'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Select a bowler for the next over:'),
          const SizedBox(height: 16),
          DropdownButton<Player>(
            value: _selectedBowler,
            hint: const Text('Select Bowler'),
            isExpanded: true,
            items: availableBowlers.map((player) {
              return DropdownMenuItem(
                value: player,
                child: Text(player.name),
              );
            }).toList(),
            onChanged: (player) {
              setState(() {
                _selectedBowler = player;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _selectedBowler != null
              ? () {
                  Navigator.of(context).pop(_selectedBowler);
                }
              : null,
          child: const Text('Confirm'),
        ),
      ],
    );
  }
}