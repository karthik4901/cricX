import 'package:flutter/material.dart';
import '../models/match_state.dart';

class SelectOpeningPlayersDialog extends StatefulWidget {
  final List<Player> battingTeam;
  final List<Player> bowlingTeam;

  const SelectOpeningPlayersDialog({
    super.key,
    required this.battingTeam,
    required this.bowlingTeam,
  });

  @override
  State<SelectOpeningPlayersDialog> createState() =>
      _SelectOpeningPlayersDialogState();
}

class _SelectOpeningPlayersDialogState
    extends State<SelectOpeningPlayersDialog> {
  Player? _selectedStriker;
  Player? _selectedNonStriker;
  Player? _selectedBowler;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Opening Players'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Striker'),
          DropdownButton<Player>(
            value: _selectedStriker,
            hint: const Text('Select Striker'),
            isExpanded: true,
            items: widget.battingTeam.map((player) {
              return DropdownMenuItem(
                value: player,
                child: Text(player.name),
              );
            }).toList(),
            onChanged: (player) {
              setState(() {
                _selectedStriker = player;
              });
            },
          ),
          const SizedBox(height: 16),
          const Text('Non-Striker'),
          DropdownButton<Player>(
            value: _selectedNonStriker,
            hint: const Text('Select Non-Striker'),
            isExpanded: true,
            items: widget.battingTeam.map((player) {
              return DropdownMenuItem(
                value: player,
                child: Text(player.name),
              );
            }).toList(),
            onChanged: (player) {
              setState(() {
                _selectedNonStriker = player;
              });
            },
          ),
          const SizedBox(height: 16),
          const Text('Opening Bowler'),
          DropdownButton<Player>(
            value: _selectedBowler,
            hint: const Text('Select Bowler'),
            isExpanded: true,
            items: widget.bowlingTeam.map((player) {
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
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: (_selectedStriker != null &&
                  _selectedNonStriker != null &&
                  _selectedBowler != null)
              ? () {
                  // Return the selected players
                  Navigator.of(context).pop({
                    'striker': _selectedStriker,
                    'nonStriker': _selectedNonStriker,
                    'bowler': _selectedBowler,
                  });
                }
              : null, // Disable button if not all players are selected
          child: const Text('Confirm'),
        ),
      ],
    );
  }
}
